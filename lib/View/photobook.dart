import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelmate/Model/photobook.dart';
import 'package:travelmate/Controller/photobook.dart';
import 'dart:io';


/*class PhotoBookView extends StatefulWidget {
  final String tripRoomId;

  PhotoBookView({required this.tripRoomId});

  @override
  _PhotoBookViewState createState() => _PhotoBookViewState();
}

class _PhotoBookViewState extends State<PhotoBookView> {
  late PhotoBookController _controller;
  List<Photo> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = PhotoBookController();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });

    List<Photo> photos = await _controller.getPhotos(widget.tripRoomId);

    setState(() {
      _photos = photos;
      _isLoading = false;
    });
  }

  Future<void> _uploadPhoto() async {
    File? image = await _controller.selectImage();
    if (image != null) {
      await _controller.uploadPhoto(widget.tripRoomId, image, description: 'Amazing trip!');
      await _loadPhotos(); // Refresh photobook view after upload
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Photo Book',
          style: GoogleFonts.poppins(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: _uploadPhoto,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoDetailView(photo: _photos[index]),
                ),
              );
            },
            child: Image.network(
              _photos[index].imageUrl,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}*/

class PhotoBookView extends StatefulWidget {
  final String tripRoomId;

  PhotoBookView({required this.tripRoomId});

  @override
  _PhotoBookViewState createState() => _PhotoBookViewState();
}

class _PhotoBookViewState extends State<PhotoBookView> {
  late PhotoBookController _controller;
  List<Photo> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = PhotoBookController();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });

    List<Photo> photos = await _controller.getPhotos(widget.tripRoomId);

    setState(() {
      _photos = photos;
      _isLoading = false;
    });
  }

  Future<void> _uploadPhoto() async {
    File? image = await _controller.selectImage();
    if (image != null) {
      String description = await _showDescriptionDialog();

      if (description.isNotEmpty) {
        await _controller.uploadPhoto(widget.tripRoomId, image, description: description);
        await _loadPhotos(); // Refresh photobook view after upload
      }
    }
  }

  Future<String> _showDescriptionDialog() async {
    TextEditingController descriptionController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Description'),
          content: TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: 'Description'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(descriptionController.text.isNotEmpty ? descriptionController.text : ''); // Return an empty string if no description is entered
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(''); // Return an empty string if the user cancels
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    ).then((value) => value ?? ''); // Ensure that null values are converted to an empty string
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Photo Book',
          style: GoogleFonts.poppins(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: _uploadPhoto,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoDetailView(photo: _photos[index]),
                ),
              );
            },
            child: Image.network(
              _photos[index].imageUrl,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}

class PhotoDetailView extends StatelessWidget {
  final Photo photo;

  PhotoDetailView({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(
          'Photo Details',
          style: GoogleFonts.poppins(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(photo.imageUrl),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              photo.description,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Uploaded on: ${photo.timestamp}',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
