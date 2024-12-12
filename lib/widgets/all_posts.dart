import 'package:flutter/material.dart';
import 'package:blogverse/appwrite/appwrite_service.dart';
import 'package:blogverse/model/PostModel.dart';
import 'package:blogverse/widgets/image_preview_widget.dart';
import 'package:blogverse/Pages/post_info.dart';
import 'package:blogverse/constants/constants.dart';

class AllPostsTab extends StatefulWidget {
  final List<Post> posts;
  final bool isLoading;
  final String currentUserId;

  const AllPostsTab({
    Key? key,
    required this.posts,
    required this.isLoading,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _AllPostsTabState createState() => _AllPostsTabState();
}

class _AllPostsTabState extends State<AllPostsTab> {
  List<Post> allPosts = [];
  String searchQuery = ''; // Define searchQuery here
  bool isLoading = true; // Use local isLoading state

  @override
  void initState() {
    super.initState();
    fetchAllPosts();
  }

  Future<void> fetchAllPosts() async {
    try {
      final response = await AppwriteService().getAllPosts();

      // Filter posts where the status is 'active'
      List<Post> activePosts = response.where((post) => post.status == 'active').toList();

      setState(() {
        allPosts = activePosts; // Only store active posts
        isLoading = false; // Set loading to false after fetching
      });
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        isLoading = false; // Ensure loading is stopped even on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching all posts.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        children: [
          // Search Bar for All Posts Tab
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value; // Update the local state variable
              });
            },
            decoration: InputDecoration(
              labelText: 'Search All Posts',
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
              filled: true,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading // Use local isLoading state
                ? const Center(child: CircularProgressIndicator())
                : allPosts.isNotEmpty
                    ? ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: allPosts.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: Colors.grey),
                        itemBuilder: (context, index) {
                          final post = allPosts[index];
                          // Filter posts based on the search query
                          if (searchQuery.isEmpty ||
                              post.title
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()) ||
                              post.userName
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase())) {
                            return ListTile(
                              title: Text(post.title),
                              subtitle: Text("${post.userName}, ${post.createdAt}"),
                              leading: ImagePreviewWidget(
                                bucketId: APPWRITE_BUCKET_ID,
                                fileId: post.featuredImage,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PostInfo(post: post),
                                  ),
                                );
                              },
                            );
                          } else {
                            return Container();
                          }
                        },
                      )
                    : const Center(child: Text("No posts available")),
          ),
        ],
      ),
    );
  }
}
