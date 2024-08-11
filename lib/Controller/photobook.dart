
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelmate/Model/photobook.dart';

class PhotoBookController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<Photo>> getPhotos(String tripRoomId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('tripRooms')
        .doc(tripRoomId)
        .collection('photos')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => Photo.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<void> uploadPhoto(String tripRoomId, File imageFile, {required String description}) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child('tripPhotos').child(tripRoomId).child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      Photo photo = Photo(
        id: '',
        tripRoomId: tripRoomId,
        imageUrl: imageUrl,
        description: description,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('tripRooms')
          .doc(tripRoomId)
          .collection('photos')
          .add(photo.toMap());
    } catch (e) {
      print('Error uploading photo: $e');
    }
  }

  Future<File?> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
