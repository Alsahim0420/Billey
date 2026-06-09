import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../l10n/app_localizations.dart';
import '../l10n/localization_helpers.dart';
import '../models/transaction.dart';
import '../providers/currency_provider.dart';

enum ExportFormat { csv, pdf }

enum ExportScope { all, expensesOnly, incomeOnly }

class ExportOptions {
  const ExportOptions({
    required this.format,
    required this.scope,
  });

  final ExportFormat format;
  final ExportScope scope;
}

class ExportFileResult {
  const ExportFileResult({
    required this.file,
    required this.fileName,
  });

  final File file;
  final String fileName;
}

class _PdfPalette {
  static final primary = PdfColor.fromInt(0xFF1FAD98);
  static final primaryDark = PdfColor.fromInt(0xFF168675);
  static final income = PdfColor.fromInt(0xFF1FAD98);
  static final expense = PdfColor.fromInt(0xFFFF6B6B);
  static final textPrimary = PdfColor.fromInt(0xFF111827);
  static final textSecondary = PdfColor.fromInt(0xFF6B7280);
  static final backgroundAlt = PdfColor.fromInt(0xFFF3F4F6);
  static final white = PdfColor.fromInt(0xFFFFFFFF);
}

class TransactionExportService {
  static List<TransactionModel> filterTransactions(
    List<TransactionModel> transactions,
    ExportScope scope,
  ) {
    return switch (scope) {
      ExportScope.all => List<TransactionModel>.from(transactions),
      ExportScope.expensesOnly => transactions
          .where((transaction) => transaction.type == TransactionType.gasto)
          .toList(),
      ExportScope.incomeOnly => transactions
          .where((transaction) => transaction.type == TransactionType.ingreso)
          .toList(),
    };
  }

  static Future<ExportFileResult> export({
    required List<TransactionModel> transactions,
    required ExportOptions options,
    required AppLocalizations l10n,
    required CurrencyProvider currency,
    required String userDisplayName,
  }) async {
    final filtered = filterTransactions(transactions, options.scope);
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return switch (options.format) {
      ExportFormat.csv => _exportCsv(
          filtered,
          l10n,
          currency,
          userDisplayName,
        ),
      ExportFormat.pdf => _exportPdf(
          filtered,
          l10n,
          currency,
          options.scope,
          userDisplayName,
        ),
    };
  }

  static String exportFileName({
    required String userDisplayName,
    required DateTime generatedAt,
    required String locale,
    required String fallbackUserName,
    required String extension,
  }) {
    final safeName = _sanitizeFileSegment(userDisplayName);
    final userSegment =
        safeName.isEmpty ? _sanitizeFileSegment(fallbackUserName) : safeName;
    final resolvedUser = userSegment.isEmpty ? 'usuario' : userSegment;
    final timestamp = DateFormat('yyyy-MM-dd HH-mm', locale).format(generatedAt);
    return 'resumen billey $resolvedUser $timestamp.$extension';
  }

