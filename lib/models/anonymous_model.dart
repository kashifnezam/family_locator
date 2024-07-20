class AnonymousModel {
  AnonymousModel({
    required this.currLoc,
    this.name,
    this.id,
    this.ipAddress,
    this.added,
    this.groupId,
  });

  final String currLoc;
  String? name;
  String? id;
  String? ipAddress;
  String? added;
  final List<String>? groupId;
  // Factory constructor to create a FamilyUserModel from JSON
  factory AnonymousModel.fromJson(Map<String, dynamic> json) {
    return AnonymousModel(
      currLoc: json['currLoc'] ?? '',
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      added: json['added'] ?? '',
      ipAddress: json['ipAddress'] ?? '',
      groupId: List<String>.from(json['groupId'] ?? []),
    );
  }

  // Method to convert FamilyUserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'currLoc': currLoc,
      'name': name,
      'id': id,
      'added': added,
      'ipAddress': ipAddress,
      'groupId': groupId,
    };
  }

  // Override toString() method for better representation
  @override
  String toString() {
    return 'AnonymousModel(currLoc: $currLoc, id: $id, added: $added, name: $name , ipAddress: $ipAddress, groupId: $groupId)';
  }
}
