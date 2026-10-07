import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/room_monthly_summary.dart';

class CanteenPdfExportService {
  static const List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  /// Builds a publication-grade vector PDF of the official Canteen Monthly Register
  static Future<Uint8List> generateRoomSpreadsheetPdf({
    required RoomMonthlySummary summary,
    required String entryNumber,
    required String squadron,
    required String room,
    required int year,
    required int month,
  }) async {
    final pdf = pw.Document(
      title: 'BAF RTS Food Canteen - Entry $entryNumber $squadron Sqn $room',
      author: 'Bangladesh Air Force RTS Canteen',
    );

    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final dateFormat = DateFormat('dd-MM-yyyy');
    final monthName = monthNames[month - 1];

    // Load BAF emblem crest image asset if available
    pw.MemoryImage? crestImage;
    try {
      final crestData = await rootBundle.load('assets/images/baf_crest.png');
      crestImage = pw.MemoryImage(crestData.buffer.asUint8List());
    } catch (_) {
      // Fallback if asset cannot be loaded in test or headless environment
      crestImage = null;
    }

    final navyColor = PdfColor.fromHex('#001F3F');
    final deepBlue = PdfColor.fromHex('#0B3C5D');
    final goldColor = PdfColor.fromHex('#D4AF37');
    final lightBlueBg = PdfColor.fromHex('#EAF2F8');
    final stripeBg = PdfColor.fromHex('#F4F6F9');
    final borderGrey = PdfColor.fromHex('#BDC3C7');
    final redDebit = PdfColor.fromHex('#C0392B');
    final greenCredit = PdfColor.fromHex('#27AE60');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header Banner with BAF RTS Emblem and Titles
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: navyColor,
                  border: pw.Border.all(color: goldColor, width: 1.5),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (crestImage != null)
                      pw.Container(
                        width: 44,
                        height: 44,
                        margin: const pw.EdgeInsets.only(right: 12),
                        child: pw.Image(crestImage, fit: pw.BoxFit.contain),
                      ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "PEOPLE'S REPUBLIC OF BANGLADESH • BANGLADESH AIR FORCE",
                            style: pw.TextStyle(
                              color: goldColor,
                              fontSize: 7.5,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'RECRUITS TRAINING SCHOOL (RTS)',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            'FOOD CANTEEN • MONTHLY ROOM EXPENDITURE REGISTER',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: deepBlue,
                        border: pw.Border.all(color: goldColor, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'ENTRY: $entryNumber',
                            style: pw.TextStyle(
                              color: goldColor,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '$monthName $year',
                            style: const pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 8.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 6),

              // Metadata Information Strip
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: lightBlueBg,
                  border: pw.Border.all(color: borderGrey, width: 0.8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPdfMeta('SQUADRON', '$squadron Sqn'),
                    _buildPdfMeta('ROOM', room),
                    _buildPdfMeta('RANK / RK', summary.rank),
                    _buildPdfMeta('PERIOD', '${monthName.toUpperCase()} $year'),
                    _buildPdfMeta('ACTIVE VISITS', '${summary.activeDaysCount} Days'),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // Ledger Table
              pw.Table(
                border: pw.TableBorder.all(color: borderGrey, width: 0.5),
                columnWidths: const {
                  0: pw.FixedColumnWidth(28), // Day #
                  1: pw.FixedColumnWidth(65), // Date
                  2: pw.FixedColumnWidth(65), // Weekday
                  3: pw.FlexColumnWidth(2.5), // Duty In-charge
                  4: pw.FixedColumnWidth(65), // Rep Sign
                  5: pw.FixedColumnWidth(70), // Price
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: navyColor),
                    children: [
                      _buildPdfCell('DAY', isHeader: true, align: pw.TextAlign.center),
                      _buildPdfCell('DATE', isHeader: true, align: pw.TextAlign.center),
                      _buildPdfCell('WEEKDAY', isHeader: true, align: pw.TextAlign.center),
                      _buildPdfCell('DUTY IN-CHARGE', isHeader: true),
                      _buildPdfCell('REP SIGN', isHeader: true, align: pw.TextAlign.center),
                      _buildPdfCell('PRICE (TK)', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),

                  // Daily Rows (Filtered or all days)
                  ...summary.days.map((record) {
                    final hasSpent = record.amount > 0;
                    final isEven = record.dayNumber % 2 == 0;
                    final rowBg = hasSpent
                        ? (isEven ? lightBlueBg : PdfColors.white)
                        : (isEven ? stripeBg : PdfColors.white);

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: rowBg),
                      children: [
                        _buildPdfCell(
                          '${record.dayNumber}',
                          align: pw.TextAlign.center,
                          isBold: hasSpent,
                          fontSize: 8,
                        ),
                        _buildPdfCell(
                          dateFormat.format(record.date),
                          align: pw.TextAlign.center,
                          fontSize: 7.5,
                        ),
                        _buildPdfCell(
                          DateFormat('EEEE').format(record.date),
                          align: pw.TextAlign.center,
                          fontSize: 7.5,
                        ),
                        _buildPdfCell(
                          hasSpent ? record.recordedBy : '—',
                          fontSize: 7.5,
                          color: hasSpent ? PdfColors.black : PdfColors.grey700,
                        ),
                        _buildPdfCell(
                          hasSpent ? (record.representativeName ?? 'Present') : '—',
                          align: pw.TextAlign.center,
                          fontSize: 7.5,
                        ),
                        _buildPdfCell(
                          hasSpent ? 'Tk ${currencyFormat.format(record.amount)}' : '—',
                          align: pw.TextAlign.right,
                          isBold: hasSpent,
                          fontSize: 8,
                          color: hasSpent ? redDebit : PdfColors.grey600,
                        ),
                      ],
                    );
                  }),

                  // Subtotal 1: Month Spending
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightBlueBg),
                    children: [
                      _buildPdfCell(''),
                      _buildPdfCell('1. MONTH TOTAL', isBold: true, fontSize: 8),
                      _buildPdfCell(''),
                      _buildPdfCell('Current month room price total', fontSize: 7.5),
                      _buildPdfCell('AUDITED', align: pw.TextAlign.center, fontSize: 7),
                      _buildPdfCell('Tk ${currencyFormat.format(summary.totalMonthlySpending)}', align: pw.TextAlign.right, isBold: true, fontSize: 8.5),
                    ],
                  ),

                  // Subtotal 2: Previous Due
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      _buildPdfCell(''),
                      _buildPdfCell('2. PREVIOUS DUE', isBold: true, fontSize: 8, color: redDebit),
                      _buildPdfCell(''),
                      _buildPdfCell('Carried over from prior audit period', fontSize: 7.5),
                      _buildPdfCell('CONFIRMED', align: pw.TextAlign.center, fontSize: 7),
                      _buildPdfCell('Tk ${currencyFormat.format(summary.preDue)}', align: pw.TextAlign.right, isBold: true, fontSize: 8.5, color: redDebit),
                    ],
                  ),

                  // Subtotal 3: Grand Total
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightBlueBg),
                    children: [
                      _buildPdfCell(''),
                      _buildPdfCell('3. GRAND TOTAL', isBold: true, fontSize: 8.5),
                      _buildPdfCell('Gross liability (Pre Due + Current Month)', isBold: true, fontSize: 7.5),
                      _buildPdfCell('Tk ${currencyFormat.format(summary.grandTotal)}', align: pw.TextAlign.right, isBold: true, fontSize: 9),
                      _buildPdfCell('VERIFIED', align: pw.TextAlign.center, fontSize: 7),
                      _buildPdfCell('VERIFIED', align: pw.TextAlign.center, fontSize: 7),
                    ],
                  ),

                  // Subtotal 4: Less Paid
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      _buildPdfCell(''),
                      _buildPdfCell('4. LESS: PAID', isBold: true, fontSize: 8, color: greenCredit),
                      _buildPdfCell('Total cash collection settled by room', fontSize: 7.5, color: greenCredit),
                      _buildPdfCell('Tk ${currencyFormat.format(summary.paid)}', align: pw.TextAlign.right, isBold: true, fontSize: 8.5, color: greenCredit),
                      _buildPdfCell('COLLECTED', align: pw.TextAlign.center, fontSize: 7),
                      _buildPdfCell('RECEIPTED', align: pw.TextAlign.center, fontSize: 7),
                    ],
                  ),

                  // Subtotal 5: Net Closing Due
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: navyColor),
                    children: [
                      _buildPdfCell('', isHeader: true),
                      _buildPdfCell('5. NET CLOSING DUE', isHeader: true, isBold: true, fontSize: 8.5),
                      _buildPdfCell('Net outstanding balance payable as of month end', isHeader: true, fontSize: 7.5),
                      _buildPdfCell('Tk ${currencyFormat.format(summary.netDue)}', isHeader: true, align: pw.TextAlign.right, isBold: true, fontSize: 9.5, color: goldColor),
                      _buildPdfCell('FINAL', isHeader: true, align: pw.TextAlign.center, fontSize: 7),
                      _buildPdfCell(summary.netDue <= 0 ? 'CLEARED' : 'PENDING', isHeader: true, align: pw.TextAlign.center, fontSize: 7),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              // Sign-off Certification Blocks
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 14),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPdfSignature('ROOM REPRESENTATIVE', summary.rank, room),
                    _buildPdfSignature('NCOIC (CANTEEN)', 'Sergeant (Sgt)', 'RTS BAF'),
                    _buildPdfSignature('JCOIC (CANTEEN)', 'Warrant Officer (WO)', 'RTS BAF'),
                    _buildPdfSignature('COUNTERSIGNED (OC)', 'Officer Commanding', 'RTS, Bangladesh Air Force'),
                  ],
                ),
              ),

              pw.SizedBox(height: 4),

              // Security Footer
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text(
                  'SECURITY CLASSIFICATION: OFFICIAL USE ONLY • RECRUITS TRAINING SCHOOL (RTS) • BANGLADESH AIR FORCE',
                  style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Downloads the PDF document directly to the device storage
  /// Returns the saved file path
  static Future<String> downloadPdfToDevice({
    required Uint8List pdfBytes,
    required String filename,
  }) async {
    Directory? directory;

    if (Platform.isAndroid) {
      // Try Download folder first for Android
      try {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } catch (_) {
        directory = await getApplicationDocumentsDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final targetDir = directory ?? await getApplicationDocumentsDirectory();
    final filePath = '${targetDir.path}/$filename';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes, flush: true);

    return filePath;
  }

  /// Shares or exports the PDF via native share sheet or printer dialog
  static Future<void> shareOrOpenPdf({
    required Uint8List pdfBytes,
    required String filename,
  }) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: filename,
    );
  }

  static pw.Widget _buildPdfMeta(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
      ],
    );
  }

  static pw.Widget _buildPdfCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    pw.TextAlign align = pw.TextAlign.left,
    double fontSize = 8,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3.5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? (isHeader ? PdfColors.white : PdfColors.black),
        ),
      ),
    );
  }

  static pw.Widget _buildPdfSignature(String title, String rank, String unit) {
    return pw.Column(
      children: [
        pw.Container(width: 95, height: 0.8, color: PdfColors.black),
        pw.SizedBox(height: 3),
        pw.Text(title, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
        pw.Text(rank, style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700)),
        pw.Text(unit, style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600)),
      ],
    );
  }
}
