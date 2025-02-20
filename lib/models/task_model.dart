class Task {
  int? id;
  String title;
  String details;
  String deadline;
  String createdAt;

  Task({this.id, required this.title, required this.details, required this.deadline, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'deadline': deadline,
      'createdAt': createdAt,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      details: map['details'],
      deadline: map['deadline'],
      createdAt: map['createdAt'],
    );
  }
}
