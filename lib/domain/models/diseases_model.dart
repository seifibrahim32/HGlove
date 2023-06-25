class DiseasesInfoModel {
  late List<DiseasesInfo> diseasesInfo;

  DiseasesInfoModel({required this.diseasesInfo});

  DiseasesInfoModel.fromJson(Map<String, dynamic> json) {
    if (json['DiseasesInfo'] != null) {
      diseasesInfo = [];
      json['DiseasesInfo'].forEach((v) {
        diseasesInfo.add(DiseasesInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DiseasesInfo'] = diseasesInfo.map((v) => v.toJson()).toList();
    return data;
  }
}

class DiseasesInfo {
  late String? name;
  late String? text;
  late String? laytext;
  late String? category;
  late String? alias;
  late String? wiki;
  late String? wiki2;
  late String? wiki3;
  late String? wiki4;
  late bool? isRare;
  late bool? isGenderSpecific;
  late bool? isImmLifeThreatening;
  late bool? isCantMiss;
  late num? risk;
  late String? iCD10;
  late String? lOINC;
  late num? gencount;

  DiseasesInfo(
      {required this.name,
      required this.text,
      required this.laytext,
      required this.category,
      required this.alias,
      required this.wiki,
      required this.wiki2,
      required this.wiki3,
      required this.wiki4,
      required this.isRare,
      required this.isGenderSpecific,
      required this.isImmLifeThreatening,
      required this.isCantMiss,
      required this.risk,
      required this.iCD10,
      required this.lOINC,
      required this.gencount});

  DiseasesInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    text = json['text'];
    laytext = json['laytext'];
    category = json['category'];
    alias = json['alias'];
    wiki = json['wiki'];
    wiki2 = json['wiki2'];
    wiki3 = json['wiki3'];
    wiki4 = json['wiki4'];
    isRare = json['IsRare'];
    isGenderSpecific = json['IsGenderSpecific'];
    isImmLifeThreatening = json['IsImmLifeThreatening'];
    isCantMiss = json['IsCantMiss'];
    risk = json['Risk'];
    iCD10 = json['ICD10'];
    lOINC = json['LOINC'];
    gencount = json['gencount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['text'] = text;
    data['laytext'] = laytext;
    data['category'] = category;
    data['alias'] = alias;
    data['wiki'] = wiki;
    data['wiki2'] = wiki2;
    data['wiki3'] = wiki3;
    data['wiki4'] = wiki4;
    data['IsRare'] = isRare;
    data['IsGenderSpecific'] = isGenderSpecific;
    data['IsImmLifeThreatening'] = isImmLifeThreatening;
    data['IsCantMiss'] = isCantMiss;
    data['Risk'] = risk;
    data['ICD10'] = iCD10;
    data['LOINC'] = lOINC;
    data['gencount'] = gencount;
    return data;
  }
}
