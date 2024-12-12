
import 'package:appwrite/appwrite.dart';
import 'package:blogverse/Pages/edit_post.dart';
import 'package:blogverse/appwrite/appwrite_service.dart';
import 'package:blogverse/appwrite/auth_check.dart';
import 'package:blogverse/model/PostModel.dart';
import 'package:blogverse/Pages/post_info.dart';
import 'package:blogverse/widgets/all_posts.dart';
import 'package:blogverse/widgets/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import 'package:blogverse/widgets/image_preview_widget.dart';
import 'package:blogverse/constants/constants.dart';
import 'package:blogverse/widgets/categories_tab.dart';
import 'package:blogverse/widgets/add_post_tab.dart';

class HomePage extends StatefulWidget {
  final models.User user;
  final Account account;

  const HomePage({super.key, required this.user, required this.account});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> posts = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await AppwriteService().getAllPosts();
      // Filter posts to include only those from the logged-in user
      setState(() {
        posts = response.where((post) => post.userId == widget.user.$id).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching posts. Please try again.')),
      );
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await AppwriteService().deletePost(postId);
      setState(() {
        posts.removeWhere((post) => post.id == postId); // Remove the deleted post from the list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully.')),
      );
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting post. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          title: const Text(
            "BlogVerse",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'logout') {
                  await widget.account.deleteSession(sessionId: 'current');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => AuthCheck(account: widget.account),
                    ),
                  );
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    value: 'username',
                    child: Text(widget.user.name),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ];
              },
              child: CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 119, 77, 236),
                child: Text(
                  widget.user.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Home"),
              Tab(text: "All Posts"),
              Tab(text: "Categories"),
              Tab(text: "Profile"),
              Tab(text: "Add Post"),
            ],
            labelColor: Colors.black,
            indicatorColor: Colors.black,
          ),
        ),
        body: TabBarView(
          children: [
            // Home Tab
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Blogs',
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
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : posts.isNotEmpty
                            ? ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: posts.length,
                                separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  if (searchQuery.isEmpty ||
                                      post.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                                      post.userName.toLowerCase().contains(searchQuery.toLowerCase())) {
                                    return ListTile(
                                      title: Text(post.title),
                                      subtitle: Text("${post.userName}, ${post.createdAt}"),
                                      leading: ImagePreviewWidget(
                                        bucketId: APPWRITE_BUCKET_ID,
                                        fileId: post.featuredImage,
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                           
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditPostScreen(post: post,
                                                onPostUpdated: fetchPosts), // Create this page for editing
                                              ),
                                            );
                                          } else if (value == 'delete') {
                                            await deletePost(post.id);
                                          }
                                        },
                                        itemBuilder: (context) {
                                          return [
                                            const PopupMenuItem<String>(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ];
                                        },
                                      ),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => PostInfo(post: post)));
                                      },
                                    );
                                  } else {
                                    return Container(); 
                                  }
                                },
                              )
                            : const Center(child: Text("No blogs available")),
                  ),
                ],
              ),
            ),
            // All Posts Tab
            AllPostsTab(
              posts: posts,
              isLoading: isLoading,
             
              currentUserId: widget.user.$id,
            ),
            // Categories Tab
            const CategoriesTab(),
            // Profile Tab
            ProfileTab(account: widget.account, userName: widget.user.name),
            // Add Post Tab with callback to refresh posts
            AddPostTab(
              onPostAdded: fetchPosts,
              userId: widget.user.$id,
              userName: widget.user.name,
            ),
          ],
        ),
      ),
    );
  }
}
