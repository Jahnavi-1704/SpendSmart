import 'package:flutter/material.dart';
import 'dart:io';

class User_data {
  String name;
  String picture;
  String tracking_period;
  int budget;
  List expense_array;

  // constructor of user_data class
  User_data(this.name, this.picture, this.tracking_period, this.budget, this.expense_array);

  static User_data fromJson(Map<String, dynamic> json) => User_data(
    json['name'],
    json['picture'],
    json['tracking_period'],
    json['budget'],
    json['expense_array'],
  );
}

class expenses{
  String name;
  int amount;
  DateTime date;
  String receipt;

  // constructor of expenses class
  expenses(this.name, this.amount, this.date, this.receipt);
}