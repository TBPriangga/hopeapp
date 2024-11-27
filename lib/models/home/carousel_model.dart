class CarouselModel {
  final String id;
  final String imageUrl;
  final String? linkUrl; // Bisa null jika tidak ada link
  final String? linkType; // 'internal' atau 'external' atau null
  final String?
      internalRoute; // Rute internal aplikasi jika linkType = 'internal'
  final DateTime createdAt;
  final bool isActive; // Untuk control active/non-active slide

  CarouselModel({
    required this.id,
    required this.imageUrl,
    this.linkUrl,
    this.linkType,
    this.internalRoute,
    required this.createdAt,
    this.isActive = true,
  });

  factory CarouselModel.fromMap(String id, Map<String, dynamic> map) {
    return CarouselModel(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      linkUrl: map['linkUrl'],
      linkType: map['linkType'],
      internalRoute: map['internalRoute'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'linkType': linkType,
      'internalRoute': internalRoute,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }
}
