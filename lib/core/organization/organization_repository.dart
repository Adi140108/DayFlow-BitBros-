import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/app_role.dart';
import 'organization.dart';
import 'organization_membership.dart';

/// Firestore repository for organizations and membership management.
class OrganizationRepository {
  final FirebaseFirestore _firestore;

  OrganizationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Creates an organization and assigns the caller as Organization Owner atomically.
  Future<Organization> createOrganization({
    required String name,
    required String legalName,
    required String ownerUid,
  }) async {
    final orgRef = _firestore.collection('organizations').doc();
    final membershipRef = _firestore.collection('memberships').doc();

    final now = DateTime.now();
    final org = Organization(
      id: orgRef.id,
      name: name,
      legalName: legalName,
      ownerId: ownerUid,
      createdAt: now,
    );

    final membership = OrganizationMembership(
      id: membershipRef.id,
      userId: ownerUid,
      organizationId: orgRef.id,
      role: AppRole.organizationOwner,
      createdAt: now,
    );

    // Atomic multi-document write
    final batch = _firestore.batch();
    batch.set(orgRef, org.toMap());
    batch.set(membershipRef, membership.toMap());
    await batch.commit();

    return org;
  }

  /// Fetches memberships for a user
  Future<List<OrganizationMembership>> getUserMemberships(String userId) async {
    final snapshot = await _firestore
        .collection('memberships')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs
        .map((doc) => OrganizationMembership.fromMap(doc.data()))
        .toList();
  }

  /// Fetches organization details by ID
  Future<Organization?> getOrganization(String orgId) async {
    final doc = await _firestore.collection('organizations').doc(orgId).get();
    if (doc.exists && doc.data() != null) {
      return Organization.fromMap(doc.data()!);
    }
    return null;
  }
}
