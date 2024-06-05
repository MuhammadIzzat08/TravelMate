import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controller/expense.dart';
import '../Model/expense.dart';

/*
class ExpenseView extends StatefulWidget {
  final String tripRoomId;

  ExpenseView({required this.tripRoomId});

  @override
  _ExpenseViewState createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<ExpenseView> {
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paidByController = TextEditingController();
  final List<String> selectedParticipants = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expenses')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<ExpenseController>(
        builder: (context, controller, child) { // Ensure ExpenseController provider is available here
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = controller.expenses[index];
                    return ListTile(
                      title: Text(expense.purpose),
                      subtitle: Text('Amount: ${expense.amount}, Paid by: ${expense.paidBy}'),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(controller: purposeController, decoration: InputDecoration(labelText: 'Purpose')),
                    TextField(controller: amountController, decoration: InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
                    TextField(controller: paidByController, decoration: InputDecoration(labelText: 'Paid by')),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        final purpose = purposeController.text;
                        final amount = double.parse(amountController.text);
                        final paidBy = paidByController.text;
                        await _showParticipantsDialog(context, widget.tripRoomId);
                        controller.addExpense(widget.tripRoomId, purpose, amount, paidBy, selectedParticipants);
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Text('Add Expense'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showParticipantsDialog(BuildContext context, String tripRoomId) async {
    final List<String> participants = await Provider.of<ExpenseController>(context, listen: false).getParticipants(tripRoomId);
    selectedParticipants.clear();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Participants'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: participants.map((participant) {
                  return CheckboxListTile(
                    title: Text(participant),
                    value: selectedParticipants.contains(participant),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          selectedParticipants.add(participant);
                        } else {
                          selectedParticipants.remove(participant);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}*/

/*class ExpenseView extends StatefulWidget {
  final String tripRoomId;

  ExpenseView({required this.tripRoomId});

  @override
  _ExpenseViewState createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<ExpenseView> {
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paidByController = TextEditingController();
  final List<String> selectedParticipants = [];
  final ExpenseController _expenseController = ExpenseController();

  List<String> _participants = []; // Store the list of participants

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  // Load participants from Firestore
  Future<void> _loadParticipants() async {
    final participants = await _expenseController.getParticipants(widget.tripRoomId);
    setState(() {
      _participants = participants;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold setup
    return Scaffold(
      appBar: AppBar(title: Text('Expenses')),
      body: Column(
        children: [
          // Expense list
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: _expenseController.getExpenses(widget.tripRoomId),
              builder: (context, AsyncSnapshot<List<Expense>> snapshot) { // Update here
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final expenses = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      title: Text(expense.purpose),
                      subtitle: Text('Amount: ${expense.amount}, Paid by: ${expense.paidBy}'),
                    );
                  },
                );
              },
            ),
          ),
          // Expense input form
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Input fields
                TextField(controller: purposeController, decoration: InputDecoration(labelText: 'Purpose')),
                TextField(controller: amountController, decoration: InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
                TextField(controller: paidByController, decoration: InputDecoration(labelText: 'Paid by')),
                // Participant selection
                if (_participants.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Participants:'),
                      Wrap(
                        children: _participants.map((participant) {
                          return FilterChip(
                            label: Text(participant),
                            selected: selectedParticipants.contains(participant),
                            onSelected: (isSelected) {
                              setState(() {
                                if (isSelected) {
                                  selectedParticipants.add(participant);
                                } else {
                                  selectedParticipants.remove(participant);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                // Add Expense button
                ElevatedButton(
                  onPressed: () {
                    final purpose = purposeController.text;
                    final amount = double.parse(amountController.text);
                    final paidBy = paidByController.text;
                    final expense = Expense(purpose: purpose, amount: amount, paidBy: paidBy, participants: selectedParticipants, id: '');
                    _expenseController.addExpense(widget.tripRoomId, expense);
                    setState(() {
                      purposeController.clear();
                      amountController.clear();
                      paidByController.clear();
                      selectedParticipants.clear();
                    });
                  },
                  child: Text('Add Expense'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/


/*class ExpenseView extends StatefulWidget {
  final String tripRoomId;

  ExpenseView({required this.tripRoomId});

  @override
  _ExpenseViewState createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<ExpenseView> {
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paidByController = TextEditingController();
  final List<String> selectedParticipants = [];
  bool isLoading = false;
  late ExpenseController _expenseController;

  @override
  void initState() {
    super.initState();
    _expenseController = ExpenseController();
    _expenseController.loadExpenses(widget.tripRoomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expenses')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _expenseController.expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenseController.expenses[index];
                return ListTile(
                  title: Text(expense.purpose),
                  subtitle: Text('Amount: ${expense.amount}, Paid by: ${expense.paidBy}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(controller: purposeController, decoration: InputDecoration(labelText: 'Purpose')),
                TextField(controller: amountController, decoration: InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
                TextField(controller: paidByController, decoration: InputDecoration(labelText: 'Paid by')),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    final purpose = purposeController.text;
                    final amount = double.parse(amountController.text);
                    final paidBy = paidByController.text;
                    await _showParticipantsDialog(context, widget.tripRoomId);
                    _expenseController.addExpense(widget.tripRoomId, purpose, amount, paidBy, selectedParticipants);
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Text('Add Expense'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showParticipantsDialog(BuildContext context, String tripRoomId) async {
    final List<String> participants = await _expenseController.getParticipants(tripRoomId);
    selectedParticipants.clear();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Participants'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: participants.map((participant) {
                  return CheckboxListTile(
                    title: Text(participant),
                    value: selectedParticipants.contains(participant),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          selectedParticipants.add(participant);
                        } else {
                          selectedParticipants.remove(participant);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}*/



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
        title: Text('Add Expense'),
        backgroundColor: Color(0xFF7A9E9F),
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


class ExpenseList extends StatefulWidget {
  final String tripRoomId;
  final String loggedInUserId;

  ExpenseList({required this.tripRoomId, required this.loggedInUserId});

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final ExpenseController _expenseController = ExpenseController();
  late Future<List<Expense>> _expensesFuture;
  late Future<Map<String, double>> _amountOwedFuture;
  Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _expensesFuture = _expenseController.loadExpenses(widget.tripRoomId);
    _amountOwedFuture = _expenseController.calculateAmountOwedByPaidBy(widget.tripRoomId, widget.loggedInUserId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
        backgroundColor: Color(0xFF7A9E9F),
      ),
      body: FutureBuilder<List<Expense>>(
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
                    ),
                  );
                }
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExpenseView(tripRoomId: widget.tripRoomId)),
          );
        },
        backgroundColor: Color(0xFF7A9E9F),
        child: Icon(Icons.add),
      ),
    );
  }
}