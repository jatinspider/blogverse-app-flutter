
import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import 'package:blogverse/constants/constants.dart';
import 'package:blogverse/model/PostModel.dart';

class AppwriteService {
  final Client client;
  late final Account account;
  late final Storage storage;
  late final Databases databases;

  AppwriteService()
      : client = Client() // Initialize the Client instance here
          ..setEndpoint(APPWRITE_URL) // Set your Appwrite endpoint
          ..setProject(APPWRITE_PROJECT_ID) // Set your Appwrite project ID
          ..setSelfSigned() // Use self-signed certificates if needed
          {
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }

  // Fetching the file preview from Appwrite storage
  Future<Uint8List> getFilePreview(String bucketId, String fileId) async {
    try {
      return await storage.getFilePreview(fileId: fileId, bucketId: bucketId);
    } catch (e) {
      print('Error fetching image: $e');
      throw Exception('Error fetching file preview: $e');
    }
  }

  // Fetching all posts from Appwrite database
  Future<List<Post>> getAllPosts() async {
    List<Post> postsList = [];

    try {
      final response = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: APPWRITE_COLLECTION_ID,
      );

      // Parse each document into a Post model
      postsList = response.documents.map((doc) {
        try {
          return Post.fromMap(doc.data); // Convert document to Post
        } catch (e) {
          print('Error creating Post from document: $e');
          print('Document data causing issue: ${doc.data}');
          return null; // Return null in case of an error
        }
      }).whereType<Post>().toList(); // Filter out null values
    } catch (e) {
      print('Error fetching posts: $e');
      throw Exception('Failed to fetch posts: $e');
    }

    return postsList;
  }

  // Fetch posts by category
  Future<List<Post>> getPostsByCategory(String category) async {
    List<Post> categoryPosts = [];

    try {
      final response = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: APPWRITE_COLLECTION_ID,
        queries: [
          Query.equal('category', category),
        ],
      );

      // Parse each document into a Post model
      categoryPosts = response.documents.map((doc) {
        try {
          return Post.fromMap(doc.data); // Convert document to Post
        } catch (e) {
          print('Error creating Post from document: $e');
          print('Document data causing issue: ${doc.data}');
          return null; // Return null in case of an error
        }
      }).whereType<Post>().toList(); // Filter out null values
    } catch (e) {
      print('Error fetching posts by category: $e');
      throw Exception('Failed to fetch posts by category: $e');
    }

    return categoryPosts;
  }

  // Create a new post
  Future<void> createPost({
    required String title,
    required String content,
    required String featuredImage,
    required String status,
    required String userId,
    required String userName,
    required String createdAt,
    required String category,
  }) async {
    try {
      await databases.createDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: APPWRITE_COLLECTION_ID,
        documentId: 'unique()', // Use unique ID for the document
        data: {
          'title': title,
          'content': content,
          'featuredImage': featuredImage,
          'status': status,
          'userId': userId,
          'userName': userName,
          'createdAt': createdAt,
          'category': category,
        },
      );
    } catch (e) {
      print('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

Future<void> deletePost(String postId) async {
  try {
    // Fetch the post to get the featured image information
    final postResponse = await databases.getDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: APPWRITE_COLLECTION_ID,
      documentId: postId,
    );

    // Extract the featured image ID (or URL) from the post document
    final featuredImageId = postResponse.data['featuredImage']; // Adjust this according to your structure

    // Delete the post document
    await databases.deleteDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: APPWRITE_COLLECTION_ID,
      documentId: postId,
    );

    // If the featured image ID exists, delete it from storage
    if (featuredImageId != null && featuredImageId.isNotEmpty) {
      await deleteFile(featuredImageId); // Ensure this function handles the deletion of the image
    }
  } catch (e) {
    print('Error deleting post: $e');
    throw Exception('Failed to delete post: $e');
  }
}

  // Upload a file to Appwrite Storage
  Future<String?> uploadFile(Uint8List fileData, String fileName) async {
    try {
      final response = await storage.createFile(
        bucketId: APPWRITE_BUCKET_ID, // Replace with your bucket ID
        fileId: 'unique()', // Use unique ID for the file
        file: InputFile.fromBytes(
          bytes: fileData,
          filename: fileName,
        ),
      );
      return response.$id; // Return the uploaded file's ID
    } catch (e) {
      print('Error uploading file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  // Delete a file by fileId
  Future<void> deleteFile(String fileId) async {
    try {
      await storage.deleteFile(
        bucketId: APPWRITE_BUCKET_ID, // Replace with your bucket ID
        fileId: fileId,
      );
    } catch (e) {
      print('Error deleting file: $e');
      throw Exception('Failed to delete file: $e');
    }
  }

  // Update an existing post with the option to upload a new image
  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    String? newFeaturedImage,
    String? existingFeaturedImage,
    required String category,
    required String status,
  }) async {
    try {
      // Logic to delete the existing image if a new image is provided
      if (newFeaturedImage != null && existingFeaturedImage != null) {
        await deleteFile(existingFeaturedImage);
      }

      // Update the post in the database
      await databases.updateDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: APPWRITE_COLLECTION_ID,
        documentId: postId,
        data: {
          'title': title,
          'content': content,
          'featuredImage': newFeaturedImage ?? existingFeaturedImage,
          'category': category,
          'status': status,
        },
      );
    } catch (e) {
      print('Error updating post: $e');
      throw Exception('Failed to update post: $e');
    }
  }
}
