// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../transactions/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.income;

  void _submitData() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      return;
    }

    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredAmount <= 0) {
      return;
    }

    Provider.of<TransactionProvider>(context, listen: false).addTransaction(
      enteredTitle,
      enteredAmount,
      _selectedDate,
      _selectedType,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Date: ${_selectedDate.toLocal()}'.split(' ')[0],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    ).then((pickedDate) {
                      if (pickedDate == null) {
                        return;
                      }
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    });
                  },
                  child: const Text('Choose Date'),
                ),
              ],
            ),
            DropdownButton<TransactionType>(
              value: _selectedType,
              onChanged: (TransactionType? newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
              items: TransactionType.values.map((TransactionType classType) {
                return DropdownMenuItem<TransactionType>(
                  value: classType,
                  child: Text(classType.toString().split('.').last),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
