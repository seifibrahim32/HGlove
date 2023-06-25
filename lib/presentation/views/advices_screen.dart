import 'package:flutter/material.dart';

class AdvicesScreen extends StatelessWidget {
  List<Text> textTitle = [
    Text(
      'Tips for diabetic\npeople',
      softWrap: true,
      style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      maxLines: 2,
    ),
    Text(
      'Tips for blood\npressure',
      softWrap: true,
      style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      maxLines: 2,
    ),
  ];
  List<Text> article = [
    Text(
        'Diabetes is a serious disease. Following your diabetes treatment plan t'
        'akes round-the-clock commitment. But your efforts are worthwhile. Careful diabe'
        'tes care can reduce your risk of serious — even life-threatening — complications.'
        'Here are 10 ways to take an active role in your diabetes care and enjoy a healthie'
        'r future.',
        style: TextStyle(fontWeight: FontWeight.w700)),
    Text(
        'If you have high blood pressure, you may wonder if medication is necessary t'
        'o bring the numbers down. But lifestyle plays a vital role in treating high '
        'blood pressure. Controlling blood pressure with a healthy lifestyle might prev'
        'ent, delay or reduce the need for medication.'
        'Here are 10 lifestyle changes that can lower blood pressure and keep it down.',
        style: TextStyle(fontWeight: FontWeight.w700))
  ];
  List tips = [];

  int tipsIndex = 0;

  AdvicesScreen(this.tipsIndex, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(tipsIndex);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: tipsIndex == 1 ? textTitle[0] : textTitle[1]),
            SizedBox(height: 50),
            tipsIndex == 1
                ? Image.asset('assets/diabetes.PNG')
                : Image.asset(
                    'assets/blood_pressure.PNG',
                    scale: 0.1,
                  ),
            SizedBox(height: 20),
            Padding(
                padding: EdgeInsets.all(8),
                child: tipsIndex == 1 ? article[0] : article[1]),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Stay tuned for more...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
