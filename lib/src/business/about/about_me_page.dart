import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/updater/bloc/bloc.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboueMeState();
  }
}

class _AboueMeState extends State<AboutMePage> {
  String version = "";

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var languageCode = Localizations.localeOf(context).languageCode;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
//          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            S.of(context).about_us,
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: ListView(padding: EdgeInsets.symmetric(horizontal: 24), children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 36, bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'res/drawable/map_rich_application.png',
                  width: 120,
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text("泰坦掘金", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF252525))),
                  SizedBox(
                    height: 4,
                  ),
                  Text("1.0.0", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Color(0xFF9B9B9B)))
                ],
              )
            ],
          ),
          SizedBox(
            height: 40,
          ),
          Divider(),
          _buildInfoContainer(
              label: "检查更新",
              onTap: () {
                BlocProvider.of<AppBloc>(context)
                    .dispatch(CheckUpdate(lang: Localizations.localeOf(context).languageCode));
              }),
          Divider()
        ]));
  }

  Widget _buildInfoContainer({String label, Function onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 1, 0, 0),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              Spacer(),
              Icon(
                Icons.chevron_right,
                color: Colors.grey,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future _openUrl(String url, String title) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void _copyText(String text) {
    Clipboard.setData(new ClipboardData(text: text));
    Fluttertoast.showToast(msg: S.of(context).copyed);
  }
}
