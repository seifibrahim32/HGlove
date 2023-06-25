import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';

import '../../../controllers/cache_controllers.dart';
import '../../../controllers/network/firebase_dio_calls.dart';
import '../../../domain/models/alarm_model.dart';
import '../../../domain/models/appointment_model.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  List<AlarmModel> medicinesAlarm = [];
  List<AppointmentModel> appointments = [];

  late TextEditingController medicineName,
      medicineTime,
      medicineTips,
      doctorName,
      appointmentTime,
      appointmentLocation;

  @override
  void initState() {
    super.initState();
    medicineName = TextEditingController();
    medicineTime = TextEditingController();
    medicineTips = TextEditingController();
    doctorName = TextEditingController();
    appointmentTime = TextEditingController();
    appointmentLocation = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          elevation: 0.1,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'Appointments',
            style: TextStyle(color: Colors.green, fontFamily: 'Lora'),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  removeDataFromCache(context);
                },
                child: const Text('Log out',
                    style: TextStyle(fontFamily: 'Lora', color: Colors.green)))
          ],
        ),
        body: SingleChildScrollView(
            child: Container(
          padding: const EdgeInsets.all(8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),

            // Appointments
            Row(
              children: [
                const Text('Appointments',
                    style: TextStyle(
                        fontSize: 26.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Lora')),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.add, size: 20, color: Colors.black),
                    onPressed: () => addAppointmentDialog(context))
              ],
            ),
            const SizedBox(height: 50),
            StreamBuilder(
                stream: FirebaseAPI.instanceFirebaseFirestore
                    .collection("appointments")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.data!.docs.isEmpty) {
                    if (appointments.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          appointments.clear();
                        });
                      });
                    }
                    return Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Text('No appointments took place. Do'
                                ' you need to add?'),
                            TextButton(
                                onPressed: () {
                                  addAppointmentDialog(context);
                                },
                                child: const Text('Add an appointment.'))
                          ],
                        ));
                  } else {
                    appointments.clear();
                    for (var doc in snapshot.data!.docs) {
                      var appointmentsData = doc.data();
                      log(appointmentsData.toString());
                      appointments.add(AppointmentModel.fromJson(
                          jsonDecode(jsonEncode(appointmentsData))));
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListView.separated(
                          itemCount: appointments.length,
                          shrinkWrap: true,
                          reverse: true,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 10);
                          },
                          itemBuilder: (context, index) {
                            return Container(
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 1,
                                        offset: const Offset(
                                            0, 2), // Shadow position
                                      ),
                                    ]),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 19),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Appointment ${index + 1}',
                                        style: const TextStyle(
                                            fontSize: 14, fontFamily: 'Lora'),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        appointments[index].doctorTime!,
                                        style: const TextStyle(
                                            fontSize: 20, fontFamily: 'Lora'),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        appointments[index].doctorName!,
                                        style: const TextStyle(
                                            fontSize: 26, fontFamily: 'Lora'),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(appointments[index].location!)
                                    ]));
                          },
                        ),
                      ],
                    );
                  }
                }),

            const SizedBox(height: 50),

            //Medicine alarms
            Row(
              children: [
                const Text('Medicines alarms',
                    style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontFamily: 'Lora')),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.add, size: 20, color: Colors.black),
                    onPressed: () => addAlarmDialog(context))
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseAPI.instanceFirebaseFirestore
                  .collection('alarms')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.data!.docs.isEmpty) {
                  if (medicinesAlarm.isNotEmpty) {
                    medicinesAlarm.clear();
                  }
                  return Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          const Text('No alarms added. Do you need to add?'),
                          TextButton(
                              onPressed: () {
                                addAlarmDialog(context);
                              },
                              child: const Text('Add some alarms')),
                        ],
                      ));
                } else {
                  if (medicinesAlarm.isNotEmpty) {
                    medicinesAlarm.clear();
                  }
                  for (var doc in snapshot.data!.docs) {
                    var alarmData = doc.data();
                    log(alarmData.toString());
                    medicinesAlarm.add(AlarmModel.fromJson(
                        jsonDecode(jsonEncode(alarmData!))));
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 2,
                        padding: const EdgeInsets.only(right: 4),
                        child: ListView.separated(
                          itemCount: medicinesAlarm.length,
                          shrinkWrap: false,
                          reverse: true,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 10);
                          },
                          itemBuilder: (context, index) {
                            return Container(
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 1,
                                        offset: const Offset(
                                            0, 2), // Shadow position
                                      ),
                                    ]),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 19),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Alarm ${index + 1}',
                                        style: const TextStyle(
                                            fontSize: 14, fontFamily: 'Lora'),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        medicinesAlarm[index].time!,
                                        style: const TextStyle(
                                            fontSize: 20, fontFamily: 'Lora'),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        medicinesAlarm[index].medicineName!,
                                        style: const TextStyle(
                                            fontSize: 26, fontFamily: 'Lora'),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(medicinesAlarm[index].medicineTips!)
                                    ]));
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ]),
        )),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future addAppointmentDialog(BuildContext context) async {
    GlobalKey<FormState> appointmentKey = GlobalKey<FormState>();
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add your appointment'),
              content: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  width: 990,
                  child: Form(
                    key: appointmentKey,
                    child: Column(
                      children: [
                        Row(children: [
                          Expanded(
                            child: TextFormField(
                              controller: doctorName,
                              validator: (name) {
                                if (name!.isEmpty) {
                                  return "Add the doctor name";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  hintText: "Doctor name"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              onTap: () async {
                                var time = await showTimePicker(
                                  context: context,
                                  cancelText: 'Cancel',
                                  initialTime: TimeOfDay.now(),
                                );
                                time == null
                                    ? appointmentTime.text = "Add time"
                                    : appointmentTime.text =
                                        '${time.hour}:${time.minute} '
                                            '${time.period.name.toUpperCase()}';
                              },
                              readOnly: true,
                              validator: (time) {
                                if (time!.isEmpty) {
                                  return "Add appointment time";
                                }
                                return null;
                              },
                              controller: appointmentTime,
                              onChanged: (value) {},
                              decoration:
                                  const InputDecoration(hintText: 'Time'),
                            ),
                          )
                        ]),
                        TextFormField(
                          maxLines: null,
                          controller: appointmentLocation,
                          decoration: InputDecoration(
                            suffixIcon: Container(
                                width: 90,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                ),
                                child: InkWell(
                                  splashColor: Colors.green,
                                  onTap: () async {
                                    await Navigator.of(context)
                                        .pushNamed('/maps-screen', arguments: {
                                      'type': 'location'
                                    }).then((location) {
                                      setState(() {
                                        appointmentLocation.text =
                                            location.toString();
                                      });
                                      log(location.toString());
                                    });
                                  },
                                  child: const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Add Location',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontFamily: 'Lora',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12)),
                                        Icon(Icons.add,
                                            size: 14, color: Colors.white70)
                                      ]),
                                )),
                            contentPadding:
                                const EdgeInsets.fromLTRB(8, 25, 8, 35.0),
                            hintText: "Location",
                          ),
                          validator: (location) {
                            if (location!.isEmpty) {
                              return "Add you location or add it from Google "
                                  "Maps"
                                  "\nby clicking on \"Add Location\" button";
                            }
                            return null;
                          },
                        ),
                        InkWell(
                          onTap: () {
                            if (appointmentKey.currentState!.validate()) {
                              List<String> formattedTime =
                                  appointmentTime.text.split(RegExp(":| "));
                              log(appointmentTime.text);
                              log(formattedTime.toList().toString());
                              FlutterAlarmClock.createAlarm(
                                  int.parse(formattedTime.first),
                                  int.parse(formattedTime.elementAt(1)),
                                  title: doctorName.text);
                              appointments.clear();
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) async {
                                await FirebaseAPI.instanceFirebaseFirestore
                                    .collection("appointments")
                                    .add(AppointmentModel(
                                            doctorName: doctorName.text,
                                            doctorTime: appointmentTime.text,
                                            location: appointmentLocation.text)
                                        .toJson())
                                    .whenComplete(() {
                                  Navigator.of(context).pop();
                                  appointmentTime.clear();
                                  doctorName.clear();
                                  appointmentLocation.clear();
                                });
                              });
                            }
                          },
                          child: Align(
                            heightFactor: 2,
                            alignment: Alignment.bottomRight,
                            child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration:
                                    const BoxDecoration(color: Colors.green),
                                child: const Text(
                                  'Set Appointment',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Lora',
                                      fontWeight: FontWeight.w700),
                                )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  Future addAlarmDialog(BuildContext context) async {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add your medicines'),
              content: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  height: 270,
                  width: 790,
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Row(children: [
                          Expanded(
                            child: TextFormField(
                              controller: medicineName,
                              validator: (name) {
                                if (name!.isEmpty) {
                                  return "Enter medicine name";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  hintText: "Medicine name"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              onTap: () async {
                                var time = await showTimePicker(
                                  context: context,
                                  cancelText: 'Cancel',
                                  initialTime: TimeOfDay.now(),
                                );
                                time == null
                                    ? medicineTime.text = "Add time"
                                    : medicineTime.text =
                                        '${time.hour}:${time.minute} '
                                            '${time.period.name.toUpperCase()}';
                              },
                              controller: medicineTime,
                              validator: (time) {
                                if (time!.isEmpty || time == "Add time") {
                                  return "Enter taking time";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: "Add time",
                              ),
                            ),
                          )
                        ]),
                        const SizedBox(height: 10),
                        TextFormField(
                          validator: (tips) {
                            if (tips!.isEmpty) {
                              return "Enter some tips";
                            }
                            return null;
                          },
                          controller: medicineTips,
                          maxLines: 4,
                          onChanged: (value) {
                            log(medicineTips.text);
                          },
                          decoration: const InputDecoration(
                            suffixIconColor: Colors.black,
                            hintText: "Medicine Tips",
                          ),
                        ),
                        // Set alarm
                        Container(
                            margin: const EdgeInsets.fromLTRB(140, 45, 10, 12),
                            padding: const EdgeInsets.all(5),
                            decoration:
                                const BoxDecoration(color: Colors.green),
                            child: InkWell(
                              onTap: () {
                                if (formKey.currentState!.validate()) {
                                  List<String> formattedTime =
                                      medicineTime.text.split(RegExp(":| "));
                                  FlutterAlarmClock.createAlarm(
                                      int.parse(formattedTime.first),
                                      int.parse(formattedTime.elementAt(1)));
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) async {
                                    await FirebaseAPI.instanceFirebaseFirestore
                                        .collection("alarms")
                                        .add(AlarmModel(
                                                medicineName: medicineName.text,
                                                time: medicineTime.text,
                                                medicineTips: medicineTips.text)
                                            .toJson())
                                        .whenComplete(() {
                                      medicineTime.clear();
                                      medicineName.clear();
                                      medicineTips.clear();
                                    });
                                  });
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text(
                                'Set alarm',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }
}
