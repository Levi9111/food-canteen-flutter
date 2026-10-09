import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/p_staff_models.dart';

class PStaffPdfExportService {
  static const List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static Future<Uint8List> generateStaffSpreadsheetPdf({
    required StaffMonthlySummary summary,
    required int year,
    required int month,
  }) async {
    final pdf = pw.Document(
      title: 'BAF RTS Canteen - ${summary.staff.rank} ${summary.staff.name} (${summary.staff.bdNo})',
      author: 'Bangladesh Air Force RTS Canteen',
    );

    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final dateFormat = DateFormat('dd-MM-yyyy');
    final dayNameFormat = DateFormat('EEEE');
    final monthName = monthNames[month - 1];

    pw.MemoryImage? crestImage;
    try {
      final crestData = await rootBundle.load('assets/images/baf_logo.png');
      crestImage = pw.MemoryImage(crestData.buffer.asUint8List());
    } catch (_) {
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
              // Header
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
                            'FOOD CANTEEN • PERMANENT STAFF (P-STAFF) MONTHLY STATEMENT',
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
                            summary.staff.bdNo,
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

              // Staff Metadata
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: lightBlueBg,
                  border: pw.Border.all(color: borderGrey, width: 0.8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPdfMeta('STAFF NAME', '${summary.staff.rank} ${summary.staff.name}'),
                    _buildPdfMeta('BD NUMBER', summary.staff.bdNo),
                    _buildPdfMeta('OFFICE / SECTION', summary.staff.office),
                    _buildPdfMeta('PERIOD', '${monthName.toUpperCase()} $year'),
                    _buildPdfMeta('CANTEEN VISITS', '${summary.activeDaysCount} Days'),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // Ledger Table (Items consumed column removed)
              pw.Table(
                border: pw.TableBorder.all(color: borderGrey, width: 0.5),
                columnWidths: const {
                  0: pw.FixedColumnWidth(28),
                  1: pw.FixedColumnWidth(68),
                  2: pw.FixedColumnWidth(68),
                  3: pw.FlexColumnWidth(2.5),
                  4: pw.FixedColumnWidth(65),
                  5: pw.FixedColumnWidth(75),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: navyColor),
                    children: [
                      _buildPdfCell('DAY', isHeader: true, align: pw.TextAlign.center),
                      _buildPdfCell('DATE', isHeader: true, align: pw.TextAlign.center),
                      _buildPdfCell('WEEKDAY', isHeader: true, align: pw.TextAlign.center),
                      _buildPdfCell('DUTY IN-CHARGE', isHeader: true),
                      _buildPdfCell('STAFF SIGN', isHeader: true, align: pw.TextAlign.center),
                      _buildPdfCell('PRICE (TK)', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
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
                          dayNameFormat.format(record.date),
                          align: pw.TextAlign.center,
                          fontSize: 7.5,
                        ),
                        _buildPdfCell(
                          hasSpent ? record.recordedBy : '—',
                          fontSize: 7.5,
                          color: hasSpent ? PdfColors.black : PdfColors.grey700,
                        ),
                        _buildPdfCell(
                          hasSpent ? 'Recorded' : '—',
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

                  // Subtotals
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightBlueBg),
                    children: [
                      _buildPdfCell(''),
                      _buildPdfCell('1. MONTH TOTAL', isBold: true, fontSize: 8),
                      _buildPdfCell(''),
                      _buildPdfCell('Current month total canteen price', fontSize: 7.5),
                      _buildPdfCell('AUDITED', align: pw.TextAlign.center, fontSize: 7),
                      _buildPdfCell('Tk ${currencyFormat.format(summary.totalMonthlySpending)}', align: pw.TextAlign.right, isBold: true, fontSize: 8.5),
                    ],
                  ),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      _buildPdfCell(''),
                      _buildPdfCell('2. PREVIOUS DUE', isBold: true, fontSize: 8, color: redDebit),
                      _buildPdfCell(''),
                      _buildPdfCell('Arrears carried forward from prior month', fontSize: 7.5),
                      _buildPdfCell('CONFIRMED', align: pw.TextAlign.center, fontSize: 7),
                      _buildPdfCell('Tk ${currencyFormat.format(summary.preDue)}', align: pw.TextAlign.right, isBold: true, fontSize: 8.5, color: redDebit),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightBlueBg),
                    children: [
                      _buildPdfCell(''),
                      _buildPdfCell('3. GROSS TOTAL', isBold: true, fontSize: 8.5),
                      _buildPdfCell(''),
                      _buildPdfCell('Gross liability (Pre Due + Current Month)', isBold: true, fontSize: 7.5),
                      _buildPdfCell('VERIFIED', align: pw.TextAlign.center, fontSize: 7),
                      _buildPdfCell('Tk ${currencyFormat.format(summary.grandTotal)}', align: pw.TextAlign.right, isBold: true, fontSize: 9),
                    ],
                  ),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      _buildPdfCell(''),
                      _buildPdfCell('4. LESS: PAID', isBold: true, fontSize: 8, color: greenCredit),
                      _buildPdfCell(''),
                      _buildPdfCell('Random payments collected during month', fontSize: 7.5, color: greenCredit),
                      _buildPdfCell('RECEIPTED', align: pw.TextAlign.center, fontSize: 7),
                      _buildPdfCell('Tk ${currencyFormat.format(summary.paid)}', align: pw.TextAlign.right, isBold: true, fontSize: 8.5, color: greenCredit),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: navyColor),
                    children: [
                      _buildPdfCell('', isHeader: true),
                      _buildPdfCell('5. EFFECTIVE BILL', isHeader: true, isBold: true, fontSize: 8.5),
                      _buildPdfCell('', isHeader: true),
                      _buildPdfCell('Net effective bill payable at month end', isHeader: true, fontSize: 7.5),
                      _buildPdfCell(summary.effectiveBill <= 0 ? 'CLEARED' : 'PENDING', isHeader: true, align: pw.TextAlign.center, fontSize: 7),
                      _buildPdfCell('Tk ${currencyFormat.format(summary.effectiveBill)}', isHeader: true, align: pw.TextAlign.right, isBold: true, fontSize: 9.5, color: goldColor),
                    ],
                  ),
                ],
              ),

              if (summary.payments.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: navyColor,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'RANDOM PAYMENTS LOGGED (DATES & AMOUNTS)',
                        style: pw.TextStyle(color: goldColor, fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'TOTAL PAID: Tk ${currencyFormat.format(summary.paid)}',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                pw.Table(
                  border: pw.TableBorder.all(color: borderGrey, width: 0.5),
                  columnWidths: const {
                    0: pw.FixedColumnWidth(70),
                    1: pw.FlexColumnWidth(3.0),
                    2: pw.FixedColumnWidth(75),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: lightBlueBg),
                      children: [
                        _buildPdfCell('PAYMENT DATE', isBold: true, fontSize: 7.5),
                        _buildPdfCell('RECEIPT / REMARKS', isBold: true, fontSize: 7.5),
                        _buildPdfCell('AMOUNT PAID (TK)', isBold: true, align: pw.TextAlign.right, fontSize: 7.5),
                      ],
                    ),
                    ...summary.payments.map((p) => pw.TableRow(
                      children: [
                        _buildPdfCell(dateFormat.format(p.date), fontSize: 7.5),
                        _buildPdfCell(p.receiptNote ?? 'Cash received towards canteen ledger', fontSize: 7.5),
                        _buildPdfCell('Tk ${currencyFormat.format(p.amount)}', align: pw.TextAlign.right, isBold: true, fontSize: 7.5, color: greenCredit),
                      ],
                    )),
                  ],
                ),
              ],

              pw.Spacer(),

              // Sign-off
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 14),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPdfSignature('INDIVIDUAL STAFF', summary.staff.rank, summary.staff.bdNo),
                    _buildPdfSignature('NCOIC (CANTEEN)', 'Sergeant (Sgt)', 'RTS BAF'),
                    _buildPdfSignature('JCOIC (CANTEEN)', 'Warrant Officer (WO)', 'RTS BAF'),
                    _buildPdfSignature('COUNTERSIGNED (OC)', 'Officer Commanding', 'RTS (BAF)'),
                  ],
                ),
              ),

              pw.SizedBox(height: 4),

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

  static Future<Uint8List> generatePStaffMonthlyMatrixPdf({
    required List<PStaffProfile> staffList,
    required String office,
    required int year,
    required int month,
    required Map<String, Map<int, double>> expensesMap,
    required double totalPreDue,
    required double totalMonthExpenses,
    required double totalPaid,
    required double totalNetDue,
  }) async {
    final pdf = pw.Document(
      title: 'BAF RTS Canteen - P-Staff Monthly Matrix ($office - ${monthNames[month - 1]} $year)',
      author: 'Bangladesh Air Force RTS Canteen',
    );

    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final monthName = monthNames[month - 1];
    final daysInMonth = DateTime(year, month + 1, 0).day;

    pw.MemoryImage? crestImage;
    try {
      final crestData = await rootBundle.load('assets/images/baf_crest.png');
      crestImage = pw.MemoryImage(crestData.buffer.asUint8List());
    } catch (_) {
      try {
        final crestData = await rootBundle.load('assets/images/baf_logo.png');
        crestImage = pw.MemoryImage(crestData.buffer.asUint8List());
      } catch (_) {
        crestImage = null;
      }
    }

    final navyColor = PdfColor.fromHex('#001F3F');
    final deepBlue = PdfColor.fromHex('#0B3C5D');
    final goldColor = PdfColor.fromHex('#D4AF37');
    final lightBlueBg = PdfColor.fromHex('#EAF2F8');
    final stripeBg = PdfColor.fromHex('#F4F6F9');
    final borderGrey = PdfColor.fromHex('#BDC3C7');
    final redDebit = PdfColor.fromHex('#C0392B');
    final greenCredit = PdfColor.fromHex('#27AE60');

    final dayWidth = daysInMonth == 31 ? 13.0 : (daysInMonth == 30 ? 13.5 : 14.5);
    final Map<int, pw.TableColumnWidth> colWidths = {
      0: const pw.FixedColumnWidth(16),
      1: const pw.FixedColumnWidth(44),
      2: const pw.FixedColumnWidth(80),
      3: const pw.FixedColumnWidth(42),
      4: const pw.FixedColumnWidth(36),
    };
    for (int d = 1; d <= daysInMonth; d++) {
      colWidths[4 + d] = pw.FixedColumnWidth(dayWidth);
    }
    colWidths[5 + daysInMonth] = const pw.FixedColumnWidth(40);
    colWidths[6 + daysInMonth] = const pw.FixedColumnWidth(40);
    colWidths[7 + daysInMonth] = const pw.FixedColumnWidth(38);
    colWidths[8 + daysInMonth] = const pw.FixedColumnWidth(42);

    final Map<int, double> dayTotals = {};
    for (int d = 1; d <= daysInMonth; d++) {
      double sum = 0.0;
      for (final staff in staffList) {
        sum += expensesMap[staff.id]?[d] ?? 0.0;
      }
      dayTotals[d] = sum;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: navyColor,
                  border: pw.Border.all(color: goldColor, width: 1.5),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (crestImage != null)
                      pw.Container(
                        width: 40,
                        height: 40,
                        margin: const pw.EdgeInsets.only(right: 10),
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
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            'RECRUITS TRAINING SCHOOL (RTS)',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            'FOOD CANTEEN • PERMANENT STAFF (P-STAFF) MONTHLY EXPENDITURE MATRIX',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 8,
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
                            'OFFICE: $office',
                            style: pw.TextStyle(
                              color: goldColor,
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '${monthName.toUpperCase()} $year',
                            style: const pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 8,
                            ),
                          ),
                          pw.Text(
                            'STRENGTH: ${staffList.length} STAFF',
                            style: const pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: stripeBg,
                  border: pw.Border.all(color: borderGrey, width: 0.7),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPdfMeta('1. PREVIOUS DUE', 'Tk ${currencyFormat.format(totalPreDue)}'),
                    _buildPdfMeta('2. MONTH CONSUMPTION', 'Tk ${currencyFormat.format(totalMonthExpenses)}'),
                    _buildPdfMeta('3. GROSS TOTAL', 'Tk ${currencyFormat.format(totalPreDue + totalMonthExpenses)}'),
                    _buildPdfMeta('4. TOTAL PAID / DEPOSIT', 'Tk ${currencyFormat.format(totalPaid)}'),
                    _buildPdfMeta('5. NET DUE / BALANCE', 'Tk ${currencyFormat.format(totalNetDue)}'),
                  ],
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Expanded(
                child: pw.Table(
                  border: pw.TableBorder.all(color: borderGrey, width: 0.4),
                  columnWidths: colWidths,
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: navyColor),
                      children: [
                        _buildPdfCell('SL', isHeader: true, align: pw.TextAlign.center, fontSize: 6.5, padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell('BD NO', isHeader: true, fontSize: 6.5, padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell('RANK & NAME', isHeader: true, fontSize: 6.5, padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell('OFFICE', isHeader: true, fontSize: 6.5, padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell('PRE DUE', isHeader: true, align: pw.TextAlign.right, fontSize: 6.5, padding: const pw.EdgeInsets.all(2)),
                        ...List.generate(daysInMonth, (d) =>
                          _buildPdfCell('${d + 1}', isHeader: true, align: pw.TextAlign.center, fontSize: 6.0, padding: const pw.EdgeInsets.all(1))
                        ),
                        _buildPdfCell('MONTH', isHeader: true, align: pw.TextAlign.right, fontSize: 6.5, padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell('TOTAL', isHeader: true, align: pw.TextAlign.right, fontSize: 6.5, padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell('PAID', isHeader: true, align: pw.TextAlign.right, fontSize: 6.5, padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell('NET DUE', isHeader: true, align: pw.TextAlign.right, fontSize: 6.5, padding: const pw.EdgeInsets.all(2)),
                      ],
                    ),

                    ...staffList.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final staff = entry.value;
                      final staffDays = expensesMap[staff.id] ?? {};
                      double monthExp = 0.0;
                      for (final amt in staffDays.values) {
                        monthExp += amt;
                      }
                      final grandTotal = staff.preDue + monthExp;
                      final netDue = grandTotal - staff.paid;
                      final isEven = idx % 2 == 0;
                      final rowBg = isEven ? stripeBg : PdfColors.white;

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(color: rowBg),
                        children: [
                          _buildPdfCell('${idx + 1}', align: pw.TextAlign.center, fontSize: 6.5, padding: const pw.EdgeInsets.all(2)),
                          _buildPdfCell(staff.bdNo, fontSize: 6.5, isBold: true, padding: const pw.EdgeInsets.all(2)),
                          _buildPdfCell('${staff.rank} ${staff.name}', fontSize: 6.5, padding: const pw.EdgeInsets.all(2)),
                          _buildPdfCell(staff.office, fontSize: 6.0, padding: const pw.EdgeInsets.all(2)),
                          _buildPdfCell(staff.preDue > 0 ? staff.preDue.toStringAsFixed(0) : '-', align: pw.TextAlign.right, fontSize: 6.5, color: staff.preDue > 0 ? redDebit : PdfColors.grey700, padding: const pw.EdgeInsets.all(2)),
                          ...List.generate(daysInMonth, (d) {
                            final amt = staffDays[d + 1] ?? 0.0;
                            return _buildPdfCell(
                              amt > 0 ? amt.toStringAsFixed(0) : '-',
                              align: pw.TextAlign.center,
                              fontSize: 6.0,
                              isBold: amt > 0,
                              color: amt > 0 ? PdfColors.black : PdfColors.grey500,
                              padding: const pw.EdgeInsets.all(1),
                            );
                          }),
                          _buildPdfCell(monthExp > 0 ? monthExp.toStringAsFixed(0) : '0', align: pw.TextAlign.right, fontSize: 6.5, isBold: true, color: redDebit, padding: const pw.EdgeInsets.all(2)),
                          _buildPdfCell(grandTotal > 0 ? grandTotal.toStringAsFixed(0) : '0', align: pw.TextAlign.right, fontSize: 6.5, isBold: true, padding: const pw.EdgeInsets.all(2)),
                          _buildPdfCell(staff.paid > 0 ? staff.paid.toStringAsFixed(0) : '-', align: pw.TextAlign.right, fontSize: 6.5, color: greenCredit, padding: const pw.EdgeInsets.all(2)),
                          _buildPdfCell(
                            netDue.toStringAsFixed(0),
                            align: pw.TextAlign.right,
                            fontSize: 7.0,
                            isBold: true,
                            color: netDue > 0 ? redDebit : greenCredit,
                            padding: const pw.EdgeInsets.all(2),
                          ),
                        ],
                      );
                    }),

                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: lightBlueBg),
                      children: [
                        _buildPdfCell('', padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell('TOTAL', fontSize: 7.0, isBold: true, color: navyColor, padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell('${staffList.length} Personnel', fontSize: 6.5, isBold: true, color: navyColor, padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell('', padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell(totalPreDue > 0 ? totalPreDue.toStringAsFixed(0) : '0', align: pw.TextAlign.right, fontSize: 6.5, isBold: true, color: redDebit, padding: const pw.EdgeInsets.all(2)),
                        ...List.generate(daysInMonth, (d) {
                          final daySum = dayTotals[d + 1] ?? 0.0;
                          return _buildPdfCell(
                            daySum > 0 ? daySum.toStringAsFixed(0) : '-',
                            align: pw.TextAlign.center,
                            fontSize: 6.0,
                            isBold: true,
                            color: daySum > 0 ? navyColor : PdfColors.grey500,
                            padding: const pw.EdgeInsets.all(1),
                          );
                        }),
                        _buildPdfCell(totalMonthExpenses.toStringAsFixed(0), align: pw.TextAlign.right, fontSize: 7.0, isBold: true, color: redDebit, padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell((totalPreDue + totalMonthExpenses).toStringAsFixed(0), align: pw.TextAlign.right, fontSize: 7.0, isBold: true, color: navyColor, padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell(totalPaid.toStringAsFixed(0), align: pw.TextAlign.right, fontSize: 7.0, isBold: true, color: greenCredit, padding: const pw.EdgeInsets.all(2)),
                        _buildPdfCell(
                          totalNetDue.toStringAsFixed(0),
                          align: pw.TextAlign.right,
                          fontSize: 7.5,
                          isBold: true,
                          color: totalNetDue > 0 ? redDebit : greenCredit,
                          padding: const pw.EdgeInsets.all(2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 6),

              pw.Container(
                padding: const pw.EdgeInsets.only(top: 8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPdfSignature('PREPARED BY', 'Canteen Accounting Clerk', 'RTS Food Canteen'),
                    _buildPdfSignature('VERIFIED BY (NCOIC)', 'Cpl Shanjid Ahmad (472770)', 'E&I Fitter • RTS BAF'),
                    _buildPdfSignature('SUPERVISED BY (JCOIC)', 'Master Warrant Officer', 'RTS Food Canteen'),
                    _buildPdfSignature('COUNTERSIGNED (OC)', 'Officer Commanding', 'RTS, Bangladesh Air Force'),
                  ],
                ),
              ),

              pw.SizedBox(height: 3),

              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'SECURITY CLASSIFICATION: OFFICIAL USE ONLY • RECRUITS TRAINING SCHOOL (RTS) • BANGLADESH AIR FORCE',
                  style: const pw.TextStyle(fontSize: 6.0, color: PdfColors.grey700),
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
    pw.EdgeInsets? padding,
  }) {
    return pw.Padding(
      padding: padding ?? const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3.5),
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
