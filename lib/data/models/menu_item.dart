class MenuItem {
  final String name;

  const MenuItem({required this.name});

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      MenuItem(name: json['name'] as String);
}
