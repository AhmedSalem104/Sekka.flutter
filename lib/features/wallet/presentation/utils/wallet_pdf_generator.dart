import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/wallet_balance_entity.dart';
import '../../domain/entities/wallet_summary_entity.dart';

class WalletPdfGenerator {
  const WalletPdfGenerator._();

  static Future<void> generateAndShare({
    required WalletBalanceEntity balance,
    required WalletSummaryEntity summary,
    required List<TransactionEntity> transactions,
  }) async {
    final font = await _loadArabicFont();
    final logoData = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    final pdf = pw.Document();

    final isAr = AppStrings.currentLang == 'ar';
    final textDir = isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final currSymbol = isAr ? 'ج' : 'EGP';

    final now = DateTime.now();
    final dateStr = '${now.day}-${now.month}-${now.year}';

    final baseStyle = pw.TextStyle(font: font, fontSize: 14);
    final headStyle = pw.TextStyle(
      font: font,
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
    );
    final titleStyle = pw.TextStyle(
      font: font,
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
    );
    final dateStyle = pw.TextStyle(
      font: font,
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
    );
    final labelStyle = pw.TextStyle(
      font: font,
      fontSize: 13,
      color: PdfColors.grey700,
    );
    final bigValueStyle = pw.TextStyle(
      font: font,
      fontSize: 28,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.orange,
    );

    final recentTx = transactions.take(15).toList();

    pdf.addPage(
      pw.Page(
        textDirection: textDir,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Logo + Date
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Image(logoImage, width: 100, height: 100),
                pw.Text(dateStr, style: dateStyle),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Center(
              child: pw.Text(AppStrings.pdfWalletSummaryTitle, style: titleStyle),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.orange),
            pw.SizedBox(height: 20),

            // Main balance
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    AppStrings.pdfMoneyWithYou,
                    style: labelStyle,
                    textDirection: textDir,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${summary.netBalance.toStringAsFixed(0)} $currSymbol',
                    style: bigValueStyle,
                    textDirection: textDir,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary
            _row(font, AppStrings.pdfTotalEarned, '${summary.totalEarnings.toStringAsFixed(0)} $currSymbol', textDir),
            _row(font, AppStrings.pdfTotalSettled, '${summary.totalSettlements.toStringAsFixed(0)} $currSymbol', textDir),
            _row(font, AppStrings.pdfPendingPartners, '${balance.pendingSettlements.toStringAsFixed(0)} $currSymbol', textDir),
            _row(font, AppStrings.pdfTransactionCount, '${summary.transactionCount}', textDir),
            pw.SizedBox(height: 24),

            // Recent transactions
            if (recentTx.isNotEmpty) ...[
              pw.Text(AppStrings.pdfRecentTransactions, style: headStyle),
              pw.SizedBox(height: 8),
              ...recentTx.map(
                (t) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          t.description,
                          style: baseStyle,
                          textDirection: textDir,
                          maxLines: 1,
                        ),
                      ),
                      pw.Text(
                        '${t.amount > 0 ? '+' : ''}${t.amount.toStringAsFixed(0)} $currSymbol',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: t.amount > 0
                              ? PdfColors.green
                              : PdfColors.red,
                        ),
                        textDirection: textDir,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            pw.Spacer(),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                AppStrings.pdfGeneratedBy,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                  color: PdfColors.grey500,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/sekka_wallet_$dateStr.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '${AppStrings.pdfShareText} — $dateStr',
      ),
    );
  }

  static pw.Widget _row(pw.Font font, String label, String value, pw.TextDirection textDir) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 13,
              color: PdfColors.grey700,
            ),
            textDirection: textDir,
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: textDir,
          ),
        ],
      ),
    );
  }

  static Future<pw.Font> _loadArabicFont() async {
    final data = await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    return pw.Font.ttf(data);
  }
}
