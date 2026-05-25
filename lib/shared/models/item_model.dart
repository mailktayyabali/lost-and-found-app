class Item {
  final String id;
  final String title;
  final String location;
  final String description;
  final bool isLost;
  final String imageUrl;
  final String timeAgo;
  final String category;
  final String status; // 'LOST', 'FOUND', 'RESOLVED', 'ACTIVE'
  final String? createdBy;
  final String? reporterName;
  final String? reporterEmail;
  final String? reporterPhone;

  const Item({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.isLost,
    required this.imageUrl,
    required this.timeAgo,
    this.category = 'Other',
    this.status = 'ACTIVE',
    this.createdBy,
    this.reporterName,
    this.reporterEmail,
    this.reporterPhone,
  });

  factory Item.fromJson(Map<String, dynamic> json, String docId) {
    return Item(
      id: docId,
      title: json['title'] ?? json['itemName'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      isLost: json['isLost'] ?? true,
      imageUrl: json['imageUrl'] ?? '',
      timeAgo: json['timeAgo'] ?? 'some time ago',
      category: json['category'] ?? 'Other',
      status: json['status'] ?? ((json['isLost'] ?? true) ? 'LOST' : 'FOUND'),
      createdBy: json['createdBy'],
      reporterName: json['reporterName'],
      reporterEmail: json['reporterEmail'],
      reporterPhone: json['reporterPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'itemName': title,
      'location': location,
      'description': description,
      'isLost': isLost,
      'imageUrl': imageUrl,
      'timeAgo': timeAgo,
      'category': category,
      'status': status,
      'createdBy': createdBy,
      'reporterName': reporterName,
      'reporterEmail': reporterEmail,
      'reporterPhone': reporterPhone,
    };
  }

  Item copyWith({
    String? id,
    String? title,
    String? location,
    String? description,
    bool? isLost,
    String? imageUrl,
    String? timeAgo,
    String? category,
    String? status,
    String? createdBy,
    String? reporterName,
    String? reporterEmail,
    String? reporterPhone,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      isLost: isLost ?? this.isLost,
      imageUrl: imageUrl ?? this.imageUrl,
      timeAgo: timeAgo ?? this.timeAgo,
      category: category ?? this.category,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      reporterName: reporterName ?? this.reporterName,
      reporterEmail: reporterEmail ?? this.reporterEmail,
      reporterPhone: reporterPhone ?? this.reporterPhone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
