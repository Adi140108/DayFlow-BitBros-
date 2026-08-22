import 'package:cloud_firestore/cloud_firestore.dart';
import '../storage/backblaze_storage_impl.dart';

class ReportMetadata {
  final String id;
  final String organizationId;
  final String title;
  final String category;
  final String format; // 'CSV', 'PDF'
  final String storagePath;
  final DateTime createdAt;

  const ReportMetadata({
    required this.id,
    required this.organizationId,
    required this.title,
    required this.category,
    required this.format,
    required this.storagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'title': title,
      'category': category,
      'format': format,
      'storagePath': storagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReportMetadata.fromMap(Map<String, dynamic> map) {
    return ReportMetadata(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      format: map['format'] as String,
      storagePath: map['storagePath'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class ReportRepository {
  final FirebaseFirestore _firestore;
  final BackblazeStorageImpl storage;

  ReportRepository({FirebaseFirestore? firestore, BackblazeStorageImpl? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? BackblazeStorageImpl();

  /// Saves report metadata to Firestore
  Future<ReportMetadata> saveReportMetadata(ReportMetadata meta) async {
    final ref = _firestore.collection('reports').doc();
    final report = ReportMetadata(
      id: ref.id,
      organizationId: meta.organizationId,
      title: meta.title,
      category: meta.category,
      format: meta.format,
      storagePath: meta.storagePath,
      createdAt: DateTime.now(),
    );
    await ref.set(report.toMap());
    return report;
  }

  /// Fetches generated organization reports
  Future<List<ReportMetadata>> getReports(String orgId) async {
    final snapshot = await _firestore
        .collection('reports')
        .where('organizationId', isEqualTo: orgId)
        .get();

    return snapshot.docs.map((doc) => ReportMetadata.fromMap(doc.data())).toList();
  }
}
