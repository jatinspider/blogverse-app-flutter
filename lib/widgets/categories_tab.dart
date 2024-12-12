import 'package:flutter/material.dart';
import 'package:blogverse/Pages/category_page.dart';
import 'package:blogverse/constants/constants.dart';
import 'package:blogverse/widgets/image_preview_widget.dart';

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  _CategoriesTabState createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  final List<Map<String, String>> categories = const [
    {'title': 'Technology', 'featuredImage': 'Technology'},
    {'title': 'Health', 'featuredImage': 'Health'},
    {'title': 'Travel', 'featuredImage': 'travel'},
    {'title': 'Education', 'featuredImage': 'Education'},
    {'title': 'Lifestyle', 'featuredImage': 'Lifestyle'},
    {'title': 'Food', 'featuredImage': 'Food'},
    {'title': 'Entertainment', 'featuredImage': 'Entertainment'},
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              if (searchQuery.isEmpty ||
                  category['title']!.toLowerCase().contains(searchQuery.toLowerCase())) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPage(
                          title: category['title']!,
                          featuredImage: category['featuredImage']!,
                        ),
                      ),
                    );
                  },
                  child: CategoryCard(
                    title: category['title']!,
                    featuredImage: category['featuredImage']!,
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String featuredImage;

  const CategoryCard({super.key, required this.title, required this.featuredImage});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ImagePreviewWidget(
                bucketId: APPWRITE_BUCKET_ID,
                fileId: featuredImage,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
