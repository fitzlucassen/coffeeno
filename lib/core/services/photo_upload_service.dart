import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Uploads user images to Cloud Storage.
///
/// Centralizes the upload pipeline that was previously copy-pasted into several
/// screens (add-coffee, coffee-detail, edit-roaster, edit-farm), each differing
/// only by the destination path prefix. Keeping it here also gets the
/// `FirebaseStorage.instance` dependency out of the presentation layer.
class PhotoUploadService {
  PhotoUploadService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Uploads the JPEG at [localPath] under [pathPrefix] and returns its public
  /// download URL. A UUID filename avoids collisions.
  Future<String> uploadJpeg({
    required String pathPrefix,
    required String localPath,
  }) async {
    final fileName = '${const Uuid().v4()}.jpg';
    final ref = _storage.ref('$pathPrefix/$fileName');
    await ref.putFile(
      File(localPath),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}

/// Singleton [PhotoUploadService] provider.
final photoUploadServiceProvider = Provider<PhotoUploadService>((ref) {
  return PhotoUploadService();
});
