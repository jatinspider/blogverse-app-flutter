
import 'package:blogverse/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:blogverse/widgets/image_preview_widget.dart'; // Import your ImagePreviewWidget
import 'package:blogverse/appwrite/appwrite_service.dart';
import 'package:blogverse/model/PostModel.dart';
import 'package:blogverse/Pages/post_info.dart'; // Import PostInfo page

class CategoryPage extends StatefulWidget {
  final String title;
  final String featuredImage; // This represents the fileId

  const CategoryPage({
    super.key,
    required this.title,
    required this.featuredImage,
  });

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Post> categoryPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategoryPosts();
  }

  Future<void> fetchCategoryPosts() async {
    try {
      List<Post> posts = await AppwriteService().getPostsByCategory(widget.title);
      
      // Filter to only include posts with the status 'active'
      List<Post> activePosts = posts.where((post) => post.status == 'active').toList();
      
      setState(() {
        categoryPosts = activePosts; // Update with only active posts
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching category posts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ImagePreviewWidget(
                bucketId: APPWRITE_BUCKET_ID, // Pass your Appwrite bucket ID
                fileId: widget.featuredImage, // Use the actual fileId from the category
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Posts from the category',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Show loading indicator or posts
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: categoryPosts.length,
                      itemBuilder: (context, index) {
                        final post = categoryPosts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostInfo(post: post),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'By ${post.userName} on ${post.createdAt}', // Assuming createdAt is a string
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Display the featured image for each post in larger size
                                  if (post.featuredImage.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        width: double.infinity, // Full width
                                        height: 250, // Set height for larger display
                                        child: ImagePreviewWidget(
                                          bucketId: APPWRITE_BUCKET_ID,
                                          fileId: post.featuredImage,
                                          // Set the width and height directly in the widget
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
