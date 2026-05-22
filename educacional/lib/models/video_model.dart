class VideoModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String videoUrl;
  final String category;
  final int views;
  final DateTime createdAt;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
    required this.category,
    required this.views,
    required this.createdAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      videoUrl: json['video_url'] ?? '',
      category: json['category'] ?? '',
      views: json['views'] ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
