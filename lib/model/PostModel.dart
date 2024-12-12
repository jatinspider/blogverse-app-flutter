class Post {
  final String id;
  final String title;
  final String content;
  final String status;
  final String userId;
  final String userName;
  final String featuredImage;
  final String category;
  final String createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.userId,
    required this.userName,
    required this.featuredImage,
    required this.category,
    required this.createdAt,
  });

  // Convert from Map<String, dynamic> to Post object
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['\$id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      status: map['status'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      featuredImage: map['featuredImage'] ?? '',
      category: map['category'] ?? '',
      createdAt: (map['createdAt'] ?? ''),
    );
  }

  // Convert Post object back to Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      '\$id': id,
      'title': title,
      'content': content,
      'status': status,
      'userId': userId,
      'userName': userName,
      'featuredImage': featuredImage,
      'category': category,
      'createdAt': createdAt.toString(),
    };
  }
}
