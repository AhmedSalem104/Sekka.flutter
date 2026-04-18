import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/daily_settlement_summary_entity.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../../partners/data/models/partner_model.dart';
import '../../domain/entities/partner_balance_entity.dart';

/// Generates a daily settlement summary PDF and opens the system share sheet.
class SettlementPdfGenerator {
  const SettlementPdfGenerator._();

  static Future<void> generateAndShare({
    required DailySettlementSummaryEntity summary,
    required List<SettlementEntity> todaySettlements,
    required List<PartnerModel> unsettledPartners,
    required Map<String, PartnerBalanceEntity> balances,
  }) async {
    final font = await _loadArabicFont();
    final logoData = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    final pdf = pw.Document();

    final baseStyle = pw.TextStyle(font: font, fontSize: 16);
    final headStyle = pw.TextStyle(
      font: font,
      fontSize: 22,
      fontWeight: pw.FontWeight.bold,
    );
    final titleStyle = pw.TextStyle(
      font: font,
      fontSize: 26,
      fontWeight: pw.FontWeight.bold,
    );
    final dateStyle = pw.TextStyle(
      font: font,
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
    );
    final labelStyle = pw.TextStyle(font: font, fontSize: 15, color: PdfColors.grey700);
    final valueStyle = pw.TextStyle(
      font: font,
      fontSize: 17,
      fontWeight: pw.FontWeight.bold,
    );

    final now = DateTime.now();
    final dateStr = '${now.day}-${now.month}-${now.year}';

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Logo (right) + Date (left)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Image(logoImage, width: 120, height: 120),
                pw.Text(dateStr, style: dateStyle),
              ],
            ),
            pw.SizedBox(height: 12),

            // Title
            pw.Center(
              child: pw.Text('سِكّة — ملخص اليوم', style: titleStyle),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.orange),
            pw.SizedBox(height: 16),

            // Summary stats
            _row(font, 'جمعت من العملاء', '${summary.totalCollected.toStringAsFixed(0)} ج'),
            _row(font, 'سلّمت للشركاء', '${summary.totalSettled.toStringAsFixed(0)} ج'),
            _row(font, 'باقي معاك', '${summary.remainingBalance.toStringAsFixed(0)} ج'),
            _row(font, 'عدد التسليمات', '${summary.settlementCount}'),
            pw.SizedBox(height: 20),

            // Today's settlements
            if (todaySettlements.isNotEmpty) ...[
              pw.Text('التسليمات النهاردا', style: headStyle),
              pw.SizedBox(height: 8),
              ...todaySettlements.map(
                (s) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          '• ${s.partnerName ?? 'شريك'}',
                          style: baseStyle,
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ),
                      pw.Text(
                        '${s.amount.toStringAsFixed(0)} ج (${_typeName(s.settlementType)})',
                        style: valueStyle,
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
            ],

            // Unsettled partners
            if (unsettledPartners.isNotEmpty) ...[
              pw.Text('الشركاء اللي عليك', style: headStyle),
              pw.SizedBox(height: 8),
              ...unsettledPartners.map((p) {
                final b = balances[p.id];
                final amount = b?.pendingBalance ?? 0;
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          '• ${p.name}',
                          style: baseStyle,
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ),
                      pw.Text(
                        '${amount.toStringAsFixed(0)} ج',
                        style: valueStyle,
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                );
              }),
            ],

            pw.Spacer(),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'تم الإنشاء من تطبيق سِكّة',
                style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey500),
              ),
            ),
          ],
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/sekka_summary_$dateStr.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'ملخص سِكّة — $dateStr',
      ),
    );
  }

  static pw.Widget _row(pw.Font font, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(font: font, fontSize: 15, color: PdfColors.grey700),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            value,
            style: pw.TextStyle(font: font, fontSize: 17, fontWeight: pw.FontWeight.bold),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  static String _typeName(int type) => switch (type) {
        0 => 'كاش',
        1 => 'بنكي',
        2 => 'فودافون',
        3 => 'إنستاباي',
        4 => 'فوري',
        _ => 'أخرى',
      };

  static Future<pw.Font> _loadArabicFont() async {
    final data = await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    return pw.Font.ttf(data);
  }
}
