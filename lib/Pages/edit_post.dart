
import 'package:blogverse/constants/constants.dart';
import 'package:blogverse/widgets/image_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data'; // For handling image bytes
import 'package:blogverse/model/PostModel.dart';
import 'package:blogverse/appwrite/appwrite_service.dart';
import 'package:uuid/uuid.dart'; // For generating unique image names

class EditPostScreen extends StatefulWidget {
  final Post post;
  final VoidCallback onPostUpdated; // Callback to refresh the post list

  const EditPostScreen({super.key, required this.post, required this.onPostUpdated});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;
  late String _selectedStatus;
  bool _isSaving = false;

  Uint8List? imageBytes; // Image bytes for the new image
  String? fileName; // Name of the selected image file
  String? existingImageUrl; // URL of the existing image
  final Uuid _uuid = const Uuid(); // For generating unique file names

  final List<String> categories = ['Technology', 'Health', 'Travel', 'Education', 'Lifestyle', 'Food', 'Entertainment'];
  final List<String> statuses = ['active', 'inactive'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _selectedCategory = widget.post.category; // Set initial category
    _selectedStatus = widget.post.status; // Set initial status
    existingImageUrl = widget.post.featuredImage.isNotEmpty ? widget.post.featuredImage : null; // Set existing image URL
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        imageBytes = result.files.first.bytes; // Store the bytes of the selected image
        fileName = result.files.first.name; // Store the file name
      });
    }
  }

  Future<void> _savePost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? fileId; // Keep the old image if not replaced

      // If a new image was selected, upload it
      if (imageBytes != null) {
        String generatedFileName = _uuid.v4(); // Generate a unique file name
        fileId = await AppwriteService().uploadFile(imageBytes!, generatedFileName); // Upload the new image
      } else {
        fileId = existingImageUrl; // If no new image, keep the existing one
      }

      // Update the post with new values
      await AppwriteService().updatePost(
        postId: widget.post.id,
        title: _titleController.text,
        content: _contentController.text,
        newFeaturedImage: fileId, // Use the uploaded image if available
        existingFeaturedImage: existingImageUrl, // Keep the existing image if no new one is uploaded
        category: _selectedCategory, // Updated category
        status: _selectedStatus, // Updated status
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully')),
      );

      widget.onPostUpdated(); // Notify parent widget to refresh the post list
      Navigator.of(context).pop(); // Return to the previous screen
    } catch (e) {
      print('Error updating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update post: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Post Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Post Content'),
              maxLines: 10,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: statuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Show the selected image or the existing image (if available)
            if (existingImageUrl != null) ...[
              const Text('Existing Image:'),
              const SizedBox(height: 10),
              ImagePreviewWidget(
                bucketId: APPWRITE_BUCKET_ID,
                fileId: existingImageUrl!,
              ),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Image'),
            ),
            if (imageBytes != null) ...[
              const SizedBox(height: 10),
              Text('Selected image: $fileName'),
            ],
            const SizedBox(height: 20),
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _isSaving ? null : _savePost,
                    child: const Text('Save Changes'),
                  ),
          ],
        ),
      ),
    );
  }
}
