import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage under emergencies/{filename}
  /// Returns the download URL string, or null if failed
  Future<String?> uploadEmergencyImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        developer.log("StorageService: File does not exist at path: $filePath");
        return null;
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${filePath.split(Platform.pathSeparator).last}';
      final ref = _storage.ref().child('emergencies').child(fileName);

      developer.log("StorageService: Uploading file $fileName to Firebase Storage...");
      final uploadTask = await ref.putFile(file);

      if (uploadTask.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        developer.log("StorageService: Upload complete. URL: $downloadUrl");
        return downloadUrl;
      }
      return null;
    } catch (e) {
      developer.log("StorageService: Upload failed with error: $e");
      return null;
    }
  }
}
