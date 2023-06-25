class AppointmentModel{
  String? location;
  String? doctorName;
  String? doctorTime;

  AppointmentModel({this.location,this.doctorName,this.doctorTime});

  AppointmentModel.fromJson(Map<String,dynamic> data){
    location = data['location'];
    doctorName = data['doctorName'];
    doctorTime = data['doctorTime'];
  }

  Map<String,dynamic> toJson() => <String,dynamic>{
    'doctorName': doctorName,
    'doctorTime': doctorTime,
    'location': location,
  };

}