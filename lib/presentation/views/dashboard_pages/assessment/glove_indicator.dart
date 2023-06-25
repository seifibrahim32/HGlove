import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gauges/gauges.dart';

class GloveIndicatorScreen extends StatelessWidget {
  final List<RadialGaugeSegment> _segments = [
    const RadialGaugeSegment(
      minValue: 0,
      maxValue: 40,
      minAngle: -150,
      maxAngle: -130,
      color: Colors.red,
    ),
    const RadialGaugeSegment(
      minValue: 40,
      maxValue: 100,
      minAngle: -120,
      maxAngle: -90,
      color: Colors.orange,
    ),
    const RadialGaugeSegment(
      minValue: 90,
      maxValue: 100,
      minAngle: -80,
      maxAngle: 70,
      color: Colors.yellow,
    ),
    const RadialGaugeSegment(
      minValue: 100,
      maxValue: 120,
      minAngle: 80,
      maxAngle: 140,
      color: Colors.green,
    ),
  ];

  GloveIndicatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          centerTitle: true,
          title:
              const Text('Glove indicator', style: TextStyle(fontFamily: "SF")),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back)),
          elevation: 3.0,
        ),
        backgroundColor: Colors.amber,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    //sp02
                    SizedBox(
                      height: 100,
                      child: Column(
                        children: [
                          StreamBuilder(
                              stream: FirebaseDatabase.instance
                                  .ref()
                                  .child('spO2')
                                  .onValue,
                              builder: (ctx, snapshot) {
                                print(snapshot.data?.snapshot.value);
                                return RadialGauge(
                                  axes: [
                                    RadialGaugeAxis(
                                        minValue: 0,
                                        maxValue: 100,
                                        minAngle: -150,
                                        maxAngle: 150,
                                        radius: 3,
                                        pointers: [
                                          RadialNeedlePointer(
                                              thickness: 1.5,
                                              length: 3.5,
                                              color: Colors.white,
                                              thicknessStart: 10,
                                              value: double.parse(snapshot
                                                  .data!.snapshot.value
                                                  .toString()))
                                        ],
                                        width: 1,
                                        segments: _segments),
                                  ],
                                  radius: 15,
                                );
                              }),
                          const Text('spO2 %',
                              style: TextStyle(fontFamily: "SF")),
                        ],
                      ),
                    ),
                    //heartRate
                    SizedBox(
                      height: 100,
                      child: Column(
                        children: [
                          StreamBuilder(
                              stream: FirebaseDatabase.instance
                                  .ref()
                                  .child('heartRate')
                                  .onValue,
                              builder: (ctx, snapshot) {
                                print(snapshot.data?.snapshot.value);
                                return RadialGauge(
                                  axes: [
                                    RadialGaugeAxis(
                                        minValue: 0,
                                        maxValue: 100,
                                        minAngle: -150,
                                        maxAngle: 150,
                                        radius: 3,
                                        width: 1,
                                        pointers: [
                                          RadialNeedlePointer(
                                              thickness: 1.5,
                                              length: 3.5,
                                              color: Colors.white,
                                              thicknessStart: 10,
                                              value: double.parse(snapshot
                                                  .data!.snapshot.value
                                                  .toString()))
                                        ],
                                        segments: _segments),
                                  ],
                                  radius: 15,
                                );
                              }),
                          const Text('heartRate',
                              style: TextStyle(fontFamily: "SF")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 100,
                child: Column(
                  children: [
                    StreamBuilder(
                        stream: FirebaseDatabase.instance
                            .ref()
                            .child('temperature')
                            .onValue,
                        builder: (ctx, snapshot) {
                          print(snapshot.data?.snapshot.value);
                          return RadialGauge(
                            axes: [
                              RadialGaugeAxis(
                                  minValue: 0,
                                  maxValue: 100,
                                  minAngle: -150,
                                  maxAngle: 150,
                                  radius: 6,
                                  width: 1,
                                  pointers: [
                                    RadialNeedlePointer(
                                        thickness: 1.5,
                                        color: Colors.white,
                                        length: 3.5,
                                        thicknessStart: 10,
                                        value: double.parse(snapshot
                                            .data!.snapshot.value
                                            .toString()))
                                  ],
                                  segments: _segments),
                            ],
                            radius: 15,
                          );
                        }),
                    const Text('Temperature',
                        style: TextStyle(fontFamily: "SF")),
                  ],
                ),
              ),
            ]));
  }
}
