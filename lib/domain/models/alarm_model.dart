class AlarmModel{
  String? medicineName;
  String? time;
  String? medicineTips;

  AlarmModel({this.medicineName,this.time,this.medicineTips});
  AlarmModel.fromJson(Map<String,dynamic> data){
      medicineName = data['medicineName'];
      medicineTips = data['medicineTips'];
      time = data['time'];
  }

  Map<String,dynamic> toJson() => <String,dynamic>{
      'medicineName': medicineName,
      'time': time,
      'medicineTips': medicineTips
    };
}