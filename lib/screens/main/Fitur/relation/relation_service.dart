import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RelationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendRelationRequest({
    required String name,
    required String phone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Pengguna belum login');
    }

    // Cari user target berdasarkan nomor telepon
    final targetSnapshot = await _firestore
        .collection('users')
        .where('telepon', isEqualTo: phone)
        .limit(1)
        .get();

    if (targetSnapshot.docs.isEmpty) {
      throw Exception('Pengguna tidak ditemukan');
    }

    final targetUser = targetSnapshot.docs.first;
    final targetUid = targetUser.id;

    // Buat ID relasi yang konsisten
    final relationId = _firestore.collection('dummy').doc().id;

    // Data relasi dikirim oleh pengirim (user saat ini)
    final relasiData = {
      'relasiId': relationId,
      'targetUid': targetUid,
      'namaLengkap': name,
      'telepon': phone,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    };

    // Ambil info pengirim
    final senderDoc =
        await _firestore.collection('users').doc(user.uid).get();

    final relasiMasukData = {
      'relasiId': relationId,
      'fromUid': user.uid,
      'namaLengkapPengirim': senderDoc['namaLengkap'] ?? 'Tidak tersedia',
      'teleponPengirim': senderDoc['telepon'] ?? 'Tidak tersedia',
      'status': 'pending',
      'createdAt': Timestamp.now(),
    };

    // Simpan data relasi
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('relasi')
        .doc(relationId)
        .set(relasiData);

    await _firestore
        .collection('users')
        .doc(targetUid)
        .collection('relasiMasuk')
        .doc(relationId)
        .set(relasiMasukData);
  }

  Future<void> handleRelationRequest({
    required String requestId,
    required String fromUid,
    required bool accept,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Pengguna belum login');
    }

    final batch = _firestore.batch();

    final requestRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('relasiMasuk')
        .doc(requestId);

    if (accept) {
      // Ambil data pengirim dan penerima
      final senderDoc =
          await _firestore.collection('users').doc(fromUid).get();
      final receiverDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      // Update status permintaan menjadi diterima
      batch.update(requestRef, {'status': 'accepted'});

      // Tambahkan relasi ke koleksi relasi pengirim
      final senderRelationData = {
        'relasiId': requestId,
        'targetUid': currentUser.uid,
        'namaLengkap': receiverDoc['namaLengkap'] ?? 'Tidak tersedia',
        'telepon': receiverDoc['telepon'] ?? 'Tidak tersedia',
        'email': receiverDoc['email'] ?? 'Tidak tersedia',
        'alamat': receiverDoc['alamat'] ?? 'Tidak tersedia',
        'location': receiverDoc['location'],
        'createdAt': Timestamp.now(),
        'lastUpdated': Timestamp.now(),
        'status': 'accepted',
      };

      batch.set(
        _firestore
            .collection('users')
            .doc(fromUid)
            .collection('relasi')
            .doc(requestId),
        senderRelationData,
      );

      // Tambahkan relasi ke koleksi relasi penerima
      final receiverRelationData = {
        'relasiId': requestId,
        'targetUid': fromUid,
        'namaLengkap': senderDoc['namaLengkap'] ?? 'Tidak tersedia',
        'telepon': senderDoc['telepon'] ?? 'Tidak tersedia',
        'email': senderDoc['email'] ?? 'Tidak tersedia',
        'alamat': senderDoc['alamat'] ?? 'Tidak tersedia',
        'location': senderDoc['location'],
        'createdAt': Timestamp.now(),
        'lastUpdated': Timestamp.now(),
        'status': 'accepted',
      };

      batch.set(
        _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('relasi')
            .doc(requestId),
        receiverRelationData,
      );
    } else {
      // Update status permintaan menjadi ditolak
      batch.update(requestRef, {'status': 'rejected'});
    }

    await batch.commit();
  }
}
