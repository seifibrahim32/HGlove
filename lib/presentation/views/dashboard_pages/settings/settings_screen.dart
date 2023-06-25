import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../controllers/cache_controllers.dart';
import '../../../../controllers/send_emails.dart';
import '../../../bloc/bloc_states.dart';
import '../../../bloc/cubit_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDark = false;
  String? imageURL, email;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.6,
        centerTitle: true,
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: isDark ? Colors.green[100] : Colors.grey[100],
        child: BlocProvider(
            create: (context) => SettingsCubit(),
            child: BlocBuilder<SettingsCubit, SettingsScreenStates>(
                builder: (context, state) {
              if (state is ProfileDetailsNotFetched) {
                context.read<SettingsCubit>().fetchData();
                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: ListView(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const Row(children: [
                                Text('Account',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 19,
                                        color: Colors.black))
                              ]),
                              const SizedBox(height: 13),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  onTap: () async {
                                    log('/profile');
                                    await Navigator.of(context)
                                        .pushNamed('/profile');
                                  },
                                  title: const Text('Edit Profile',
                                      style: TextStyle(color: Colors.black)),
                                  trailing: const Icon(Icons.arrow_forward),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: SwitchListTile(
                                  title: const Text('Dark Mode (beta)',
                                      style: TextStyle(color: Colors.black)),
                                  value: isDark,
                                  onChanged: (bool value) {
                                    setState(() {
                                      context
                                          .read<SettingsCubit>()
                                          .setDarkMode(value);
                                      isDark = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  onTap: () async {
                                    log('/languages');
                                    await Navigator.of(context)
                                        .pushNamed('/languages');
                                  },
                                  title: const Text('Languages (beta)',
                                      style: TextStyle(color: Colors.black)),
                                  trailing: const Icon(Icons.arrow_forward),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  onTap: () async {
                                    log('/about');
                                    await Navigator.of(context)
                                        .pushNamed('/about');
                                  },
                                  title: const Text('About',
                                      style: TextStyle(color: Colors.black)),
                                  trailing: const Icon(Icons.arrow_forward),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  sendEmail();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const ListTile(
                                    title: Text('Report an issue',
                                        style: TextStyle(color: Colors.black)),
                                    trailing: Icon(Icons.arrow_forward),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  removeDataFromCache(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const ListTile(
                                    title: Text('Log out',
                                        style: TextStyle(color: Colors.black)),
                                    trailing: Icon(Icons.arrow_forward),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    )
                  ],
                );
              }
              return Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            SettingsCubit.imageURL!,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(SettingsCubit.email!),
                              Text(SettingsCubit.username!,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700))
                            ])
                      ]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: ListView(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const Row(children: [
                              Text('Account',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 19,
                                      color: Colors.black))
                            ]),
                            const SizedBox(height: 13),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: ListTile(
                                onTap: () async {
                                  log('/profile');
                                  await Navigator.of(context)
                                      .pushNamed('/profile');
                                },
                                title: const Text('Edit Profile',
                                    style: TextStyle(color: Colors.black)),
                                trailing: const Icon(Icons.arrow_forward),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: SwitchListTile(
                                title: const Text('Dark Mode (beta)',
                                    style: TextStyle(color: Colors.black)),
                                value: isDark,
                                onChanged: (bool value) {
                                  setState(() {
                                    isDark = value;
                                  });
                                  log(value.toString());
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: ListTile(
                                onTap: () async {
                                  log('/languages');
                                  await Navigator.of(context)
                                      .pushNamed('/languages');
                                },
                                title: const Text('Languages (beta)',
                                    style: TextStyle(color: Colors.black)),
                                trailing: const Icon(Icons.arrow_forward),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: ListTile(
                                onTap: () async {
                                  log('/about');
                                  await Navigator.of(context)
                                      .pushNamed('/about');
                                },
                                title: const Text('About',
                                    style: TextStyle(color: Colors.black)),
                                trailing: const Icon(Icons.arrow_forward),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                sendEmail();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: const ListTile(
                                  title: Text('Report an issue',
                                      style: TextStyle(color: Colors.black)),
                                  trailing: Icon(Icons.arrow_forward),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async => await Navigator.of(context)
                                  .pushReplacementNamed('/log-out'),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: const ListTile(
                                  title: Text('Log out',
                                      style: TextStyle(color: Colors.black)),
                                  trailing: Icon(Icons.arrow_forward),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  )
                ],
              );
            })),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    log('dispose');
  }
}
