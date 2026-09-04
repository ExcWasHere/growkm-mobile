import 'dart:typed_data';
class ReceiptImageUpload {
  final String fileName;
  final String contentType;
  final Uint8List bytes;

  const ReceiptImageUpload({required this.fileName, required this.contentType, required this.bytes});
}

enum TransactionType { income, expense }

extension TransactionTypeX on TransactionType {
  String get wireValue => this == TransactionType.income ? 'income' : 'expense';
  String get label => this == TransactionType.income ? 'Pemasukan' : 'Pengeluaran';

  static TransactionType fromWire(String? value) {
    return value == 'expense' ? TransactionType.expense : TransactionType.income;
  }
}

class Transaction {
  final String id;
  final TransactionType type;
  final String? category;
  final String? productName;
  final int amount;
  final int? quantity;
  final int? unitPrice;
  final String recordDate;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.recordDate,
    required this.createdAt,
    this.category,
    this.productName,
    this.quantity,
    this.unitPrice,
  });

  String get displayLabel => productName ?? category ?? type.label;
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String? ?? '',
      type: TransactionTypeX.fromWire(json['type'] as String?),
      category: json['category'] as String?,
      productName: json['product_name'] as String?,
      amount: json['amount'] as int? ?? 0,
      quantity: json['quantity'] as int?,
      unitPrice: json['unit_price'] as int?,
      recordDate: json['record_date'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class DailySummary {
  final int income;
  final int expense;
  final int profit;
  final double marginPct;

  const DailySummary({required this.income, required this.expense, required this.profit, required this.marginPct});

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      income: json['income'] as int? ?? 0,
      expense: json['expense'] as int? ?? 0,
      profit: json['profit'] as int? ?? 0,
      marginPct: (json['margin_pct'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RecordTransactionResult {
  final String aiResponse;
  final List<Transaction> transactions;
  final DailySummary dailySummary;
  final int streakDays;

  const RecordTransactionResult({
    required this.aiResponse,
    required this.transactions,
    required this.dailySummary,
    required this.streakDays,
  });

  factory RecordTransactionResult.fromJson(Map<String, dynamic> json) {
    final txJson = json['transactions'] as List<dynamic>? ?? [];
    return RecordTransactionResult(
      aiResponse: json['ai_response'] as String? ?? '',
      transactions: txJson.map((t) => Transaction.fromJson(t as Map<String, dynamic>)).toList(),
      dailySummary: DailySummary.fromJson(json['daily_summary'] as Map<String, dynamic>? ?? {}),
      streakDays: json['streak_days'] as int? ?? 0,
    );
  }
}

class GetRecordsResult {
  final List<Transaction> records;
  final int total;

  const GetRecordsResult({required this.records, required this.total});

  factory GetRecordsResult.fromJson(Map<String, dynamic> json) {
    final list = json['records'] as List<dynamic>? ?? [];
    return GetRecordsResult(
      records: list.map((t) => Transaction.fromJson(t as Map<String, dynamic>)).toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}

enum SummaryPeriod { daily, monthly }

extension SummaryPeriodX on SummaryPeriod {
  String get wireValue => this == SummaryPeriod.daily ? 'daily' : 'monthly';
  String get label => this == SummaryPeriod.daily ? 'Harian' : 'Bulanan';
}

class FinancialSummary {
  final SummaryPeriod period;
  final String? date;
  final int? year;
  final int? month;
  final int income;
  final int expense;
  final int profit;
  final double marginPct;
  final int transactionCount;

  const FinancialSummary({
    required this.period,
    required this.income,
    required this.expense,
    required this.profit,
    required this.marginPct,
    required this.transactionCount,
    this.date,
    this.year,
    this.month,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      period: json['period'] == 'monthly' ? SummaryPeriod.monthly : SummaryPeriod.daily,
      date: json['date'] as String?,
      year: json['year'] as int?,
      month: json['month'] as int?,
      income: json['income'] as int? ?? 0,
      expense: json['expense'] as int? ?? 0,
      profit: json['profit'] as int? ?? 0,
      marginPct: (json['margin_pct'] as num?)?.toDouble() ?? 0,
      transactionCount: json['transaction_count'] as int? ?? 0,
    );
  }
}

class DailyBreakdownEntry {
  final String date;
  final int income;
  final int expense;
  final int profit;

  const DailyBreakdownEntry({required this.date, required this.income, required this.expense, required this.profit});

  factory DailyBreakdownEntry.fromJson(Map<String, dynamic> json) {
    return DailyBreakdownEntry(
      date: json['date'] as String? ?? '',
      income: json['income'] as int? ?? 0,
      expense: json['expense'] as int? ?? 0,
      profit: json['profit'] as int? ?? 0,
    );
  }
}

class KurReadiness {
  final bool hasNib;
  final bool has30DaysRecords;
  final int daysRecorded;
  final String message;

  const KurReadiness({
    required this.hasNib,
    required this.has30DaysRecords,
    required this.daysRecorded,
    required this.message,
  });

  factory KurReadiness.fromJson(Map<String, dynamic> json) {
    return KurReadiness(
      hasNib: json['has_nib'] as bool? ?? false,
      has30DaysRecords: json['has_30_days_records'] as bool? ?? false,
      daysRecorded: json['days_recorded'] as int? ?? 0,
      message: json['message'] as String? ?? '',
    );
  }
}

class FinanceReportSummary {
  final int totalIncome;
  final int totalExpense;
  final int grossProfit;
  final double grossMarginPct;
  final int recordingDays;
  final double consistencyPct;

  const FinanceReportSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.grossProfit,
    required this.grossMarginPct,
    required this.recordingDays,
    required this.consistencyPct,
  });

  factory FinanceReportSummary.fromJson(Map<String, dynamic> json) {
    return FinanceReportSummary(
      totalIncome: json['total_income'] as int? ?? 0,
      totalExpense: json['total_expense'] as int? ?? 0,
      grossProfit: json['gross_profit'] as int? ?? 0,
      grossMarginPct: (json['gross_margin_pct'] as num?)?.toDouble() ?? 0,
      recordingDays: json['recording_days'] as int? ?? 0,
      consistencyPct: (json['consistency_pct'] as num?)?.toDouble() ?? 0,
    );
  }
}

class FinancialReport {
  final String? businessName;
  final String businessType;
  final String period;
  final DateTime reportGeneratedAt;
  final FinanceReportSummary summary;
  final List<DailyBreakdownEntry> dailyBreakdown;
  final KurReadiness kurReadiness;

  const FinancialReport({
    required this.businessName,
    required this.businessType,
    required this.period,
    required this.reportGeneratedAt,
    required this.summary,
    required this.dailyBreakdown,
    required this.kurReadiness,
  });

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    final breakdownJson = json['daily_breakdown'] as List<dynamic>? ?? [];
    return FinancialReport(
      businessName: json['business_name'] as String?,
      businessType: json['business_type'] as String? ?? '',
      period: json['period'] as String? ?? '',
      reportGeneratedAt: DateTime.tryParse(json['report_generated_at'] as String? ?? '') ?? DateTime.now(),
      summary: FinanceReportSummary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      dailyBreakdown: breakdownJson.map((d) => DailyBreakdownEntry.fromJson(d as Map<String, dynamic>)).toList(),
      kurReadiness: KurReadiness.fromJson(json['kur_readiness'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class PresignedUploadResult {
  final String uploadUrl;
  final String publicUrl;
  final String fileKey;

  const PresignedUploadResult({required this.uploadUrl, required this.publicUrl, required this.fileKey});

  factory PresignedUploadResult.fromJson(Map<String, dynamic> json) {
    return PresignedUploadResult(
      uploadUrl: json['upload_url'] as String? ?? '',
      publicUrl: json['public_url'] as String? ?? '',
      fileKey: json['file_key'] as String? ?? '',
    );
  }
}

enum DocumentPurpose { sppIrt }
extension DocumentPurposeX on DocumentPurpose {
  String get wireValue => 'spp_irt';
  String get label => 'SPP-IRT';
}