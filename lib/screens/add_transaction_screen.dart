// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../resources/utils.dart';
import '../theme/colors/app_colors.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _id;
  late double _amount;
  late DateTime _date;
  late TransactionType _type;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _id = widget.transaction!.id!;
      _title = widget.transaction!.title;
      _amount = widget.transaction!.amount;
      _date = widget.transaction!.date;
      _type = widget.transaction!.type;
    } else {
      _id = DateTime.now().toString();
      _title = '';
      _amount = 0.0;
      _date = DateTime.now();
      _type = TransactionType.ingreso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(
                      labelText: 'Concepto de la transacción'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un concepto';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value!;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: _amount == 0.0 ? "" : _amount.toString(),
                  decoration: const InputDecoration(labelText: 'Valor \$'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _amount = double.parse(value!);
                  },
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      width: size.width * 0.25,
                      height: size.height * 0.08,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.primaryColorTransparent,
                      ),
                      child: const Text(
                        "Elige un tipo de transacción",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: size.width * 0.05),
                    SizedBox(
                      width: size.width * 0.4,
                      child: DropdownButtonFormField<TransactionType>(
                        value: _type,
                        items: TransactionType.values
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(Utils().capitalize(
                                      type.toString().split('.').last)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _type = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.width * 0.05),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fecha: ${DateFormat.yMd().format(_date)}',
                      ),
                    ),
                    TextButton(
                      onPressed: _presentDatePicker,
                      child: const Text('Selecciona otra fecha'),
                    ),
                  ],
                ),
                SizedBox(
                  width: size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final transaction = TransactionModel(
                          id: _id,
                          title: _title,
                          amount: _amount,
                          date: _date,
                          type: _type,
                        );
                        if (widget.transaction == null) {
                          Provider.of<TransactionProvider>(context,
                                  listen: false)
                              .addTransaction(transaction);
                        } else {
                          Provider.of<TransactionProvider>(context,
                                  listen: false)
                              .editTransaction(transaction);
                        }
                        if (widget.transaction == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.incomeColor,
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    TablerIcons.square_rounded_check,
                                    color: AppColors.white,
                                    size: 50,
                                  ),
                                  Text(
                                    "Transacción agregada correctamente",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.primaryColor,
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    TablerIcons.square_rounded_check,
                                    color: AppColors.white,
                                    size: 50,
                                  ),
                                  Text(
                                    "Transacción editada correctamente",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }

                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(widget.transaction == null ? 'Agregar' : 'Editar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _date) {
      setState(() {
        _date = pickedDate;
      });
    }
  }
}
