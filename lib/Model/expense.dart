/*import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String tripRoomId;
  String purpose;
  double amount;
  String paidBy;
  List<String> participants;
  Map<String, double> split;

  Expense({
    required this.id,
    required this.tripRoomId,
    required this.purpose,
    required this.amount,
    required this.paidBy,
    required this.participants,
    required this.split,
  });

  factory Expense.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      tripRoomId: data['tripRoomId'],
      purpose: data['purpose'],
      amount: data['amount'],
      paidBy: data['paidBy'],
      participants: List<String>.from(data['participants']),
      split: Map<String, double>.from(data['split']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripRoomId': tripRoomId,
      'purpose': purpose,
      'amount': amount,
      'paidBy': paidBy,
      'participants': participants,
      'split': split,
    };
  }
}*/


import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String tripRoomId;
  String purpose;
  double amount;
  String paidBy;
  List<String> participants;
  Map<String, double> split;

  Expense({
    required this.id,
    required this.tripRoomId,
    required this.purpose,
    required this.amount,
    required this.paidBy,
    required this.participants,
    required this.split,
  });

  factory Expense.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      tripRoomId: data['tripRoomId'],
      purpose: data['purpose'],
      amount: data['amount'],
      paidBy: data['paidBy'],
      participants: List<String>.from(data['participants']),
      split: Map<String, double>.from(data['split']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripRoomId': tripRoomId,
      'purpose': purpose,
      'amount': amount,
      'paidBy': paidBy,
      'participants': participants,
      'split': split,
    };
  }
}

//user info model
class User {
  final String id;
  final String name;
  final String email;
  final String gender;
  final String phoneNum;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.phoneNum,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['Name'],
      email: data['Email'],
      gender: data['Gender'],
      phoneNum: data['PhoneNum'],
    );
  }
}
