import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Wraps Firebase Storage uploads — currently used for user avatars.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadAvatar({
    required String uid,
    required File file,
  }) async {
    final String ext = file.path.split('.').last;
    final Reference ref = _storage.ref('avatars/$uid/profile.$ext');
    final UploadTask task = ref.putFile(file);
    final TaskSnapshot snap = await task;
    return snap.ref.getDownloadURL();
  }
}
