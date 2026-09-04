import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../core/services/api_client.dart';
import '../../../core/utils/idempotency.dart';
import '../models/snapcash_models.dart';
import 'snapcash_format.dart';

class SnapCashRepository {
  SnapCashRepository._();
  static final instance = SnapCashRepository._();
  Future<RecordTransactionResult> recordTransaction({
    required String message,
    DateTime? recordDate,
    List<String>? images,
  }) async {
    final response = await ApiClient.instance.post(
      '/api/finance/record',
      {
        'message': message,
        if (recordDate != null) 'record_date': dateToIso(recordDate),
        if (images != null && images.isNotEmpty) 'images': images,
      },
      headers: {'x-idempotency-key': generateIdempotencyKey()},
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(decoded['message'] as String? ?? 'HTTP ${response.statusCode}');
    }
    return RecordTransactionResult.fromJson(decoded['data'] as Map<String, dynamic>? ?? {});
  }

  Future<GetRecordsResult> fetchRecords({DateTime? startDate, DateTime? endDate, TransactionType? type}) async {
    final query = <String, String>{
      if (startDate != null) 'start_date': dateToIso(startDate),
      if (endDate != null) 'end_date': dateToIso(endDate),
      if (type != null) 'type': type.wireValue,
    };
    final path = query.isEmpty ? '/api/finance/records' : '/api/finance/records?${Uri(queryParameters: query).query}';
    final response = await ApiClient.instance.get(path);
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat riwayat transaksi (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return GetRecordsResult.fromJson(decoded['data'] as Map<String, dynamic>? ?? {});
  }

  Future<FinancialSummary> fetchSummary({
    SummaryPeriod period = SummaryPeriod.daily,
    DateTime? date,
    int? year,
    int? month,
  }) async {
    final query = <String, String>{
      'period': period.wireValue,
      if (date != null) 'date': dateToIso(date),
      if (year != null) 'year': '$year',
      if (month != null) 'month': '$month',
    };
    final response = await ApiClient.instance.get('/api/finance/summary?${Uri(queryParameters: query).query}');
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat ringkasan (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return FinancialSummary.fromJson(decoded['data'] as Map<String, dynamic>? ?? {});
  }

  Future<FinancialReport> fetchReport({int? year, int? month}) async {
    final query = <String, String>{
      if (year != null) 'year': '$year',
      if (month != null) 'month': '$month',
    };
    final path = query.isEmpty ? '/api/finance/report' : '/api/finance/report?${Uri(queryParameters: query).query}';
    final response = await ApiClient.instance.get(path);
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat laporan (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return FinancialReport.fromJson(decoded['data'] as Map<String, dynamic>? ?? {});
  }

  Future<Uint8List> fetchReportExcelBytes({int? year, int? month}) async {
    final query = <String, String>{
      if (year != null) 'year': '$year',
      if (month != null) 'month': '$month',
    };
    final path = query.isEmpty ? '/api/finance/report/excel' : '/api/finance/report/excel?${Uri(queryParameters: query).query}';
    final response = await ApiClient.instance.get(path);
    if (response.statusCode != 200) {
      throw Exception('Gagal mengunduh laporan excel (${response.statusCode})');
    }
    return response.bodyBytes;
  }

  Future<PresignedUploadResult> generatePresignedUrl({
    required String fileName,
    required String contentType,
    String folder = 'receipts',
  }) async {
    final response = await ApiClient.instance.post('/api/upload/presigned-url', {
      'file_name': fileName,
      'content_type': contentType,
      'folder': folder,
    });
    if (response.statusCode != 200) {
      throw Exception('Gagal menyiapkan upload (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return PresignedUploadResult.fromJson(decoded['data'] as Map<String, dynamic>? ?? {});
  }
  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal mengunggah foto (${response.statusCode})');
    }
  }

  Future<String> uploadReceiptImage({
    required String fileName,
    required String contentType,
    required Uint8List bytes,
  }) async {
    final presigned = await generatePresignedUrl(fileName: fileName, contentType: contentType);
    await uploadToPresignedUrl(uploadUrl: presigned.uploadUrl, bytes: bytes, contentType: contentType);
    return presigned.publicUrl;
  }

  Future<List<String>> uploadReceiptImages(List<ReceiptImageUpload> images) {
    return Future.wait(
      images.map(
        (img) => uploadReceiptImage(
          fileName: img.fileName,
          contentType: img.contentType,
          bytes: img.bytes,
        ),
      ),
    );
  }

  Future<void> draftIngredientList({DocumentPurpose purpose = DocumentPurpose.sppIrt}) async {
    final response = await ApiClient.instance.post('/api/documents/draft/ingredient-list', {
      'purpose': purpose.wireValue,
    });
    if (response.statusCode == 404) throw DocumentBusinessProfileMissingException();
    if (response.statusCode == 400) throw DocumentInvalidPurposeException();
    if (response.statusCode != 200) {
      throw Exception('Gagal membuat draft dokumen (${response.statusCode})');
    }
  }

  Future<String> fetchIngredientListPreviewHtml({DocumentPurpose purpose = DocumentPurpose.sppIrt}) async {
    final response = await ApiClient.instance.get('/api/documents/preview/ingredient-list?purpose=${purpose.wireValue}');
    if (response.statusCode == 404) throw DocumentBusinessProfileMissingException();
    if (response.statusCode == 400) throw DocumentInvalidPurposeException();
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat preview dokumen (${response.statusCode})');
    }
    return response.body;
  }
}

class DocumentBusinessProfileMissingException implements Exception {}
class DocumentInvalidPurposeException implements Exception {}