  static String _sanitizeFileSegment(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static Future<ExportFileResult> _exportCsv(
    List<TransactionModel> transactions,
    AppLocalizations l10n,
    CurrencyProvider currency,
    String userDisplayName,
  ) async {
    final locale = currency.selectedCurrency.locale;
    final generatedAt = DateTime.now();
    final fileName = exportFileName(
      userDisplayName: userDisplayName,
      generatedAt: generatedAt,
      locale: locale,
      fallbackUserName: l10n.defaultUser,
      extension: 'csv',
    );

    final rows = <List<dynamic>>[
      l10n.csvHeaders.split(', '),
      ...transactions.map(
        (transaction) => _transactionRow(transaction, l10n, currency),
      ),
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/$fileName').writeAsString(
      '\uFEFF$csvData',
    );
    return ExportFileResult(file: file, fileName: fileName);
  }

  static Future<ExportFileResult> _exportPdf(
    List<TransactionModel> transactions,
    AppLocalizations l10n,
    CurrencyProvider currency,
    ExportScope scope,
    String userDisplayName,
  ) async {
    final locale = currency.selectedCurrency.locale;
    final generatedAt = DateTime.now();
    final generatedAtLabel =
        DateFormat.yMMMd(locale).add_jm().format(generatedAt);
    final incomeTotal = transactions
        .where((transaction) => transaction.type == TransactionType.ingreso)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    final expenseTotal = transactions
        .where((transaction) => transaction.type == TransactionType.gasto)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);

    final logoBytes = (await rootBundle.load('icono.png')).buffer.asUint8List();
    final logo = pw.MemoryImage(logoBytes);
    final resolvedUserName = userDisplayName.trim().isEmpty
        ? l10n.defaultUser
        : userDisplayName.trim();
    final fileName = exportFileName(
      userDisplayName: userDisplayName,
      generatedAt: generatedAt,
      locale: locale,
      fallbackUserName: l10n.defaultUser,
      extension: 'pdf',
    );

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        build: (context) {
          return [
            _pdfHeader(
              logo: logo,
              userName: resolvedUserName,
              generatedAt: generatedAtLabel,
              scopeLabel: _scopeLabel(l10n, scope),
              title: l10n.exportPdfTitle,
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _summaryBox(
                  label: l10n.exportPdfSummaryIncome,
                  value: _pdfAmount(currency, incomeTotal),
                  accent: _PdfPalette.income,
                ),
                pw.SizedBox(width: 10),
                _summaryBox(
                  label: l10n.exportPdfSummaryExpenses,
                  value: _pdfAmount(currency, expenseTotal),
                  accent: _PdfPalette.expense,
                ),
                pw.SizedBox(width: 10),
                _summaryBox(
                  label: l10n.exportPdfSummaryCount,
                  value: '${transactions.length}',
                  accent: _PdfPalette.primaryDark,
                ),
              ],
            ),
            pw.SizedBox(height: 22),
            if (transactions.isEmpty)
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: _PdfPalette.backgroundAlt,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(
                  l10n.exportNoData,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: _PdfPalette.textSecondary,
                  ),
                ),
              )
            else
              _transactionsTable(transactions, l10n, currency),
          ];
        },
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey300, width: 0.6),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.SizedBox(
                    width: 22,
                    height: 22,
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'Billey',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: _PdfPalette.primary,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Text(
                '${context.pageNumber}/${context.pagesCount}',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: _PdfPalette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final bytes = await doc.save();
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/$fileName').writeAsBytes(bytes);
    return ExportFileResult(file: file, fileName: fileName);
  }

  /// Montos en ASCII para que Helvetica del PDF los renderice siempre.
  static String _pdfAmount(CurrencyProvider currency, double amount) {
    final symbol = _pdfSafeText(currency.selectedCurrency.symbol);
    final value = _pdfSafeText(currency.formatValue(amount));
    return '$symbol $value';
  }

  static String _pdfSafeText(String input) {
    return input
        .replaceAll(RegExp(r'[\u00A0\u202F\u2009\u2007]'), ' ')
        .trim();
  }

  static pw.Widget _pdfHeader({
    required pw.MemoryImage logo,
    required String userName,
    required String generatedAt,
    required String scopeLabel,
    required String title,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: pw.BoxDecoration(
            color: _PdfPalette.primary,
            borderRadius: pw.BorderRadius.circular(16),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.ClipRRect(
                horizontalRadius: 14,
                verticalRadius: 14,
                child: pw.SizedBox(
                  width: 72,
                  height: 72,
                  child: pw.Image(logo, fit: pw.BoxFit.cover),
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Billey',
                      style: pw.TextStyle(
                        color: _PdfPalette.white,
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        color: _PdfPalette.white,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      userName,
                      style: pw.TextStyle(
                        color: _PdfPalette.white,
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      _pdfSafeText(generatedAt),
                      style: pw.TextStyle(
                        color: _PdfPalette.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: pw.BoxDecoration(
            color: _PdfPalette.primaryDark,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Text(
            scopeLabel,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: _PdfPalette.white,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _summaryBox({
    required String label,
    required String value,
    required PdfColor accent,
  }) {
    return pw.Expanded(
      child: pw.Container(
        height: 92,
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: pw.BoxDecoration(
          color: accent,
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              maxLines: 2,
              style: pw.TextStyle(
                fontSize: 9,
                color: _PdfPalette.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.FittedBox(
              alignment: pw.Alignment.centerLeft,
              fit: pw.BoxFit.scaleDown,
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: _PdfPalette.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _transactionsTable(
    List<TransactionModel> transactions,
    AppLocalizations l10n,
    CurrencyProvider currency,
  ) {
    final headers = l10n.csvHeaders.split(', ');

    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(
          color: _PdfPalette.backgroundAlt,
          width: 0.8,
        ),
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(0.9),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.3),
        4: const pw.FlexColumnWidth(0.9),
        5: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: _PdfPalette.primary,
            borderRadius: const pw.BorderRadius.vertical(
              top: pw.Radius.circular(10),
            ),
          ),
          children: headers
              .map(
                (header) => _tableCell(
                  header,
                  isHeader: true,
                ),
              )
              .toList(),
        ),
        ...transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          final row = _transactionRow(transaction, l10n, currency);
          final background =
              index.isEven ? _PdfPalette.white : _PdfPalette.backgroundAlt;

          return pw.TableRow(
            decoration: pw.BoxDecoration(color: background),
            children: [
              _tableCell(row[0]),
              _tableCell(
                row[1],
                color: transaction.type == TransactionType.ingreso
                    ? _PdfPalette.income
                    : _PdfPalette.expense,
                fontWeight: pw.FontWeight.bold,
              ),
              _tableCell(row[2]),
              _tableCell(row[3]),
              _tableCell(
                row[4],
                align: pw.TextAlign.right,
                fontWeight: pw.FontWeight.bold,
                color: transaction.type == TransactionType.ingreso
                    ? _PdfPalette.income
                    : _PdfPalette.expense,
              ),
              _tableCell(row[5]),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _tableCell(
    String text, {
    bool isHeader = false,
    PdfColor? color,
    pw.FontWeight fontWeight = pw.FontWeight.normal,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8.5,
          fontWeight: isHeader ? pw.FontWeight.bold : fontWeight,
          color: isHeader ? _PdfPalette.white : (color ?? _PdfPalette.textPrimary),
        ),
      ),
    );
  }

  static List<String> _transactionRow(
    TransactionModel transaction,
    AppLocalizations l10n,
    CurrencyProvider currency,
  ) {
    final locale = currency.selectedCurrency.locale;
    final date = DateFormat.yMMMd(locale).format(transaction.date);

    return [
      date,
      transaction.type.localizedExportName(l10n),
      transaction.category.localizedName(l10n),
      transaction.title,
      _pdfAmount(currency, transaction.amount),
      transaction.description ?? '',
    ];
  }

  static String _scopeLabel(AppLocalizations l10n, ExportScope scope) {
    return switch (scope) {
      ExportScope.all => l10n.exportContentAll,
      ExportScope.expensesOnly => l10n.exportContentExpenses,
      ExportScope.incomeOnly => l10n.exportContentIncome,
    };
  }
}

extension TransactionTypeExportL10n on TransactionType {
  String localizedExportName(AppLocalizations l10n) {
    return switch (this) {
      TransactionType.ingreso => l10n.transactionTypeIncome,
      TransactionType.gasto => l10n.transactionTypeExpense,
    };
  }
}
