import 'package:flutter/material.dart';

class LanguagesScreen extends StatelessWidget {
  const LanguagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 1,
            backgroundColor: Colors.lightGreen,
            centerTitle: true,
            title: const Text('Select your app language'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Material(
                    elevation: 1,
                    shadowColor: Colors.black,
                    type: MaterialType.button,
                    color: Colors.grey[50],
                    child: ListTile(
                      leading: Text('Arabic'),
                      trailing: Icon(Icons.check),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Material(
                    elevation: 1,
                    shadowColor: Colors.black,
                    type: MaterialType.button,
                    color: Colors.grey[50],
                    child: ListTile(
                      leading: Text('English'),
                      trailing: Icon(Icons.check, color: Colors.blue),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
