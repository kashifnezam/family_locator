class UserModel {
  UserModel({
    required this.currLoc,
    this.name,
    this.email,
    this.added,
    this.groupId,
    this.pendingReq,
    this.sentReq,
    this.updated,
    this.friends,
  });

  final String currLoc;
  String? name;
  String? added;
  String? email;
  final List<String>? groupId;
  final List<String>? pendingReq;
  final List<String>? sentReq;
  final String? updated;
  final List<String>? friends;

  // Factory constructor to create a FamilyUserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      currLoc: json['currLoc'] ?? '',
      name: json['name'] ?? '',
      added: json['added'] ?? '',
      email: json['email'] ?? '',
      groupId: List<String>.from(json['groupId'] ?? []),
      pendingReq: List<String>.from(json['pendingReq'] ?? []),
      sentReq: List<String>.from(json['sentReq'] ?? []),
      updated: json['updated'] ?? '',
      friends: List<String>.from(json['friends'] ?? []),
    );
  }

  // Method to convert FamilyUserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'currLoc': currLoc,
      'name': name,
      'added': added,
      'email': email,
      'groupId': groupId,
      'pendingReq': pendingReq,
      'sentReq': sentReq,
      'updated': updated,
      'friends': friends,
    };
  }

  // Override toString() method for better representation
  @override
  String toString() {
    return 'UserModel(currLoc: $currLoc, name: $name, added: $added, groupId: $groupId, pendingReq: $pendingReq, sentReq: $sentReq, updated: $updated, friends: $friends)';
  }
}
