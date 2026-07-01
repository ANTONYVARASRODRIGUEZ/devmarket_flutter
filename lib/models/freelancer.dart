class FreelancerModel {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;
  int serviceCount;
  // 👇 Agrega estos campos nuevos
  final String? bio;
  final String? location;
  final List<String>? skills;

  FreelancerModel({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.serviceCount = 1,
    this.bio,        // 👈
    this.location,   // 👈
    this.skills,     // 👈
  });
}