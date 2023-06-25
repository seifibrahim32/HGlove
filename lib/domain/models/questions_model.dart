class QuestionsModel {
  late List<Questions> questions;

  QuestionsModel({required this.questions});

  QuestionsModel.fromJson(Map<String, dynamic> json) {
    questions = [];
    if (json['questions'] != null) {
      json['questions'].forEach((v) {
        questions.add(Questions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['questions'] = questions.map((v) => v.toJson()).toList();
    return data;
  }
}

class Questions {
  late String? text;
  late String? laytext;
  late String? name;
  late String? type;
  late num? min;
  late num? max;

  late num? defaultValue;

  late String? category;
  late String? alias;
  late String? wiki;
  late String? wiki2;
  late String? wiki3;
  late String? wiki4;
  late String? subcategory1;
  late String? subcategory2;
  late String? subcategory3;
  late String? subcategory4;
  late bool isPatientProvided;
  late num? step;
  List<Choices>? choices;

  Questions(
      {required this.text,
      required this.laytext,
      required this.name,
      required this.type,
      required this.min,
      required this.max,
      required this.defaultValue,
      required this.category,
      required this.alias,
      required this.wiki,
      required this.wiki2,
      required this.wiki3,
      required this.wiki4,
      required this.subcategory1,
      required this.subcategory2,
      required this.subcategory3,
      required this.subcategory4,
      required this.isPatientProvided,
      required this.step,
      this.choices});

  Questions.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    laytext = json['laytext'];
    name = json['name'];
    type = json['type'];
    min = json['min'];
    max = json['max'];
    defaultValue = json['default'];
    category = json['category'];
    alias = json['alias'];
    wiki = json['wiki'];
    wiki2 = json['wiki2'];
    wiki3 = json['wiki3'];
    wiki4 = json['wiki4'];
    subcategory1 = json['subcategory1'];
    subcategory2 = json['subcategory2'];
    subcategory3 = json['subcategory3'];
    subcategory4 = json['subcategory4'];
    isPatientProvided = json['IsPatientProvided'];
    step = json['step'];
    if (json['choices'] != null) {
      choices = [];
      json['choices'].forEach((v) {
        choices?.add(Choices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['laytext'] = laytext;
    data['name'] = name;
    data['type'] = type;
    data['min'] = min;
    data['max'] = max;
    data['defaultValue'] = defaultValue;
    data['category'] = category;
    data['alias'] = alias;
    data['wiki'] = wiki;
    data['wiki2'] = wiki2;
    data['wiki3'] = wiki3;
    data['wiki4'] = wiki4;
    data['subcategory1'] = subcategory1;
    data['subcategory2'] = subcategory2;
    data['subcategory3'] = subcategory3;
    data['subcategory4'] = subcategory4;
    data['IsPatientProvided'] = isPatientProvided;
    data['step'] = step;
    data['choices'] = choices?.map((v) => v.toJson()).toList();
    return data;
  }
}

class Choices {
  late String? text;
  late String? laytext;
  late num? value;
  late String? relatedanswertag;

  Choices({required this.text,required this.laytext, this.value,
    required this.relatedanswertag});

  Choices.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    laytext = json['laytext'];
    value = json['value'];
    relatedanswertag = json['relatedanswertag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['laytext'] = laytext;
    data['value'] = value;
    data['relatedanswertag'] = relatedanswertag;
    return data;
  }
}
