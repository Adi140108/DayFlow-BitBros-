import 'package:cloud_firestore/cloud_firestore.dart';
import 'employee_document.dart';

/// Repository for document metadata operations in `documents/{docId}`.
class DocumentRepository {
  final FirebaseFirestore _firestore;

  DocumentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<EmployeeDocument>> getEmployeeDocuments(String employeeId) async {
    final snapshot = await _firestore
        .collection('documents')
        .where('employeeId', isEqualTo: employeeId)
        .get();

    return snapshot.docs
        .map((doc) => EmployeeDocument.fromMap(doc.data()))
        .toList();
  }

  Future<EmployeeDocument> saveDocumentMetadata(EmployeeDocument doc) async {
    await _firestore.collection('documents').doc(doc.id).set(doc.toMap());
    return doc;
  }

  Future<void> deleteDocumentMetadata(String docId) async {
    await _firestore.collection('documents').doc(docId).delete();
  }
}
