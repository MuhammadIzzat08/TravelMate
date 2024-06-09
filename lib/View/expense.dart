import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Controller/expense.dart';
import '../Model/expense.dart';

//Add expenses
class ExpenseView extends StatefulWidget {
  final String tripRoomId;

  ExpenseView({required this.tripRoomId});

  @override
  _ExpenseViewState createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<ExpenseView> {
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final ExpenseController _expenseController = ExpenseController();
  bool isLoading = false;
  List<User> participants = [];
  String? selectedPaidBy;
  List<String> selectedParticipants = [];

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    final loadedParticipants = await _expenseController.getParticipants(widget.tripRoomId);
    setState(() {
      participants = loadedParticipants;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Expenses',
          style: GoogleFonts.poppins(
            color: Color(0xFF7A9E9F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: purposeController,
              decoration: InputDecoration(
                labelText: 'Purpose',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xFF7A9E9F)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF7A9E9F)),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xFF7A9E9F)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF7A9E9F)),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text(
              'Select Paid By:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF7A9E9F),
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedPaidBy,
              onChanged: (newValue) {
                setState(() {
                  selectedPaidBy = newValue;
                });
              },
              items: participants.map((User user) {
                return DropdownMenuItem<String>(
                  value: user.id,
                  child: Text(user.name),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF7A9E9F)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Select Participants:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF7A9E9F),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  return CheckboxListTile(
                    title: Text(participant.name),
                    value: selectedParticipants.contains(participant.id),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          selectedParticipants.add(participant.id);
                        } else {
                          selectedParticipants.remove(participant.id);
                        }
                      });
                    },
                    activeColor: Color(0xFF7A9E9F),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final purpose = purposeController.text;
                  final amount = double.parse(amountController.text);
                  final paidBy = selectedPaidBy ?? '';
                  await _expenseController.addExpense(widget.tripRoomId, purpose, amount, paidBy, selectedParticipants);
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF7A9E9F),
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Add Expense',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




// Expense List //

class UnifiedExpenseView extends StatefulWidget {
  final String tripRoomId;
  final String loggedInUserId;

  UnifiedExpenseView({required this.tripRoomId, required this.loggedInUserId});

  @override
  _UnifiedExpenseViewState createState() => _UnifiedExpenseViewState();
}

class _UnifiedExpenseViewState extends State<UnifiedExpenseView> {
  final ExpenseController _expenseController = ExpenseController();
  late Future<List<Expense>> _expensesFuture;
  late Future<Map<String, double>> _amountOwedFuture;
  Expense? _selectedExpense;
  bool _isLoading = false;
  Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    setState(() {
      _expensesFuture = _expenseController.loadExpenses(widget.tripRoomId);
      _amountOwedFuture = _expenseController.calculateAmountOwedByPaidBy(widget.tripRoomId, widget.loggedInUserId);
    });
  }

  Future<String> _fetchUserName(String userId) async {
    if (_userNames.containsKey(userId)) {
      return _userNames[userId]!;
    } else {
      final userName = await _expenseController.getUserNameById(userId);
      setState(() {
        _userNames[userId] = userName;
      });
      return userName;
    }
  }

  void _showExpenseDetail(Expense expense) {
    setState(() {
      _selectedExpense = expense;
    });
  }

  void _backToList() {
    setState(() {
      _selectedExpense = null;
    });
  }

  void _navigateToAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseView(tripRoomId: widget.tripRoomId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedExpense == null ? 'Expenses' : 'Expense Details',
          style: GoogleFonts.poppins(
          color: Color(0xFF7A9E9F),
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),),
        backgroundColor: Colors.white,iconTheme: IconThemeData(color: Color(0xFF7A9E9F)),
        leading: _selectedExpense != null
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF7A9E9F)),
          onPressed: _backToList,
        )
            : null,
      ),
      body: _selectedExpense == null ? _buildExpenseList() : _buildExpenseDetail(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        backgroundColor: Color(0xFF7A9E9F),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpenseList() {
    return FutureBuilder<List<Expense>>(
      future: _expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No expenses found.'));
        } else {
          final expenses = snapshot.data!;
          final filteredExpenses = expenses.where((expense) => expense.participants.contains(widget.loggedInUserId)).toList();

          return ListView.builder(
            itemCount: filteredExpenses.length + 1, // Add 1 for the summary row
            itemBuilder: (context, index) {
              if (index == filteredExpenses.length) {
                // Summary row
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: ListTile(
                    title: Text(
                      'You Owe:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: FutureBuilder<Map<String, double>>(
                      future: _amountOwedFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error calculating amount owed: ${snapshot.error}');
                        } else {
                          final amountOwedByPaidBy = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: amountOwedByPaidBy.entries.map((entry) {
                              return FutureBuilder<String>(
                                future: _fetchUserName(entry.key),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Text('Loading...');
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Text(
                                      '${snapshot.data}: RM ${entry.value.toStringAsFixed(2)}',
                                      style: TextStyle(color: Colors.red, fontSize: 16),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ),
                );
              } else {
                final expense = filteredExpenses[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  child: ListTile(
                    title: Text(expense.purpose),
                    subtitle: FutureBuilder<String>(
                      future: _fetchUserName(expense.paidBy),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text('Amount: RM ${expense.amount} || Paid by: Loading...');
                        } else if (snapshot.hasError) {
                          return Text('Amount: RM ${expense.amount} || Paid by: Error');
                        } else {
                          return Text(
                            'Amount: RM ${expense.amount} || Paid by: ${snapshot.data}',
                            style: TextStyle(color: Colors.grey[700]),
                          );
                        }
                      },
                    ),
                    onTap: () => _showExpenseDetail(expense),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildExpenseDetail() {
    if (_selectedExpense == null) {
      return Center(child: Text('No expense selected.'));
    }
    final expense = _selectedExpense!;
    return FutureBuilder<String>(
        future: _fetchUserName(expense.paidBy),
    builder: (context, snapshot) {
    return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Purpose: ${expense.purpose}',
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF7A9E9F)),
    ),
      SizedBox(height: 16),
      Text(
        'Amount: RM ${expense.amount}',
        style: TextStyle(fontSize: 20, color: Colors.grey[700]),
      ),
      SizedBox(height: 16),
      Text(
        'Paid by: ${snapshot.connectionState == ConnectionState.waiting ? 'Loading...' : snapshot.hasError ? 'Error' : snapshot.data}',
        style: TextStyle(fontSize: 20, color: Colors.grey[700]),
      ),
      SizedBox(height: 16),
      Text(
        'Participants:',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
      ),
      ...expense.participants.map((participantId) {
        return FutureBuilder<String>(
          future: _fetchUserName(participantId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text(
                snapshot.data!,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              );
            }
          },
        );
      }).toList(),
      SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _backToList,
          child: Text('Back To List'),
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF7A9E9F),
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    ],
    ),
    );
    },
    );
  }
}



