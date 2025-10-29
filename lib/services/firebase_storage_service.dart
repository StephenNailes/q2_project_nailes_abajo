import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Firebase Storage Service
/// Handles file uploads to Firebase Storage
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile picture
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final Reference ref = _storage.ref().child('profile_pictures/$fileName');
      
      // Upload file
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Delete profile picture
  Future<void> deleteProfilePicture(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete profile picture: $e');
    }
  }

  /// Upload submission photos
  Future<List<String>> uploadSubmissionPhotos(
    String userId,
    List<File> photos,
  ) async {
    try {
      final List<String> downloadUrls = [];
      
      for (int i = 0; i < photos.length; i++) {
        final String fileName = 'submission_${userId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final Reference ref = _storage.ref().child('submissions/$fileName');
        
        // Upload file
        final UploadTask uploadTask = ref.putFile(photos[i]);
        final TaskSnapshot snapshot = await uploadTask;
        
        // Get download URL
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
      
      return downloadUrls;
    } catch (e) {
      throw Exception('Failed to upload submission photos: $e');
    }
  }
}
