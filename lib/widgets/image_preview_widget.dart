import 'package:blogverse/appwrite/appwrite_service.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class ImagePreviewWidget extends StatelessWidget {
  final String bucketId;
  final String fileId;
  final double width;
  final double height;

  // In-memory cache
  static final Map<String, Uint8List> _imageCache = {};

  const ImagePreviewWidget({super.key, 
    required this.bucketId,
    required this.fileId,
    this.width = 120,
    this.height = 90,
  });

  Future<Uint8List?> _getCachedImage() async {
    if (_imageCache.containsKey(fileId)) {
      return _imageCache[fileId];
    } else {
      try {
        Uint8List? image = await AppwriteService().getFilePreview(bucketId, fileId);
        _imageCache[fileId] = image; // Store the image in the cache
              return image;
      } catch (e) {
        // Handle error (you could log it or show a message)
        print('Error fetching image: $e');
        return null; // Return null to indicate an error occurred
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _getCachedImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Placeholder image while loading
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300], // Placeholder color
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300], // Placeholder color
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('Error loading image')),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                fit: BoxFit.contain, 
                image: MemoryImage(snapshot.data!),
              ),
            ),
          );
        } else {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300], // Placeholder color
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('No image found')),
          );
        }
      },
    );
  }
}
