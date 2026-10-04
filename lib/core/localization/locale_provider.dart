import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, bengali }

class LocaleNotifier extends Notifier<AppLanguage> {
  static const String _prefsKeyLocale = 'rts_app_language_v2';

  @override
  AppLanguage build() {
    _loadLocale();
    return AppLanguage.english;
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString(_prefsKeyLocale);
      if (lang == 'bn') {
        state = AppLanguage.bengali;
      } else {
        state = AppLanguage.english;
      }
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyLocale, language == AppLanguage.bengali ? 'bn' : 'en');
    } catch (_) {}
  }

  void toggleLanguage() {
    setLanguage(state == AppLanguage.english ? AppLanguage.bengali : AppLanguage.english);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, AppLanguage>(
  LocaleNotifier.new,
);

class AppTranslations {
  static String tr(String key, AppLanguage lang) {
    if (lang == AppLanguage.bengali) {
      return _bn[key] ?? _en[key] ?? key;
    }
    return _en[key] ?? key;
  }

  static const Map<String, String> _en = {
    'app_title': 'FOOD CANTEEN, RTS',
    'app_subtitle': 'Recruits Training School • Shamshernagar',
    'recruits_canteen': 'RECRUITS CANTEEN (ROOM-WISE)',
    'p_staff_canteen': 'P-STAFFS CANTEEN (INDIVIDUAL)',
    'register': 'REGISTER',
    'matrix': 'MATRIX',
    'audit': 'AUDIT',
    'staff_book': 'STAFF BOOK',
    'statement': 'STATEMENT',
    'settings': 'SETTINGS',
    'squadron': 'SQUADRON',
    'room': 'ROOM',
    'entry': 'ENTRY',
    'active_entry': 'ACTIVE RECRUIT ENTRY BATCH',
    'duty_manager': 'DUTY IN-CHARGE',
    'logout': 'LOGOUT SESSION',
    'logout_confirm': 'Are you sure you want to end this duty session and log out?',
    'cancel': 'CANCEL',
    'confirm': 'CONFIRM',
    'save_price': 'SAVE PRICE IN BOOK',
    'appearance': 'APPEARANCE & THEME',
    'language': 'LANGUAGE (ভাষা)',
    'squadron_management': 'SQUADRON MANAGEMENT',
    'room_management': 'ROOM MANAGEMENT (PER SQUADRON)',
    'add_squadron': 'ADD SQUADRON',
    'add_room': 'ADD ROOM',
    'dark_mode': 'Dark',
    'light_mode': 'Light',
    'system_mode': 'System',
    'version': 'BAF RTS Food Canteen System v1.1.0',
    'search_staff': 'Search BD No or Name',
    'add_new_staff': 'ADD NEW P-STAFF',
    'expense_entry': 'RECORD EXPENSE',
    'cash_payment': 'RECORD CASH PAYMENT',
    'monthly_summary': 'MONTHLY SUMMARY',
    'download_pdf': 'DOWNLOAD PDF',
    'share': 'SHARE',
    'pre_due': 'PRE DUE',
    'month_spend': 'MONTH SPEND',
    'paid': 'PAID',
    'net_due': 'NET DUE',
    'all_rooms': 'All Rooms',
    'grand_total': 'GRAND TOTAL',
    'today': 'TODAY',
    'clear_all': 'CLEAR ALL',
    'daily_voucher': 'DAILY VOUCHER ENTRY',
    'audit_integrity': 'AUDIT INTEGRITY',
    'duty': 'DUTY',
    'verified': 'VERIFIED',
    'save': 'SAVE',
    'delete': 'DELETE',
    'remove': 'REMOVE',
  };

  static const Map<String, String> _bn = {
    'app_title': 'খাদ্য ক্যান্টিন, আরটিএস',
    'app_subtitle': 'রিক্রুটস ট্রেনিং স্কুল • শমশেরনগর',
    'recruits_canteen': 'রিক্রুটস ক্যান্টিন (রুম ভিত্তিক)',
    'p_staff_canteen': 'পি-স্টাফ ক্যান্টিন (ব্যক্তিগত)',
    'register': 'রেজিস্টার',
    'matrix': 'ম্যাট্রিক্স',
    'audit': 'অডিট',
    'staff_book': 'স্টাফ খাতা',
    'statement': 'স্টেটমেন্ট',
    'settings': 'সেটিংস',
    'squadron': 'স্কোয়াড্রন',
    'room': 'রুম',
    'entry': 'এন্ট্রি',
    'active_entry': 'সক্রিয় রিক্রুট এন্ট্রি ব্যাচ',
    'duty_manager': 'দায়িত্বরত কর্মকর্তা',
    'logout': 'লগআউট',
    'logout_confirm': 'আপনি কি এই ডিউটি সেশন শেষ করে লগআউট করতে চান?',
    'cancel': 'বাতিল',
    'confirm': 'নিশ্চিত',
    'save_price': 'খাতায় জমা করুন',
    'appearance': 'থিম ও প্রদর্শন',
    'language': 'ভাষা (LANGUAGE)',
    'squadron_management': 'স্কোয়াড্রন ব্যবস্থাপনা',
    'room_management': 'রুম ব্যবস্থাপনা (প্রতি স্কোয়াড্রন)',
    'add_squadron': 'স্কোয়াড্রন যোগ করুন',
    'add_room': 'রুম যোগ করুন',
    'dark_mode': 'ডার্ক',
    'light_mode': 'লাইট',
    'system_mode': 'সিস্টেম',
    'version': 'বিএএফ আরটিএস খাদ্য ক্যান্টিন সংস্করণ ১.১.০',
    'search_staff': 'বিডি নম্বর বা নাম খুঁজুন',
    'add_new_staff': 'নতুন পি-স্টাফ যোগ করুন',
    'expense_entry': 'ব্যয় লিপিবদ্ধ করুন',
    'cash_payment': 'নগদ জমা লিপিবদ্ধ করুন',
    'monthly_summary': 'মাসিক বিবরণী',
    'download_pdf': 'পিডিএফ ডাউনলোড',
    'share': 'শেয়ার করুন',
    'pre_due': 'পূর্বের বকেয়া',
    'month_spend': 'চলতি মাসের ব্যয়',
    'paid': 'পরিশোধ',
    'net_due': 'মোট বকেয়া',
    'all_rooms': 'সকল রুম',
    'grand_total': 'সর্বমোট',
    'today': 'আজ',
    'clear_all': 'সব মুছুন',
    'daily_voucher': 'দৈনিক ভাউচার এন্ট্রি',
    'audit_integrity': 'অডিট নির্ভুলতা',
    'duty': 'ডিউটি',
    'verified': 'যাচাইকৃত',
    'save': 'সংরক্ষণ',
    'delete': 'মুছুন',
    'remove': 'অপসারণ',
  };
}

extension TranslationContext on BuildContext {
  String tr(String key, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    return AppTranslations.tr(key, lang);
  }
}
