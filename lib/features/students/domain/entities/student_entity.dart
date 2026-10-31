class StudentEntity {
  final int id;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime createdAt;

  const StudentEntity({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      other is StudentEntity &&
      other.id == id &&
      other.name == name &&
      other.phone == phone &&
      other.notes == notes &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, name, phone, notes, createdAt);
}
