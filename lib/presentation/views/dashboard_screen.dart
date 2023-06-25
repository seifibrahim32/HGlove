import 'dart:developer';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:health_diagnosis/presentation/views/registration/login_screen'
    '.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:timelines/timelines.dart';

import 'advices_screen.dart';
import 'dashboard_pages/appointment_screen.dart';
import 'dashboard_pages/assessment/assessment_screen.dart';
import 'dashboard_pages/diagnosis_screen.dart';
import 'dashboard_pages/overview_screen.dart';
import 'dashboard_pages/settings/about_screen.dart';
import 'dashboard_pages/settings/edit_profile.dart';
import 'dashboard_pages/settings/languages_screen.dart';
import 'dashboard_pages/settings/settings_screen.dart';
import 'maps/maps_screen.dart';
import 'navigators/bottom_navigator_bar.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad
      };
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Initial Selected Value
  String dropdownValue = 'Profile settings';

  int currentIndex = 0;

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  // List of items in our dropdown menu for desktop
  var items = [
    'Profile settings',
    'Log out',
  ];

  final ScrollController _tableVerticalController = ScrollController();

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> pages = const [
    DiagnosisScreen(),
    OverviewScreen(),
    AppointmentScreen(),
    SettingsScreen()
  ];

  static final controller = PageController(
    initialPage: 0,
  );

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/assessment': (_) => const AssessmentScreen(),
        '/profile': (_) => const EditProfileScreen(),
        '/log-out': (_) => const LoginScreen(),
        '/languages': (_) => const LanguagesScreen(),
        '/maps-screen': (mapsContext){
          final arguments = (ModalRoute.of(mapsContext)?.settings.arguments ??
              <String, dynamic>{}) as Map;
            log("arguments dashboard_screen.dart: ${arguments.toString()}");

          return MapsScreen(kind: arguments['type']);
        },
        '/about': (_) => const AboutScreen(),
        '/diabetes-advices': (_) => AdvicesScreen(1),
        '/blood-advices': (_) => AdvicesScreen(2),
      },
      home: ScreenTypeLayout.builder(
        mobile:  (_)=> Scaffold(
          body: Column(children: [
            Expanded(
              child: PageView(
                controller: controller,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => {
                  setState(() {
                    log(index.toString());
                    currentIndex = index;
                  })
                },
                children: pages,
              ),
            )
          ]),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.black,
            items: bottomNavigatorBarItems(currentIndex: currentIndex),
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (index) {
              setState(() {
                currentIndex = index;
                controller.animateToPage(index,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.linear);
              });
            },
            selectedIconTheme: const IconThemeData(color: Colors.black),
          ),
        ),
        desktop: (_)=> Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Text('HGlove',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18)),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Overview',
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Appointment',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Medical Report',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Medical Test',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Doctors',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ]),
                    const Spacer(flex: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {},
                          padding: const EdgeInsets.all(0.0),
                          icon: const Icon(Icons.notifications_none),
                        ),
                        IconButton(
                          onPressed: () {},
                          padding: const EdgeInsets.all(0.0),
                          icon: const Icon(Icons.settings),
                        ),
                        const CircleAvatar(
                          radius: 15,
                        ),
                        const SizedBox(width: 9),
                        Container(
                          color: Colors.transparent,
                          child: DropdownButton(
                            isDense: true,
                            borderRadius: BorderRadius.circular(12),
                            elevation: 2,
                            underline: Container(height: 0),
                            value: dropdownValue,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: items.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ]),
              const SizedBox(height: 5),
              Container(
                decoration: const BoxDecoration(color: Colors.grey),
                width: double.infinity,
                height: 2,
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //left
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 611,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(5)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Diagnosis History',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.more_vert)
                                ]),
                            const SizedBox(height: 13),
                            Expanded(
                              child: Row(children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ScrollConfiguration(
                                          behavior:
                                              ScrollConfiguration.of(context)
                                                  .copyWith(scrollbars: true),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: 1,
                                            controller:
                                                _tableVerticalController,
                                            itemBuilder: (context, index) {
                                              return TimelineTheme(
                                                data: TimelineThemeData(
                                                    color: Colors.grey),
                                                child:
                                                    FixedTimeline.tileBuilder(
                                                  builder: TimelineTileBuilder
                                                      .connectedFromStyle(
                                                    contentsAlign: ContentsAlign
                                                        .alternating,
                                                    connectorStyleBuilder:
                                                        (context, index) {
                                                      return (index == 1)
                                                          ? ConnectorStyle
                                                              .dashedLine
                                                          : ConnectorStyle
                                                              .solidLine;
                                                    },
                                                    indicatorStyleBuilder:
                                                        (context, index) =>
                                                            IndicatorStyle.dot,
                                                    itemExtent: 40.0,
                                                    itemCount: 72,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Lottie.asset('assets/96127-search.json'),
                              ]),
                            )
                          ]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  //right
                  Expanded(
                    flex: 2,
                    child: Column(children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //green
                            Column(children: [
                              Container(
                                  padding: const EdgeInsets.all(11),
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: const Offset(0, 3),
                                          // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Blood Pressure'),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text('Normal'),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text('119/80'),
                                              Text('mmHg'),
                                            ])
                                      ])
                              ),
                              const SizedBox(height: 10),
                              Container(
                                  padding: const EdgeInsets.all(11),
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Heart Rate'),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text('Checkup Now'),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text('119/80'),
                                              Text('mmHg'),
                                            ])
                                      ])),
                            ]),
                            const SizedBox(width: 10),
                            // green
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(11),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 7,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('Heart Rate'),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Text('Checkup Now'),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text('119/80'),
                                                  Text('mmHg'),
                                                ])
                                          ])),
                                  const SizedBox(height: 10),
                                  Container(
                                      padding: const EdgeInsets.all(11),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: const Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('Waters'),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Text('Normal'),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text('3.25'),
                                                  Text('Liters'),
                                                ])
                                          ])
                                  ),
                                ]),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 170,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: true,
                                      horizontalInterval: 1,
                                      verticalInterval: 1,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: const Color(0xff37434d),
                                          strokeWidth: 1,
                                        );
                                      },
                                      getDrawingVerticalLine: (value) {
                                        return FlLine(
                                          color: const Color(0xff37434d),
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          interval: 1,
                                          getTitlesWidget: bottomTitleWidgets,
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 1,
                                          getTitlesWidget: leftTitleWidgets,
                                          reservedSize: 42,
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(
                                          color: const Color(0xff37434d)),
                                    ),
                                    minX: 0,
                                    maxX: 11,
                                    minY: 0,
                                    maxY: 6,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: const [
                                          FlSpot(11, 4),
                                        ],
                                        isCurved: true,
                                        gradient: LinearGradient(
                                          colors: gradientColors,
                                        ),
                                        barWidth: 5,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: false,
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: gradientColors
                                                .map((color) =>
                                                    color.withOpacity(0.3))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  swapAnimationDuration:
                                      const Duration(milliseconds: 150),
                                  // Optional
                                  swapAnimationCurve: Curves.linear, // Optional
                                ),
                              ),
                            ),
                          ]),
                      const SizedBox(height: 10),
                      Container(
                        height: 311,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ]),
                        child: Column(children: [
                          const Row(children: [
                            Text('List Alerts',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            Spacer(),
                            TextField(
                              decoration: InputDecoration(
                                constraints: BoxConstraints(
                                  maxHeight: 48,
                                  maxWidth: 207,
                                ),
                                border: OutlineInputBorder(),
                                hintText: 'Search',
                                prefixIcon:
                                    Icon(Icons.search, color: Colors.black),
                                isDense: true,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 9),
                          Expanded(
                            child: ListView(children: [
                              DataTable(
                                columnSpacing: 100,
                                columns: const [
                                  DataColumn(
                                    label: Text('Date'),
                                  ),
                                  DataColumn(
                                    label: Text('Checkup Time'),
                                  ),
                                  DataColumn(
                                    label: Text('Blood Glucose'),
                                  ),
                                  DataColumn(
                                    label: Text('Heart Rate'),
                                  ),
                                  DataColumn(
                                    label: Text('Summary Status'),
                                  ),
                                ],
                                rows: const [
                                  DataRow(cells: [
                                    DataCell(Text('dd')),
                                    DataCell(Text('dd')),
                                    DataCell(Text('dd')),
                                    DataCell(Text('dd')),
                                    DataCell(Text('dd'))
                                  ]),
                                ],
                              )
                            ]),
                          )
                        ]),
                      ),
                    ]),
                  )
                ],
              ),
            ]),
          ),
        ),
        breakpoints: const ScreenBreakpoints(
          desktop: 630,
          tablet: 12,
          watch: 12,
        ),
      ),
    );
  }
}
