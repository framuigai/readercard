class CardContact {
  final int? id; // Optional database ID
  final String imagePath; // NEW: Path to saved image file
  final String name;
  final String phone;
  final String email;
  final String company;
  final String jobTitle;
  final String notes;

  CardContact({
    this.id,
    required this.imagePath,
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
    required this.jobTitle,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'name': name,
      'phone': phone,
      'email': email,
      'company': company,
      'jobTitle': jobTitle,
      'notes': notes,
    };
  }

  factory CardContact.fromMap(Map<String, dynamic> map) {
    return CardContact(
      id: map['id'],
      imagePath: map['imagePath'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      company: map['company'],
      jobTitle: map['jobTitle'],
      notes: map['notes'],
    );
  }
}
