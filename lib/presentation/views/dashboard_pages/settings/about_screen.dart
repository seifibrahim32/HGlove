import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text('About'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: const Center(
            child: Text(
          'The project is implemented by\n'
          'Seif Ashraf\n'
          'Omar Rashad\n'
          'Rawan Mohamed\n@2023 All rights reserved...',
          textAlign: TextAlign.center,
        )));
  }
}
