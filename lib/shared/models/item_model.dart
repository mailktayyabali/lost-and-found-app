class Item {
  final String id;
  final String title;
  final String location;
  final String description;
  final bool isLost;
  final String imageUrl;
  final String timeAgo;
  final String category;

  const Item({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.isLost,
    required this.imageUrl,
    required this.timeAgo,
    this.category = 'Other',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
