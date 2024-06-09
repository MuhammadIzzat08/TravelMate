/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/expense.dart';

class ExpenseController with ChangeNotifier {
  final CollectionReference expensesCollection = FirebaseFirestore.instance.collection('expenses');
  final CollectionReference tripRoomMembersCollection = FirebaseFirestore.instance.collection('UserTripRoom');

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  void loadExpenses(String tripRoomId) {
    expensesCollection.where('tripRoomId', isEqualTo: tripRoomId).snapshots().listen((snapshot) {
      _expenses = snapshot.docs.map((doc) => Expense.fromDocument(doc)).toList();
      notifyListeners();
    });
  }

  Future<List<String>> getParticipants(String tripRoomId) async {
    final querySnapshot = await tripRoomMembersCollection.where('TripRoomId', isEqualTo: tripRoomId).get();
    return querySnapshot.docs.map((doc) => doc['UserId'] as String).toList();
  }

  Future<void> addExpense(String tripRoomId, String purpose, double amount, String paidBy, List<String> participants) async {
    final split = _calculateSplit(participants, amount);
    final expense = Expense(
      id: '',
      tripRoomId: tripRoomId,
      purpose: purpose,
      amount: amount,
      paidBy: paidBy,
      participants: participants,
      split: split,
    );
    await expensesCollection.add(expense.toJson());
  }

  // Implement your split calculation logic here
  Map<String, double> _calculateSplit(List<String> participants, double amount) {
    final splitAmount = amount / participants.length;
    return Map.fromIterable(participants, key: (userId) => userId, value: (_) => splitAmount);
  }
}*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../Model/expense.dart';

/*
class ExpenseController {
  final CollectionReference expensesCollection = FirebaseFirestore.instance.collection('expenses');
  final CollectionReference tripRoomMembersCollection = FirebaseFirestore.instance.collection('UserTripRoom');
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('User');

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  Future<List<User>> getParticipants(String tripRoomId) async {
    final querySnapshot = await tripRoomMembersCollection.where('TripRoomId', isEqualTo: tripRoomId).get();
    final userIds = querySnapshot.docs.map((doc) => doc['UserId'] as String).toList();

    final userDocs = await Future.wait(userIds.map((userId) => usersCollection.doc(userId).get()));
    return userDocs.map((doc) => User.fromDocument(doc)).toList();
  }

  Future<List<Expense>> loadExpenses(String tripRoomId) async {
    QuerySnapshot snapshot = await expensesCollection.where('tripRoomId', isEqualTo: tripRoomId).get();
    return snapshot.docs.map((doc) => Expense.fromDocument(doc)).toList();
  }

  Future<void> addExpense(String tripRoomId, String purpose, double amount, String paidBy, List<String> participants) async {
    final split = _calculateSplit(participants, amount);
    final expense = Expense(
      id: '',
      tripRoomId: tripRoomId,
      purpose: purpose,
      amount: amount,
      paidBy: paidBy,
      participants: participants,
      split: split,
    );
    await expensesCollection.add(expense.toJson());
  }

  Map<String, double> _calculateSplit(List<String> participants, double amount) {
    final splitAmount = amount / participants.length;
    return Map.fromIterable(participants, key: (userId) => userId, value: (_) => splitAmount);
  }
}*/

class ExpenseController {
  final CollectionReference expensesCollection = FirebaseFirestore.instance.collection('expenses');
  final CollectionReference tripRoomMembersCollection = FirebaseFirestore.instance.collection('UserTripRoom');
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('User');

  Future<List<User>> getParticipants(String tripRoomId) async {
    final querySnapshot = await tripRoomMembersCollection.where('TripRoomId', isEqualTo: tripRoomId).get();
    final userIds = querySnapshot.docs.map((doc) => doc['UserId'] as String).toList();

    final userDocs = await Future.wait(userIds.map((userId) => usersCollection.doc(userId).get()));
    return userDocs.map((doc) => User.fromDocument(doc)).toList();
  }

  Future<List<Expense>> loadExpenses(String tripRoomId) async {
    QuerySnapshot snapshot = await expensesCollection.where('tripRoomId', isEqualTo: tripRoomId).get();
    return snapshot.docs.map((doc) => Expense.fromDocument(doc)).toList();
  }

  Future<void> addExpense(String tripRoomId, String purpose, double amount, String paidBy, List<String> participants) async {
    final split = _calculateSplit(participants, amount);
    final expense = Expense(
      id: '',
      tripRoomId: tripRoomId,
      purpose: purpose,
      amount: amount,
      paidBy: paidBy,
      participants: participants,
      split: split,
    );
    await expensesCollection.add(expense.toJson());
  }

  Map<String, double> _calculateSplit(List<String> participants, double amount) {
    final splitAmount = amount / participants.length;
    return Map.fromIterable(participants, key: (userId) => userId, value: (_) => splitAmount);
  }

  Future<Map<String, double>> calculateAmountOwedByPaidBy(String tripRoomId, String loggedInUserId) async {
    final expenses = await loadExpenses(tripRoomId);
    final filteredExpenses = expenses.where((expense) => expense.participants.contains(loggedInUserId)).toList();
    final amountOwedByPaidBy = <String, double>{};

    for (final expense in filteredExpenses) {
      if (expense.paidBy != loggedInUserId) { // Exclude amount the user owes to themselves
        final split = expense.split[loggedInUserId] ?? 0.0;
        amountOwedByPaidBy.update(expense.paidBy, (value) => value + split, ifAbsent: () => split);
      }
    }

    return amountOwedByPaidBy;
  }

  Future<String> getUserNameById(String userId) async {
    final doc = await usersCollection.doc(userId).get();
    if (doc.exists) {
      return doc['Name'];
    } else {
      return 'Unknown User';
    }
  }

  // Method to fetch the logged-in user's ID
  Future<String> getLoggedInUserId() async {
    // Get the current user from Firebase Authentication
    firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If user is authenticated, return their user ID
      return user.uid;
    } else {
      // If user is not authenticated, return an empty string or handle accordingly
      return '';
    }
  }


}
