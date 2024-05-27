// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../transactions/transaction.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _selectedDate = widget.transaction.date;
    super.initState();
  }

  void _submitData() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      return;
    }

    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredAmount <= 0) {
      return;
    }

    Provider.of<TransactionProvider>(context, listen: false).editTransaction(
      widget.transaction.id,
      enteredTitle,
      enteredAmount,
      _selectedDate,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
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
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
