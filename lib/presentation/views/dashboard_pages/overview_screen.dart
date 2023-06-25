import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../controllers/cache_controllers.dart';
import '../../bloc/bloc_states.dart';
import '../../bloc/cubit_manager.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => OverviewCubit(),
        child: BlocBuilder<OverviewCubit, OverviewStates>(
          builder: (BuildContext context, state) {
            if (state is AppBarDetailsFetched) {
              return Scaffold(
                appBar: AppBar(
                  elevation: 0.1,
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  title: Text(OverviewCubit.username!,
                      style: const TextStyle(color: Colors.green)),
                  actions: [
                    TextButton(
                        onPressed: () {
                          removeDataFromCache(context);
                        },
                        child: const Text('Log out',
                            style: TextStyle(color: Colors.green)))
                  ],
                ),
                body: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[100],
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 19),
                          //Recent assessments
                          Text("Recent assessments",
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: 'SF',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 10),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('assessments')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if(!snapshot.hasData){
                                return Center(child: const CircularProgressIndicator());
                              }
                              var data = snapshot.data?.docs;
                              return ListView.separated(
                                itemCount: data!.length,
                                shrinkWrap: true,
                                reverse: true,
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 10);
                                },
                                itemBuilder: data.isEmpty
                                    ? (_, __) => const Align(
                                          alignment:
                                              AlignmentDirectional.center,
                                          child: Text("No assessments done yet",
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black,
                                              )),
                                        )
                                    : (context, index) {
                                        return Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(8)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 1,
                                                    offset: const Offset(0,
                                                        2), // Shadow position
                                                  ),
                                                ]),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 19),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Result ${index + 1}',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: 'Lora'),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    data[index]['name'],
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily: 'Lora'),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    data[index]['most_disease'],
                                                    style: TextStyle(
                                                        fontSize: 26,
                                                        fontFamily: 'Lora'),
                                                  ),
                                                ]));
                                      },
                              );
                            },
                          ),
                          const SizedBox(height: 19),
                          const SizedBox(height: 19),
                        ])),
              );
            } else if (state is AppBarDetailsNotFetched) {
              context.read<OverviewCubit>().fetchData();
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          },
        ));
  }

  @override
  void dispose() {
    super.dispose();
    log('dispose');
  }
}
