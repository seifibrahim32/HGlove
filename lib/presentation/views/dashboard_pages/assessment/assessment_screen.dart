import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:health_diagnosis/presentation/views/dashboard_pages/assessment/question_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../domain/models/diseases_model.dart';
import '../../../../domain/models/questions_model.dart';
import '../../../../domain/models/result_model.dart';
import '../../../bloc/bloc_states.dart';
import '../../../bloc/cubit_manager.dart';
import '../../maps/maps_screen.dart';
import 'glove_indicator.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  bool clicked = false, termsAndConditions = false;

  final PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 1);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 1000),
        reverseDuration: const Duration(milliseconds: 1000),
        vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider<AssessmentCubit>(
      create: (context) => AssessmentCubit(),
      child: BlocBuilder<AssessmentCubit, AssessmentStates>(
          builder: (context, state) {
        switch (state.runtimeType) {
          case CheckConnectivityState:
            BlocProvider.of<AssessmentCubit>(context).checkConnectivity();
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: Center(
                  widthFactor: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Connecting to server',
                                style: TextStyle(
                                  fontFamily: "SF",
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                )),
                            SizedBox(
                              width: 70,
                              height: 20,
                              child: DefaultTextStyle(
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black),
                                child: AnimatedTextKit(
                                  repeatForever: true,
                                  animatedTexts: [
                                    TyperAnimatedText('...'),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                    ],
                  )),
            );
          case ConnectivityInvalidState:
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: const Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 64),
                      Text(
                        'No internet connection',
                        style: TextStyle(fontFamily: "SF", fontSize: 20),
                      )
                    ]),
              ),
            );
          case SessionInitializingState:
            BlocProvider.of<AssessmentCubit>(context).navigate();
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                        alignment: Alignment.center,
                        widthFactor: 3,
                        child: Text(
                          'Session is initializing ....',
                          softWrap: true,
                          style: TextStyle(fontFamily: "SF", fontSize: 20),
                        )),
                  ],
                ),
              ),
            );
          case SessionInitializedState:
            BlocProvider.of<AssessmentCubit>(context).navigate();
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: animation,
                      child: const Align(
                          alignment: Alignment.center,
                          widthFactor: 3,
                          child: Text(
                            'Session is initialized ....',
                            softWrap: true,
                            style: TextStyle(fontFamily: "SF", fontSize: 20),
                          )),
                    ),
                  ],
                ),
              ),
            );
          case AcceptingTermsAndConditionsState:
            final VoidCallback? onPressed = termsAndConditions
                ? () {
                    BlocProvider.of<AssessmentCubit>(context)
                        .acceptTermsAndConditions();
                  }
                : null;
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: termsAndConditions,
                          onChanged: (bool? value) {
                            setState(() {
                              termsAndConditions = value!;
                            });
                          },
                        ),
                        const Text(
                          'I agree to HGlove Terms and Conditions',
                        ),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Disagree to API confidentiality.
                        ElevatedButton(
                          style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel',
                              style: TextStyle(fontFamily: "SF")),
                        ),
                        ElevatedButton(
                          onPressed: onPressed,
                          child: const Text('Next',
                              style: TextStyle(fontFamily: "SF")),
                        )
                      ])
                ],
              ),
            );
          case PreparingQuestionsState:
            BlocProvider.of<AssessmentCubit>(context).retrieveQuestions();
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: const Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Assessment is preparing...',
                          style: TextStyle(fontFamily: "SF"))
                    ]),
              ),
            );
          case QuestionsShownState:
            List<Questions> questions =
                BlocProvider.of<AssessmentCubit>(context).questions;
            List<Widget> questionsWidget = [];
            for (var question in questions) {
              questionsWidget.add(QuestionScreen(
                  pageController: _pageController,
                  contextCubit: context,
                  currentQuestion: question,
                  list: questions,
                  text: question.text,
                  name: question.name));
            }
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: PageView(
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  //print("Question ${index + 1}");
                },
                controller: _pageController,
                children: questionsWidget,
              ),
            );
          case AssessmentAnalyzingState:
            return Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                body: const Center(child: CircularProgressIndicator()));
          case StoreDiseasesState:
            BlocProvider.of<AssessmentCubit>(context).storeInDiseasesList();

            return const Center(child: CircularProgressIndicator());
          case AssessmentAnalyzedState:
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: [
                  BlocProvider.of<AssessmentCubit>(context).diseases.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  GloveIndicatorScreen(),
                            ));
                          },
                          icon: const Icon(Icons.front_hand),
                        )
                      : Container(),
                  BlocProvider.of<AssessmentCubit>(context).diseases.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const MapsScreen(
                                kind: 'doctors',
                              ),
                            ));
                          },
                          icon: const Icon(Icons.map_rounded),
                        )
                      : Container()
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    getWidgetDiseases(context)!,
                  ],
                ),
              ),
            );

          default:
            return Container();
        }
      }),
    ));
  }

  Widget? getWidgetDiseases(BuildContext context) {
    final contextAssessment = BlocProvider.of<AssessmentCubit>(context);
    List<Diseases> diseasesList = contextAssessment.diseases;
    List<DiseasesInfo> diseasesInfo = contextAssessment.diseasesInfo;
    print(diseasesList.length);
    //If there is no disease
    if (diseasesList.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Image.asset('assets/no_diseases.png'),
          const SizedBox(height: 10),
          const Text(
            'Congratulations!.\nYou have no diseases or '
            'symptoms.',
            style:
                TextStyle(color: Colors.black, fontFamily: "SF", fontSize: 20),
            textAlign: TextAlign.center,
          )
        ],
      );
    }
    // If there are diseases
    else if (diseasesList.isNotEmpty) {
      return Column(
        children: [
          const SizedBox(height: 5),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Diseases',
                style: TextStyle(fontFamily: 'SF', fontSize: 24)),
          ),
          ListView.separated(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                    margin: const EdgeInsets.all(10.0),
                    padding: const EdgeInsets.all(10.0),
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 1.8,
                            offset: const Offset(0, 2),
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    diseasesList[index].type!.trim(),
                                    style: const TextStyle(fontFamily: "SF"),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(diseasesInfo[index]
                                      .category!
                                      .capitalize()),
                                  Text(diseasesInfo[index].isGenderSpecific!
                                      ? "Specific"
                                      : "Not Gender Specific"),
                                  Text(diseasesInfo[index].isRare!
                                      ? "Rare"
                                      : "Not rare"),
                                  Text(
                                      "Risk level: ${diseasesInfo[index].risk}",
                                      style: TextStyle(
                                          color: diseasesInfo[index].risk! <=
                                                  1.0
                                              ? Colors.green
                                              : diseasesInfo[index].risk! <= 2.0
                                                  ? Colors.orange
                                                  : diseasesInfo[index].risk! <=
                                                          2.0
                                                      ? Colors.amber
                                                      : Colors.red)),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                LinearPercentIndicator(
                                  width: 260.0,
                                  lineHeight: 12.0,
                                  percent:
                                      double.parse(diseasesList[index].value!),
                                  progressColor: Colors.green,
                                ),
                                Text(
                                  "${(double.parse(diseasesList[index].value!) * 100).toStringAsPrecision(2)} %",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontFamily: "SF"),
                                )
                              ],
                            ),
                          ]),
                    ));
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 13,
                );
              },
              itemCount: diseasesList.length),
        ],
      );
    }
    return null;
  }
}
