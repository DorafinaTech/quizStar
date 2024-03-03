import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizstar/resultpage.dart';

class GetJson extends StatelessWidget {
  final String langname;
  GetJson({this.langname = ""});

  late String assetToLoad;

  // Corrected method name to follow Dart conventions
  void setAsset() {
    switch (langname) {
      case "Python":
        assetToLoad = "assets/python.json";
        break;
      case "Java":
        assetToLoad = "assets/java.json";
        break;
      case "Javascript":
        assetToLoad = "assets/js.json";
        break;
      case "C++":
        assetToLoad = "assets/cpp.json";
        break;
      default:
        assetToLoad = "assets/linux.json";
    }
  }

  @override
  Widget build(BuildContext context) {
    setAsset(); // Call setAsset before building the widget

    return FutureBuilder<String>(
      future:
          DefaultAssetBundle.of(context).loadString(assetToLoad, cache: false),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<dynamic> questions = json.decode(snapshot.data.toString());

          return QuizPage(questions: questions);
        } else if (snapshot.hasError) {
          return Scaffold(
              body:
                  Center(child: Text("Error loading data: ${snapshot.error}")));
        }
        return Scaffold(body: Center(child: Text("Loading...")));
      },
    );
  }
}

// Renamed class to follow Dart naming conventions
class QuizPage extends StatefulWidget {
  final List<dynamic> questions;
  QuizPage({required this.questions});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Color colorToShow = Colors.indigoAccent;
  Color right = Colors.green;
  Color wrong = Colors.red;
  int marks = 0, numberOfQuestion = 1, timer = 10;
  bool disableAnswer = false;
  late List<int> randomArray;
  Map<String, Color> btnColor = {
    "a": Colors.indigoAccent,
    "b": Colors.indigoAccent,
    "c": Colors.indigoAccent,
    "d": Colors.indigoAccent,
  };
  bool cancelTimer = false;

  // String showtimer = "10";

  @override
  void initState() {
    super.initState();
    startTimer();
    genRandomArray();
  }

  void genRandomArray() {
    randomArray = List.generate(10, (index) => index)..shuffle();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) {
      if (mounted) {
        setState(() {
          if (timer < 1) {
            t.cancel();
            nextQuestion();
          } else if (cancelTimer) {
            t.cancel();
          } else {
            timer--;
          }
        });
      }
    });
  }

  void nextQuestion() {
    cancelTimer = false;
    timer = 10;
    setState(() {
      if (numberOfQuestion < randomArray.length) {
        // numberOfQuestion = randomArray[numberOfQuestion];
        numberOfQuestion++;
      } else {
        // Navigate to result page
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ResultPage(marks: marks),
        ));
      }
      btnColor = {
        "a": Colors.indigoAccent,
        "b": Colors.indigoAccent,
        "c": Colors.indigoAccent,
        "d": Colors.indigoAccent
      };
      disableAnswer = false;
    });
    startTimer();
  }

  void checkAnswer(String k) {
    if (widget.questions[2][numberOfQuestion.toString()] ==
        widget.questions[1][numberOfQuestion.toString()][k]) {
      marks += 5;
      colorToShow = right;
    } else {
      colorToShow = wrong;
    }
    setState(() {
      btnColor[k] = colorToShow;
      cancelTimer = true;
      disableAnswer = true;
    });
    Timer(Duration(seconds: 4), nextQuestion);
  }

  Widget choiceButton(String k) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: MaterialButton(
        onPressed: () => checkAnswer(k),
        child: Text(
          widget.questions[1][numberOfQuestion.toString()][k],
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        color: btnColor[k]!,
        splashColor: Colors.indigo[700],
        highlightColor: Colors.indigo[700],
        minWidth: 200.0,
        height: 45.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return WillPopScope(
      onWillPop: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Quizstar"),
            content: Text("You Can't Go Back At This Stage."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(true); // Return true when popping the dialog
                },
                child: Text('Ok'),
              ),
            ],
          ),
        );

        return result ?? false; // Return false if dialog is dismissed
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(15.0),
                alignment: Alignment.bottomLeft,
                child: Text(
                  widget.questions[0][numberOfQuestion.toString()],
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Quando",
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: AbsorbPointer(
                absorbing: disableAnswer,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      choiceButton('a'),
                      choiceButton('b'),
                      choiceButton('c'),
                      choiceButton('d'),
                    ],
                  ),
                ),
              ),
            ),
            // Expanded(
            //   flex: 1,
            //   child: Container(
            //     alignment: Alignment.topCenter,
            //     child: Center(
            //       child: Text(
            //         showtimer,
            //         style: TextStyle(
            //           fontSize: 35.0,
            //           fontWeight: FontWeight.w700,
            //           fontFamily: 'Times New Roman',
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
