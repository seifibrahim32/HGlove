class ResultModel {
  String? status;
  List<Diseases>? diseases;

  ResultModel({this.status, this.diseases});

  ResultModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['Diseases'] != null) {
      diseases = <Diseases>[];
      json['Diseases'].forEach((v) {
        diseases!.add(Diseases.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (diseases != null) {
      data['Diseases'] = diseases!.map((disease) => disease.toJson()).toList();
    }
    return data;
  }
}

class Diseases {
  String? type;
  String? value;

  Diseases.fromJson(Map<String, dynamic> json) {
    type = json.entries.first.key;
    value = json.entries.first.value;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['value'] = value;
    return data;
  }
}