import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controllers/services/services.dart';
import '../../bloc/bloc_states.dart';
import '../../bloc/cubit_manager.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late int index;
  String? user = 'user';
  late Material materialButton;

  @override
  void initState() {
    super.initState();
    index = 0;
    getUsernameFromCache();
  }

  getUsernameFromCache() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    user = prefs.getString('username');
    setState(() {
      if (kDebugMode) {
        print('firstName ${user!}');
      }
    });
  }

  Material _skipButton({void Function(int)? setIndex}) {
    return Material(
      borderRadius: defaultSkipButtonBorderRadius,
      color: defaultSkipButtonColor,
      child: InkWell(
        borderRadius: defaultSkipButtonBorderRadius,
        onTap: () {
          if (setIndex != null) {
            index = 3;
            setIndex(3);
          }
          BackgroundServices.enableNotificationService();
        },
        child: const Padding(
          padding: defaultSkipButtonPadding,
          child: Text(
            'Skip',
            style: defaultSkipButtonTextStyle,
          ),
        ),
      ),
    );
  }

  Material get _dashboardButton {
    return Material(
      borderRadius: defaultProceedButtonBorderRadius,
      color: defaultProceedButtonColor,
      child: InkWell(
        borderRadius: defaultProceedButtonBorderRadius,
        onTap: () {
          Navigator.pushReplacementNamed(context, '/dashboard');
        },
        child: const Padding(
          padding: defaultProceedButtonPadding,
          child: Text(
            '>>',
            style: defaultProceedButtonTextStyle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF112F2F),
        body: Column(children: [
          BlocProvider(
              lazy: false,
              create: (BuildContext context) => RegistrationCubit(),
              child: BlocBuilder<RegistrationCubit, ScreenStates>(
                  builder: (context, state) {
                return Expanded(
                  child: Onboarding(
                    onPageChange: (pageIndex) {
                      index = pageIndex;
                    },
                    startPageIndex: 0,
                    pages: [
                      PageModel(
                        widget: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Lottie.asset(
                              'assets/healthcare-loader.json',
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Welcome  ${user!},\nUse HGlove anytime,anywhere',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontFamily: 'Lora',
                                    color: Colors.white,
                                    fontSize: 25),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      PageModel(
                        widget: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/96127-search.json',
                            ),
                            const SizedBox(height: 10),
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Diagnose yourself with\n HWatch App',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Lora',
                                    color: Colors.white,
                                    fontSize: 25),
                              ),
                            )
                          ],
                        ),
                      ),
                      PageModel(
                        widget: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Align(
                                alignment: Alignment.center,
                                child: Lottie.asset(
                                  'assets/78072-map-pin-location.json',
                                  height: 350,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Find near hospitals or clinics',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                            ),
                            const Spacer()
                          ],
                        ),
                      ),
                      PageModel(
                        widget: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/healthcare-loader.json',
                              height: 380,
                            ),
                            const SizedBox(height: 1),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Set your medicines with your user-friendly app\n',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Lora',
                                    color: Colors.white,
                                    fontSize: 25),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                    footerBuilder:
                        (context, dragDistance, pagesLength, setIndex) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: background,
                          border: Border.all(
                            width: 0.0,
                            color: background,
                          ),
                        ),
                        child: ColoredBox(
                          color: background,
                          child: Padding(
                            padding: const EdgeInsets.all(45.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomIndicator(
                                  netDragPercent: dragDistance,
                                  pagesLength: pagesLength,
                                  indicator: Indicator(
                                    indicatorDesign: IndicatorDesign.line(
                                      lineDesign: LineDesign(
                                        lineType: DesignType.line_uniform,
                                      ),
                                    ),
                                  ),
                                ),
                                index == pagesLength - 1
                                    ? _dashboardButton
                                    : _skipButton(setIndex: setIndex)
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              })),
        ]));
  }
}
