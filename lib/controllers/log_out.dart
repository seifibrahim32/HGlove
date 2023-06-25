import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

logOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut().whenComplete(() async =>
        await Navigator.of(context).pushReplacementNamed('/log-out'));
  } on Exception catch (e) {
    print(e.toString());
  }

  Navigator.of(context).pop();
  Navigator.of(context).pushNamed('/');
}
