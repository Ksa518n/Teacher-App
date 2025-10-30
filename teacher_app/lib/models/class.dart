class Class {
  final String id;
  final String teacherId;
  final String name;

  Class({
    required this.id,
    required this.teacherId,
    required this.name,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      name: json['class_name'] as String,
    );
  }
}
