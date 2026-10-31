class SubjectEntity {
  final int id;
  final String name;

  /// ARGB color used to tag the subject in lists; null means default.
  final int? colorValue;

  const SubjectEntity({required this.id, required this.name, this.colorValue});

  @override
  bool operator ==(Object other) =>
      other is SubjectEntity &&
      other.id == id &&
      other.name == name &&
      other.colorValue == colorValue;

  @override
  int get hashCode => Object.hash(id, name, colorValue);
}
