import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../constants/canteen_constants.dart';

class CanteenStructureState {
  final List<String> squadrons;
  final Map<String, List<String>> roomsBySquadron;

  const CanteenStructureState({
    this.squadrons = CanteenConstants.squadrons,
    this.roomsBySquadron = const {},
  });

  List<String> getRoomsForSquadron(String squadron) {
    if (roomsBySquadron.containsKey(squadron) && roomsBySquadron[squadron]!.isNotEmpty) {
      return roomsBySquadron[squadron]!;
    }
    return CanteenConstants.rooms;
  }

  CanteenStructureState copyWith({
    List<String>? squadrons,
    Map<String, List<String>>? roomsBySquadron,
  }) {
    return CanteenStructureState(
      squadrons: squadrons ?? this.squadrons,
      roomsBySquadron: roomsBySquadron ?? this.roomsBySquadron,
    );
  }
}

final canteenStructureProvider =
    NotifierProvider<CanteenStructureNotifier, CanteenStructureState>(
  CanteenStructureNotifier.new,
);

class CanteenStructureNotifier extends Notifier<CanteenStructureState> {
  static const String _prefsKeySquadrons = 'rts_canteen_squadrons_v2';
  static const String _prefsKeyRooms = 'rts_canteen_rooms_per_squadron_v2';
  bool _disposed = false;

  @override
  CanteenStructureState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _loadFromPrefs();
    return _buildInitialState();
  }

  CanteenStructureState _buildInitialState() {
    final Map<String, List<String>> initialMap = {};
    for (final sqn in CanteenConstants.squadrons) {
      initialMap[sqn] = List<String>.from(CanteenConstants.rooms);
    }
    return CanteenStructureState(
      squadrons: List<String>.from(CanteenConstants.squadrons),
      roomsBySquadron: initialMap,
    );
  }

  Future<void> _loadFromPrefs() async {
    if (_disposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      final sqns = prefs.getStringList(_prefsKeySquadrons);
      final roomsJson = prefs.getString(_prefsKeyRooms);

      List<String> loadedSqns = state.squadrons;
      if (sqns != null && sqns.isNotEmpty) {
        loadedSqns = sqns;
      }

      Map<String, List<String>> loadedRooms = Map.from(state.roomsBySquadron);
      if (roomsJson != null) {
        final decoded = jsonDecode(roomsJson) as Map<String, dynamic>;
        loadedRooms = decoded.map((k, v) => MapEntry(k, List<String>.from(v as List)));
      }

      // Ensure every squadron has a room list
      for (final sqn in loadedSqns) {
        if (!loadedRooms.containsKey(sqn) || loadedRooms[sqn]!.isEmpty) {
          loadedRooms[sqn] = List<String>.from(CanteenConstants.rooms);
        }
      }

      if (_disposed) return;
      state = state.copyWith(
        squadrons: loadedSqns,
        roomsBySquadron: loadedRooms,
      );
    } catch (_) {
      // Fallback to default state
    }

    // Next sync with backend database
    _syncWithServer();
  }

  Future<void> _syncWithServer() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.squadrons);
      if (_disposed) return;
      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data as Map<String, dynamic>;
        final data = resData['data'] as List?;
        if (data != null && data.isNotEmpty) {
          final List<String> serverSqns = [];
          final Map<String, List<String>> serverRooms = {};
          for (final item in data) {
            final m = item as Map<String, dynamic>;
            final name = m['name'] as String;
            final rooms = (m['rooms'] as List?)?.map((r) => r.toString()).toList() ?? [];
            serverSqns.add(name);
            serverRooms[name] = rooms.isNotEmpty ? rooms : List<String>.from(CanteenConstants.rooms);
          }
          if (_disposed) return;
          state = state.copyWith(squadrons: serverSqns, roomsBySquadron: serverRooms);
          await _saveToPrefs();
        }
      }
    } catch (_) {
      // Gracefully retain offline/cached state
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKeySquadrons, state.squadrons);
      await prefs.setString(_prefsKeyRooms, jsonEncode(state.roomsBySquadron));
    } catch (_) {}
  }

  Future<bool> addSquadron(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || state.squadrons.contains(trimmed)) {
      return false;
    }
    final updatedSqns = [...state.squadrons, trimmed];
    final updatedRooms = Map<String, List<String>>.from(state.roomsBySquadron);
    // Initialize standard 16 rooms for the new squadron
    updatedRooms[trimmed] = List<String>.from(CanteenConstants.rooms);

    state = state.copyWith(squadrons: updatedSqns, roomsBySquadron: updatedRooms);
    await _saveToPrefs();

    // Async sync to server database
    try {
      final dio = ref.read(dioProvider);
      await dio.post(
        ApiEndpoints.squadrons,
        data: {
          'name': trimmed,
          'rooms': CanteenConstants.rooms,
        },
      );
    } catch (_) {}

    return true;
  }

  Future<bool> removeSquadron(String name) async {
    if (state.squadrons.length <= 1) {
      return false; // Guard: At least 1 squadron must remain
    }
    final updatedSqns = state.squadrons.where((s) => s != name).toList();
    final updatedRooms = Map<String, List<String>>.from(state.roomsBySquadron);
    updatedRooms.remove(name);

    state = state.copyWith(squadrons: updatedSqns, roomsBySquadron: updatedRooms);
    await _saveToPrefs();

    // Async sync to server database
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('${ApiEndpoints.squadrons}/$name');
    } catch (_) {}

    return true;
  }

  Future<bool> addRoom(String squadron, String roomName) async {
    final trimmed = roomName.trim();
    if (trimmed.isEmpty) return false;

    final currentRooms = List<String>.from(state.getRoomsForSquadron(squadron));
    if (currentRooms.contains(trimmed)) return false;

    currentRooms.add(trimmed);
    final updatedRooms = Map<String, List<String>>.from(state.roomsBySquadron);
    updatedRooms[squadron] = currentRooms;

    state = state.copyWith(roomsBySquadron: updatedRooms);
    await _saveToPrefs();

    // Async sync to server database
    try {
      final dio = ref.read(dioProvider);
      await dio.post(
        ApiEndpoints.squadronRooms(squadron),
        data: {'room': trimmed},
      );
    } catch (_) {}

    return true;
  }

  Future<bool> removeRoom(String squadron, String roomName) async {
    final currentRooms = List<String>.from(state.getRoomsForSquadron(squadron));
    if (currentRooms.length <= 1) {
      return false; // Guard: At least 1 room must remain in a squadron
    }
    currentRooms.remove(roomName);
    final updatedRooms = Map<String, List<String>>.from(state.roomsBySquadron);
    updatedRooms[squadron] = currentRooms;

    state = state.copyWith(roomsBySquadron: updatedRooms);
    await _saveToPrefs();

    // Async sync to server database
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('${ApiEndpoints.squadronRooms(squadron)}/$roomName');
    } catch (_) {}

    return true;
  }
}
