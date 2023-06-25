import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_diagnosis/presentation/bloc/cubit_manager.dart';

import '../../../../controllers/network/diagnoser_api/assessment_api.dart';
import '../../../../domain/models/questions_model.dart';
import '../../custom_widgets/custom_slider.dart';

class QuestionScreen extends StatefulWidget {
  final String? text, name;
  final List<Questions> list;
  final Questions currentQuestion;
  final PageController pageController;

  final BuildContext contextCubit;

  const QuestionScreen({
    required this.pageController,
    required this.text,
    required this.currentQuestion,
    required this.list,
    required this.name,
    required this.contextCubit,
    Key? key,
  }) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late int selectedIndex;

  late String? value;

  bool clicked = false;

  List<DropdownMenuItem<String>> menuItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.currentQuestion.type == 'integer' ||
        widget.currentQuestion.type == 'double') {
      value = widget.currentQuestion.defaultValue!.toString();
    } else {
      value = 2.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height:20),
              Text(
                  'Question ${widget.list.indexOf(
                      widget.currentQuestion) + 1}'
                      '/ ${widget.list.length}',
                  style: const TextStyle(fontFamily: 'SF', fontSize: 26)),
              const SizedBox(height:50),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.text!,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontFamily: "SF", fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(widget.currentQuestion.laytext!,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 16)),
              ),
              _getWidgetOptions(widget.currentQuestion),
              const SizedBox(height:10),
              //Next
              clicked ? const CircularProgressIndicator()
                  : Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Container(
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                clicked = true;
                              });
                              AssessmentAPI.updateFeature(widget.name!, value!)
                                  ?.then((res) {
                                if (res.statusCode == 200) {
                                  if (widget.currentQuestion !=
                                      widget.list.last) {
                                    widget.pageController.animateToPage(
                                        widget.list.indexOf(
                                                widget.currentQuestion) +
                                            1,
                                        duration:
                                            const Duration(milliseconds: 9),
                                        curve: Curves.bounceIn);
                                  } else if (widget.currentQuestion ==
                                      widget.list.last) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              });
                            },
                            child: const Text('Next'),
                          )),
                      const SizedBox(height: 10),
                    ]),
              const SizedBox(height:30),
              Container(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: () {
                      BlocProvider
                          .of<AssessmentCubit>(widget.contextCubit)
                          .navigate();
                    },
                    child: const Text('FINISH!!'),
                  ))
            ],
          ),
        ));
  }

  _getWidgetOptions(Questions currentQuestion) {
    switch (currentQuestion.type) {
      case 'integer':
      case 'double':
        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            showValueIndicator: ShowValueIndicator.always,
            trackHeight: 10,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
            thumbShape: PolygonSliderThumb(
              thumbRadius: 16.0,
              sliderValue: double.parse(value!),
            ),
          ),
          child: Slider(
            value: double.parse(value!),
            divisions: 50,
            min: double.parse(currentQuestion.min!.toString()),
            max: double.parse(currentQuestion.max!.toString()),
            onChanged: (val) {
              setState(() {
                value = val.toString();
              });
            },
          ),
        );
      case 'categorical':
        menuItems.clear();
        currentQuestion.choices?.map((choice) {
          menuItems.add(DropdownMenuItem<String>(
              value: choice.value.toString(),
              child: Text(choice.text.toString())));
        }).toList();
        return SizedBox(
          width: 300,
          height: 90,
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isDense: true,
              isExpanded: true,
              padding: const EdgeInsets.all(14),
              onTap: () {},
              value: value,
              items: menuItems.toList(),
              onChanged: (val) {
                print(val);
                setState(() {
                  value = val.toString();
                });
              },
            ),
          ),
        );
    }
  }
}
