class User {
  String name;
  String designation;
  String phone;

  User({required this.name, required this.designation, required this.phone});

  // Method to return a single string containing all properties
  String get fullInfo => '$name $designation $phone';
}
