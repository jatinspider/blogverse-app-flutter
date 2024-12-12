import 'package:blogverse/widgets/image_preview_widget.dart';
import 'package:blogverse/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:blogverse/model/PostModel.dart';
import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_html/style.dart'; // Ensure to import flutter_html/style.dart

class PostInfo extends StatelessWidget {
  final Post post;

  const PostInfo({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          post.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          myIconButton(Icons.bookmark_outline),
          myIconButton(Icons.favorite_border),
          myIconButton(Icons.share_outlined),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: ListView(
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 40, 156, 250),
                  child: Text(
                    post.userName[0].toUpperCase(), // First letter of username
                    style: const TextStyle(color: Colors.white),
                  ), // Customize the color
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      post.createdAt.toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Post Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ImagePreviewWidget(
                bucketId: APPWRITE_BUCKET_ID,
                fileId: post.featuredImage,
                width: double.infinity, // Set the width to fill the available space
                height: 400, // Set a consistent height
              ),
            ),
            const SizedBox(height: 15),
            // Post Content
            Html(
              data: post.content, // Use your HTML content here
              style: {
                "p": Style(
                  fontSize: FontSize(18), // Increase the font size of paragraphs
                  lineHeight: const LineHeight(1.5), // Optional: Set line height
                  color: Colors.black, // Set text color
                ),
                "h1": Style(
                  fontSize: FontSize(24),
                  fontWeight: FontWeight.bold,
                ),
                "h2": Style(
                  fontSize: FontSize(22),
                  fontWeight: FontWeight.bold,
                ),
              },
            ),
            const SizedBox(height: 20),
            // Action Buttons
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     likeShareButton(Icons.remove_red_eye_outlined, "${post.views} Views"),
            //     likeShareButton(Icons.favorite, "${post.likes} Likes"),
            //     likeShareButton(Icons.bookmark, "${post.saves} Saves"),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Wrap likeShareButton(IconData icon, String title) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.black54,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Padding myIconButton(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.red[200],
          child: IconButton(
            onPressed: () {
              // Action for icon button
            },
            icon: Icon(
              icon,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
