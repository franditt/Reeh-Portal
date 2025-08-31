class Event {
  final int id;
  final int producerId;
  final String title;
  final String? description;
  final DateTime? eventDate;
  final String? eventTime; // Keep as string for simplicity with TIME type from SQL
  final double price;
  final String? thumbnailUrl;
  final String? videoUrl;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.producerId,
    required this.title,
    this.description,
    this.eventDate,
    this.eventTime,
    required this.price,
    this.thumbnailUrl,
    this.videoUrl,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      producerId: json['producer_id'] is int ? json['producer_id'] : int.parse(json['producer_id']),
      title: json['title'],
      description: json['description'],
      eventDate: json['event_date'] != null ? DateTime.parse(json['event_date']) : null,
      eventTime: json['event_time'],
      price: json['price'] is double ? json['price'] : double.parse(json['price'].toString()),
      thumbnailUrl: json['thumbnail_url'],
      videoUrl: json['video_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producer_id': producerId,
      'title': title,
      'description': description,
      'event_date': eventDate?.toIso8601String().split('T').first, // Format as YYYY-MM-DD
      'event_time': eventTime,
      'price': price,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
    };
  }
}
