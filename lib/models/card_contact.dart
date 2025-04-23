class CardContact {
  final int? id; // Optional database ID field
  final String name;
  final String phone;
  final String email;
  final String company;
  final String jobTitle;
  final String notes;

  CardContact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
    required this.jobTitle,
    required this.notes,
  });

  // Convert object to map for DB storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'company': company,
      'jobTitle': jobTitle,
      'notes': notes,
    };
  }

  // Convert map to object after retrieving from DB
  factory CardContact.fromMap(Map<String, dynamic> map) {
    return CardContact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      company: map['company'],
      jobTitle: map['jobTitle'],
      notes: map['notes'],
    );
  }
}
