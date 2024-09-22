class AnonymousModel {
  AnonymousModel({
    required this.currLoc,
    this.id,
    this.macAd,
    this.ipAddress,
    this.added,
    this.groupId,
  });

  final String currLoc;
  String? id;
  String? macAd;
  String? ipAddress;
  String? added;
  final List<String>? groupId;
  // Factory constructor to create a FamilyUserModel from JSON
  factory AnonymousModel.fromJson(Map<String, dynamic> json) {
    return AnonymousModel(
      currLoc: json['currLoc'] ?? '',
      id: json['id'] ?? '',
      macAd: json['macAd'] ?? '',
      added: json['added'] ?? '',
      ipAddress: json['ipAddress'] ?? '',
      groupId: List<String>.from(json['groupId'] ?? []),
    );
  }

  // Method to convert FamilyUserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'currLoc': currLoc,
      'id': id,
      'macAd': macAd,
      'added': added,
      'ipAddress': ipAddress,
      'groupId': groupId,
    };
  }

  // Override toString() method for better representation
  @override
  String toString() {
    return 'AnonymousModel(currLoc: $currLoc, id: $id, macAd: $macAd, added: $added, , ipAddress: $ipAddress, groupId: $groupId)';
  }
}
