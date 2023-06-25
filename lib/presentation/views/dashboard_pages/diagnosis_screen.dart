import 'package:flutter/material.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform'
    '_interface.dart';

import '../../../controllers/cache_controllers.dart';
import '../../../controllers/network/latest_news_api.dart';
import '../../../controllers/services/services.dart';
import '../../../domain/models/health_articles_model.dart';
import 'assessment/glove_indicator.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  late Future<List<Articles>?> listOfNewsArticles;
  List<Widget> medicalNews = [];

  @override
  void initState() {
    fetchNews();
    super.initState();
  }

  void fetchNews() {
    listOfNewsArticles = LatestNewsAPI.getData();
    listOfNewsArticles.then((list) {
      list?.forEach((article) {
        setState(() {
          medicalNews.add(GestureDetector(
            onTap: () async {
              await UrlLauncherPlatform.instance.launch(
                article.url!,
                webOnlyWindowName: 'google.com',
                useSafariVC: false,
                useWebView: false,
                enableJavaScript: false,
                enableDomStorage: false,
                universalLinksOnly: false,
                headers: <String, String>{},
              );
            },
            child: SizedBox(
              width: 200,
              height: 200,
              child: Card(
                  color: Colors.white70,
                  elevation: 10,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          article.urlToImage!,
                          fit: BoxFit.fitWidth,
                          scale: 2,
                          isAntiAlias: true,
                          width: 300,
                          height: 100,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            article.title!,
                            softWrap: true,
                            overflow: TextOverflow.fade,
                            maxLines: 3,
                            style: const TextStyle(
                                fontSize: 17.0, fontWeight: FontWeight.w700),
                          ),
                        )
                      ])),
            ),
          ));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                    return GloveIndicatorScreen();
                  },));
            },
            icon: const Icon(Icons.front_hand),
          ),
          elevation: 0.12,
          centerTitle: true,
          title: const Text('HGlove', style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                boxShadow: [BoxShadow(spreadRadius: 1, offset: Offset(-3, -5))],
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[Colors.blue, Colors.green])),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  BackgroundServices.disableNotificationService();
                  removeDataFromCache(context);
                },
                child: const Text('Log out',
                    style: TextStyle(color: Colors.white, fontFamily: 'Lora')))
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.1, 0.4, 3.6, 0.9],
            colors: [
              Colors.greenAccent,
              Colors.blue,
              Colors.indigo,
              Colors.teal,
            ],
          )),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                        "Hi, I'm HF App.\nYour health is first."
                        "\nTake your health assessment.",
                        style: TextStyle(
                            fontSize: 28.0,
                            color: Colors.white,
                            fontFamily: 'Lora')),
                    const SizedBox(height: 19),
                    TextButton(
                      onHover: (val) {},
                      onPressed: () {
                        Navigator.pushNamed(context, '/assessment');
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color?>(
                              const Color(0xff426c87)),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                  const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 13)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: const BorderSide(
                                          color: Color(0xff426c87))))),
                      child: const Text('Diagnose your health',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'Lora',
                            color: Colors.white,
                          )),
                    ),
                    const SizedBox(height: 19),
                    //Tips and advices
                    const Text("Tips and advices",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'Lora',
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 19),
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed('/diabetes-advices');
                                  },
                                  child: Card(
                                      color: Colors.white,
                                      elevation: 4,
                                      child: Column(children: [
                                        Image.asset(
                                          'assets/diabetes.PNG',
                                          scale: 4,
                                        ),
                                        const SizedBox(height: 10),
                                        const Text('Tips for Diabetes',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'Lora',
                                                fontWeight: FontWeight.w700))
                                      ])),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed('/blood-advices');
                                  },
                                  child: Card(
                                      color: Colors.white,
                                      elevation: 4,
                                      child: Column(children: [
                                        Image.asset(
                                          'assets/blood_pressure.PNG',
                                          scale: 1.09,
                                        ),
                                        const SizedBox(height: 10),
                                        const Text('Tips for Blood Pressure',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'Lora',
                                                fontWeight: FontWeight.w700))
                                      ])),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 19),
                    //Latest Medical News
                    const Text("Latest Medical News",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'Lora',
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 19),
                    // If empty ,so it appears no visits else list of widgets appear.
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          medicalNews.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  height: 200,
                                  child: ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    children: medicalNews,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
