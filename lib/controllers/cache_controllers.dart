
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void removeDataFromCache(BuildContext context) async {
  var pref = await SharedPreferences.getInstance();
  await FirebaseAuth.instance.signOut()
      .then((_) async => await pref.clear().then((_) =>
      Navigator.of(context).pushNamed('/log-out')));
}