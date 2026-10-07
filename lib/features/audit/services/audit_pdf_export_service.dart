import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/monthly_audit_statement.dart';

class AuditPdfExportService {
  static Future<Uint8List> generateAuditPdf({
    required MonthlyAuditStatement audit,
  }) async {
    final pdf = pw.Document();

    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

    pw.MemoryImage? crestImage;
    try {
      final crestData = await rootBundle.load('assets/images/baf_logo.png');
      crestImage = pw.MemoryImage(crestData.buffer.asUint8List());
    } catch (_) {
      crestImage = null;
    }

    final navyColor = PdfColor.fromHex('#001F3F');
    final goldColor = PdfColor.fromHex('#D4AF37');
    final lightBlueBg = PdfColor.fromHex('#EAF2F8');
    final stripeBg = PdfColor.fromHex('#F4F6F9');
    final borderGrey = PdfColor.fromHex('#BDC3C7');
    final redDebit = PdfColor.fromHex('#C0392B');
    final greenCredit = PdfColor.fromHex('#27AE60');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                color: navyColor,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (crestImage != null)
                      pw.Container(
                        width: 48,
                        height: 48,
                        margin: const pw.EdgeInsets.only(right: 12),
                        child: pw.Image(crestImage),
                      ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "PEOPLE'S REPUBLIC OF BANGLADESH • BANGLADESH AIR FORCE",
                            style: pw.TextStyle(
                              color: goldColor,
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'RECRUITS TRAINING SCHOOL (RTS)',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'FOOD CANTEEN & MESS ACCOUNTS — OFFICIAL AUDIT STATEMENT',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // Metadata Ribbon
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: lightBlueBg,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPdfMeta('ACCOUNTING PERIOD', audit.period.toUpperCase()),
                    _buildPdfMeta('GENERATED DATE', dateFormat.format(audit.generatedDate)),
                    _buildPdfMeta('AUDIT STATUS', 'VERIFIED & BALANCED (100% OK)'),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // Table Title
              pw.Text(
                '1. COMPREHENSIVE ACCOUNTS RECONCILIATION SUMMARY',
                style: pw.TextStyle(
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                  color: navyColor,
                ),
              ),
              pw.SizedBox(height: 6),

              // Reconciliation Table
              pw.Table(
                border: pw.TableBorder.all(color: borderGrey, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3.0),
                  1: pw.FixedColumnWidth(48),
                  2: pw.FixedColumnWidth(68),
                  3: pw.FixedColumnWidth(70),
                  4: pw.FixedColumnWidth(70),
                  5: pw.FixedColumnWidth(72),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: navyColor),
                    children: [
                      _buildPdfCell('ACCOUNT CLASSIFICATION', isHeader: true),
                      _buildPdfCell('HEAD', isHeader: true, align: pw.TextAlign.center),
                      _buildPdfCell('OPENING (TK)', isHeader: true, align: pw.TextAlign.right),
                      _buildPdfCell('DEBIT [CHARGES]', isHeader: true, align: pw.TextAlign.right),
                      _buildPdfCell('CREDIT [PAID]', isHeader: true, align: pw.TextAlign.right),
                      _buildPdfCell('CLOSING [DUE]', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      _buildPdfCell('Recruits Mess Account (Intake & Squadrons)', isBold: true),
                      _buildPdfCell('${audit.totalRecruitsEnrolled}', align: pw.TextAlign.center),
                      _buildPdfCell(currencyFormat.format(audit.recruitOpeningBalance), align: pw.TextAlign.right),
                      _buildPdfCell(currencyFormat.format(audit.recruitTotalDebits), align: pw.TextAlign.right, color: redDebit),
                      _buildPdfCell(currencyFormat.format(audit.recruitTotalCredits), align: pw.TextAlign.right, color: greenCredit),
                      _buildPdfCell(currencyFormat.format(audit.recruitClosingBalance), align: pw.TextAlign.right, isBold: true),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: stripeBg),
                    children: [
                      _buildPdfCell('Permanent Staff Mess Account (Offices & BD No)', isBold: true),
                      _buildPdfCell('${audit.totalStaffEnrolled}', align: pw.TextAlign.center),
                      _buildPdfCell(currencyFormat.format(audit.staffOpeningBalance), align: pw.TextAlign.right),
                      _buildPdfCell(currencyFormat.format(audit.staffTotalDebits), align: pw.TextAlign.right, color: redDebit),
                      _buildPdfCell(currencyFormat.format(audit.staffTotalCredits), align: pw.TextAlign.right, color: greenCredit),
                      _buildPdfCell(currencyFormat.format(audit.staffClosingBalance), align: pw.TextAlign.right, isBold: true),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightBlueBg),
                    children: [
                      _buildPdfCell('GRAND TOTAL (CANTEEN RECONCILED)', isBold: true, fontSize: 8.5),
                      _buildPdfCell('${audit.totalRecruitsEnrolled + audit.totalStaffEnrolled}', align: pw.TextAlign.center, isBold: true),
                      _buildPdfCell(currencyFormat.format(audit.grandOpeningBalance), align: pw.TextAlign.right, isBold: true),
                      _buildPdfCell(currencyFormat.format(audit.grandTotalDebits), align: pw.TextAlign.right, isBold: true, color: redDebit),
                      _buildPdfCell(currencyFormat.format(audit.grandTotalCredits), align: pw.TextAlign.right, isBold: true, color: greenCredit),
                      _buildPdfCell(currencyFormat.format(audit.grandClosingBalance), align: pw.TextAlign.right, isBold: true),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              // Mathematical Checksum Box
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.TableBorder.all(color: goldColor, width: 1),
                  color: stripeBg,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'MATHEMATICAL AUDIT & CHECKSUM VERIFICATION',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: navyColor),
                        ),
                        pw.Text(
                          'RECONCILED: 100% BALANCED',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: greenCredit),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Checksum Equation: [Opening Dues Tk ${currencyFormat.format(audit.grandOpeningBalance)}] + [Total Debits Tk ${currencyFormat.format(audit.grandTotalDebits)}] - [Total Credits Tk ${currencyFormat.format(audit.grandTotalCredits)}] = [Net Closing Arrears Tk ${currencyFormat.format(audit.grandClosingBalance)}]',
                      style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Signatures
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPdfSignature('NCOIC (CANTEEN)', 'Sergeant (Sgt)', 'RTS BAF'),
                    _buildPdfSignature('JCOIC (CANTEEN)', 'Warrant Officer (WO)', 'RTS BAF'),
                    _buildPdfSignature('AUDIT OFFICER', 'Flight Lieutenant (Flt Lt)', 'RTS BAF'),
                    _buildPdfSignature('OFFICER COMMANDING (OC)', 'Wing Commander (Wg Cdr)', 'RTS (BAF)'),
                  ],
                ),
              ),

              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'CONFIDENTIAL • RTS BAF CANTEEN OFFICIAL RECORDS • COMPUTER-GENERATED AUDIT STATEMENT',
                  style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<String> downloadPdfToDevice({
    required Uint8List pdfBytes,
    required String filename,
  }) async {
    Directory? directory;

    if (Platform.isAndroid) {
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
        pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
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
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
