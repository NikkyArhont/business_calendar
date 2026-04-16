class ContactItem {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? email;

  ContactItem({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
  });
}
