import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/submission_model.dart';

/// Firebase Submission Service
/// Handles e-waste submission operations
class FirebaseSubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================
  // CREATE SUBMISSION
  // ============================================

  /// Submit a new recycling request
  Future<String> createSubmission({
    required String userId,
    required String itemType,
    required int quantity,
    required String dropOffLocation,
    List<File>? photoFiles,
  }) async {
    try {
      // Upload photos if provided
      List<String> photoUrls = [];
      if (photoFiles != null && photoFiles.isNotEmpty) {
        photoUrls = await _uploadPhotos(userId, photoFiles);
      }

      // Create submission model
      final submission = SubmissionModel(
        id: '', // Will be set by Firestore
        userId: userId,
        itemType: itemType,
        quantity: quantity,
        dropOffLocation: dropOffLocation,
        photoUrls: photoUrls,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // Add to Firestore
      final docRef = await _firestore
          .collection('submissions')
          .add(submission.toFirebaseJson());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create submission: $e');
    }
  }

  // ============================================
  // READ SUBMISSIONS
  // ============================================

  /// Get all submissions for a user
  Future<List<SubmissionModel>> getUserSubmissions(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('submissions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SubmissionModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get submissions: $e');
    }
  }

  /// Get submissions by status
  Future<List<SubmissionModel>> getSubmissionsByStatus({
    required String userId,
    required String status,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('submissions')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SubmissionModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get submissions by status: $e');
    }
  }

  /// Get a single submission
  Future<SubmissionModel?> getSubmission(String submissionId) async {
    try {
      final doc = await _firestore
          .collection('submissions')
          .doc(submissionId)
          .get();

      if (doc.exists && doc.data() != null) {
        return SubmissionModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get submission: $e');
    }
  }

  /// Stream of user submissions (real-time updates)
  Stream<List<SubmissionModel>> streamUserSubmissions(String userId) {
    return _firestore
        .collection('submissions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubmissionModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // ============================================
  // UPDATE SUBMISSION
  // ============================================

  /// Update submission status
  Future<void> updateSubmissionStatus({
    required String submissionId,
    required String status,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'status': status,
      };

      if (status == 'completed') {
        updates['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('submissions')
          .doc(submissionId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update submission status: $e');
    }
  }

  /// Cancel submission
  Future<void> cancelSubmission(String submissionId) async {
    try {
      await updateSubmissionStatus(
        submissionId: submissionId,
        status: 'cancelled',
      );
    } catch (e) {
      throw Exception('Failed to cancel submission: $e');
    }
  }

  // ============================================
  // DELETE SUBMISSION
  // ============================================

  /// Delete submission
  Future<void> deleteSubmission(String submissionId) async {
    try {
      // Get submission to delete photos
      final submission = await getSubmission(submissionId);
      
      if (submission != null && submission.photoUrls.isNotEmpty) {
        // Delete photos from storage
        await _deletePhotos(submission.photoUrls);
      }

      // Delete submission document
      await _firestore.collection('submissions').doc(submissionId).delete();
    } catch (e) {
      throw Exception('Failed to delete submission: $e');
    }
  }

  // ============================================
  // STATISTICS
  // ============================================

  /// Get total submissions count for user
  Future<int> getTotalSubmissionsCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('submissions')
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get submissions count: $e');
    }
  }

  /// Get completed submissions count
  Future<int> getCompletedSubmissionsCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('submissions')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get completed submissions count: $e');
    }
  }

  /// Get total items recycled
  Future<int> getTotalItemsRecycled(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('submissions')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      int total = 0;
      for (var doc in querySnapshot.docs) {
        final submission = SubmissionModel.fromJson(doc.data(), doc.id);
        total += submission.quantity;
      }

      return total;
    } catch (e) {
      throw Exception('Failed to get total items recycled: $e');
    }
  }

  // ============================================
  // PHOTO MANAGEMENT
  // ============================================

  /// Upload photos to Firebase Storage
  Future<List<String>> _uploadPhotos(String userId, List<File> photos) async {
    try {
      List<String> urls = [];
      
      for (int i = 0; i < photos.length; i++) {
        final file = photos[i];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'submission_${timestamp}_$i.jpg';
        final storageRef = _storage.ref().child('submissions/$userId/$fileName');
        
        // Upload file
        final uploadTask = await storageRef.putFile(file);
        
        // Get download URL
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        urls.add(downloadUrl);
      }

      return urls;
    } catch (e) {
      throw Exception('Failed to upload photos: $e');
    }
  }

  /// Delete photos from Firebase Storage
  Future<void> _deletePhotos(List<String> photoUrls) async {
    try {
      for (String url in photoUrls) {
        try {
          final ref = _storage.refFromURL(url);
          await ref.delete();
        } catch (e) {
          // Continue deleting other photos even if one fails
          debugPrint('Failed to delete photo: $url - $e');
        }
      }
    } catch (e) {
      // Don't throw error for photo deletion failures
      debugPrint('Error deleting photos: $e');
    }
  }

  /// Upload a single photo
  Future<String> uploadPhoto(String userId, File photo) async {
    try {
      final urls = await _uploadPhotos(userId, [photo]);
      return urls.first;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }
}
