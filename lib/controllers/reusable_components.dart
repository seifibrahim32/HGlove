import 'dart:developer';

import 'package:flutter/material.dart';

Widget textFormField(
        {required Widget? suffixIcon,
        required String? hintText,
        required String? type,
        required TextEditingController? controller,
        required BuildContext context,
        required TextInputType kind,
        required bool isHidden}) =>
    TextFormField(
        controller: controller,
        obscureText: isHidden,
        style: Theme.of(context).textTheme.headlineSmall,
        validator: (value) {
          log('$value');
          if ((value == null || value.isEmpty) && hintText == "First Name") {
            return "Fill the first name";
          }
          if ((value == null || value.isEmpty) && hintText == "Last Name") {
            return "Fill the last name";
          }
          if ((value == null || value.isEmpty) &&
              hintText == "Confirm Password") {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Re-enter the password correctly',
                  style: TextStyle(fontFamily: "SF")),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ));
            return "Wrong Password";
          }
          if (((value == null || value.isEmpty) && hintText == "Email") ||
              (hintText == "Email" &&
                  !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~"
                  r"]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value!))) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Enter email',
                  style: TextStyle(fontFamily: "SF")),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ));
            return 'Wrong email';
          }
          if ((value == null || value.isEmpty) && type == 'login') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Fill details',
                  style: TextStyle(fontFamily: "SecularOne")),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 8),
            ));
            return 'Wrong Password';
          }
          return null;
        },
        decoration: InputDecoration(
          hintStyle:
              const TextStyle(fontFamily: "SecularOne", color: Colors.white),
          hintText: hintText,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          focusedBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ));
