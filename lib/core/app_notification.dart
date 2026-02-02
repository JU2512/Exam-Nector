class AppNotification {
  final String id;
  final String title;
  final String description;
  final String pdfPath;
  final DateTime createdAt;
  bool unread;

  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.pdfPath,
    required this.createdAt,
    this.unread = true,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "pdfPath": pdfPath,
        "createdAt": createdAt.toIso8601String(),
        "unread": unread,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      pdfPath: json["pdfPath"],
      createdAt: DateTime.parse(json["createdAt"]),
      unread: json["unread"],
    );
  }
}
