import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'package:blogverse/appwrite/appwrite_service.dart';
import 'package:uuid/uuid.dart';
class AddPostTab extends StatefulWidget {
  final Function onPostAdded;
  final String userId; // Receive the user ID
  final String userName; // Receive the user name

  const AddPostTab({super.key, required this.onPostAdded, required this.userId, required this.userName});

  @override
  _AddPostTabState createState() => _AddPostTabState();
}

class _AddPostTabState extends State<AddPostTab> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String category = '';
  String status = 'active';
  Uint8List? imageBytes;
  String? fileName;
  final Uuid _uuid = const Uuid();

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
        imageBytes = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      String title = _titleController.text;
      String content = _contentController.text;

      String? fileId;

      if (imageBytes != null) {
        String generatedFileName = _uuid.v4();
        fileId = (await AppwriteService().uploadFile(imageBytes!, generatedFileName));
      }

      // Format the current time using intl package
      String formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

      // Submit the post with userId and userName from the HomePage
      await AppwriteService().createPost(
        title: title,
        content: content,
        featuredImage: fileId ?? '',
        status: status,
        userId: widget.userId, // Pass the userId from HomePage
        userName: widget.userName, // Pass the userName from HomePage
        createdAt: formattedDate, // Use the formatted date
        category: category,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      widget.onPostAdded();

      setState(() {
        _titleController.clear();
        _contentController.clear();
        category = '';
        imageBytes = null;
        fileName = null;
        status = 'active';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
            ),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              validator: (value) => value!.isEmpty ? 'Please enter content' : null,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category'),
              value: category.isEmpty ? null : category,
              onChanged: (value) => setState(() {
                category = value!;
              }),
              validator: (value) => value == null ? 'Please select a category' : null,
              items: ['Technology', 'Health', 'Travel', 'Education', 'Lifestyle', 'Food' ,'Entertainment']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Status'),
              value: status,
              onChanged: (value) => setState(() {
                status = value!;
              }),
              items: ['active', 'inactive']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Image'),
            ),
            if (imageBytes != null) ...[
              const SizedBox(height: 10),
              Text('Selected image: $fileName'),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit'),
               ),
          ],
        ),
      ),
    );
  }
}
