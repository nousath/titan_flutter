import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/i18n.dart';
import 'package:url_launcher/url_launcher.dart';


class ImprovementDialog extends StatefulWidget {
  ImprovementDialog();

  @override
  State<StatefulWidget> createState() {
    return ImprovementDialogDialogState();
  }
}

class ImprovementDialogDialogState extends State<ImprovementDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;

    RoundedRectangleBorder _defaultDialogShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2.0)));

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: Colors.white,
              ),
              child: buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  S.of(context).improvement_plan_title,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Container(
                  color: Colors.grey[100],
                  margin: EdgeInsets.only(top: 16),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Html(
                        data: '''
                        ${S.of(context).improvement_plan_message}
                        ''',
                        padding: EdgeInsets.all(8.0),
                        onLinkTap: (url) {
//                          print("Opening $url...");
                          _openUrl(url, "Titan Privacy");
                        },
                      ),
                      Text(
                        '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                        child: RaisedButton(
                          onPressed: onDisAgree,
                          child: Text(
                            S.of(context).improvement_plan_refuse,
                            style: TextStyle(fontSize: 16),
                          ),
                          color: Colors.black87,
                          splashColor: Colors.white10,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        child: RaisedButton(
                          onPressed: onAgree,
                          child: Text(
                            S.of(context).improvement_plan_agree,
                            style: TextStyle(fontSize: 16),
                          ),
                          color: Colors.black87,
                          splashColor: Colors.white10,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  String addressErrorStr;

  String validatePubAddress(String address) {
    return addressErrorStr;
  }

  void onAgree() async {
    _savePlanDialogChoose(true);
    Navigator.pop(context);
  }

  void onDisAgree() async {
    _savePlanDialogChoose(false);
    Navigator.pop(context);
  }

  void _savePlanDialogChoose(bool isAgree) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isAgreePlan', isAgree);
//    setState(() {});
//    _isNeedShowIntro();
  }

  Future _openUrl(String url, String title) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}