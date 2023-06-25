import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/bloc_states.dart';
import '../../../bloc/cubit_manager.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();

  final _editKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.green,
          elevation: 0.7,
          centerTitle: true,
          title: const Text('Edit your profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                if (_editKey.currentState!.validate()) {
                  final data = await SharedPreferences.getInstance();
                  final photoInstance = FirebaseStorage.instance;
                  String? email = data.getString("email");
                  String? uid = data.getString("uid");
                  photoInstance.ref(email).delete().then((_) {
                    photoInstance
                        .ref()
                        .child(email!)
                        .putFile(File(EditProfileCubit.photoLink))
                        .then((snapshot) async {
                      await snapshot.ref
                          .getDownloadURL()
                          .then((imageURL) async {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(uid)
                            .update({
                          'imageURL': imageURL,
                          'bmi': _bmiController.text
                        }).whenComplete(() {
                          data.setString("photo", imageURL);
                          data.setString("bmi", _bmiController.text);
                          data.setString("age", _ageController.text);
                          Navigator.pop(context);
                        });
                      });
                    });
                  });
                }
              },
            )
          ],
        ),
        body: BlocProvider<EditProfileCubit>(
          create: (BuildContext context) => EditProfileCubit(),
          child: BlocBuilder<EditProfileCubit, EditProfileStates>(
            builder: (context, state) {
              return Form(
                key: _editKey,
                child: SingleChildScrollView(
                  child: Column(children: [
                    const SizedBox(height: 10),
                    //Profile Picture
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BlocBuilder<EditProfileCubit, EditProfileStates>(
                          builder: (BuildContext context, state) {
                            if (state is ProfileDataIsNotFetched) {
                              BlocProvider.of<EditProfileCubit>(context)
                                  .fetchData();
                              return ClipRRect(
                                  borderRadius: BorderRadius.circular(64.0),
                                  child: Image.asset(
                                      'assets/blank-profile.webp',
                                      scale: 10.0));
                            }
                            else if (state is ProfileDataIsEdited) {
                              return Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  ClipRRect(
                                      clipBehavior: Clip.antiAlias,
                                      borderRadius: BorderRadius.circular(64.0),
                                      child: Image.network(
                                          width: 150,
                                          height: 150,
                                          EditProfileCubit.photoLink,
                                          scale: 2,
                                          errorBuilder: (ctx, object, index) {
                                            return const CircularProgressIndicator();
                                          }
                                      )
                                  ),
                                  InkWell(
                                    child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.greenAccent,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 10, 5, 5),
                                        child: IconButton(
                                          padding: const EdgeInsets.all(0.0),
                                          icon: const Icon(Icons.edit),
                                          iconSize: 23,
                                          color: Colors.white,
                                          onPressed: () async {
                                            context
                                                .read<EditProfileCubit>()
                                                .change(context);
                                          },
                                        )),
                                  ),
                                ],
                              );
                            }
                            else {
                              return Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(64.0),
                                      child: kIsWeb
                                          ? Image.memory(
                                          BlocProvider
                                              .of<
                                              PhotoRegistrationCubit>(
                                              context)
                                              .hashCode as Uint8List,
                                          errorBuilder: (ctx, object, index) {
                                            return const CircularProgressIndicator();
                                          }, scale: 4.0)
                                          : Image.file(
                                          width: 150,
                                          height: 150,
                                          File(EditProfileCubit.photoLink),
                                          errorBuilder: (ctx, object, index) {
                                            return const CircularProgressIndicator();
                                          }, scale: 0.1)),
                                  InkWell(
                                    child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.greenAccent,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 10, 5, 5),
                                        child: IconButton(
                                          padding: const EdgeInsets.all(0.0),
                                          icon: const Icon(Icons.edit),
                                          iconSize: 23,
                                          color: Colors.white,
                                          onPressed: () async {
                                            context
                                                .read<EditProfileCubit>()
                                                .change(context);
                                          },
                                        )),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    //First Name
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        style: const TextStyle(color: Colors.grey),
                        controller: firstNameController,
                        decoration: InputDecoration(
                            labelText: 'First Name',
                            hintText: EditProfileCubit.firstName,
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            hintStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusColor: Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Rewrite your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    //Last Name
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        style: const TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                            hintText: EditProfileCubit.lastName,
                            labelText: 'Last Name',
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusColor: Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Last Name';
                          }
                          return null;
                        },
                      ),
                    ),
                    //Emergency Number
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: null,
                        style: const TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                            hintText: EditProfileCubit.emergencyNumber,
                            labelText: 'Primary Emergency Number',
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusColor: Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Rewrite Emergency number';
                          }
                          return null;
                        },
                      ),
                    ),
                    //Age
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(
                            hintText: '21',
                            labelText: 'Age',
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusColor: Colors.black),
                        style: const TextStyle(color: Colors.grey),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Incorrect';
                          }
                          return null;
                        },
                      ),
                    ),
                    //BMI
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _bmiController,
                        style: const TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                            hintText: '120.0',
                            labelText: 'BMI',
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusColor: Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Rewrite the BMI';
                          }
                          return null;
                        },
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
