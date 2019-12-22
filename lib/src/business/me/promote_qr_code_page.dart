import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/global.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:titan/generated/i18n.dart';
import 'widget_shot.dart';
import 'dart:typed_data';

class PromoteQrCodePage extends StatelessWidget {
  final String url;
  final ShotController _shotController = new ShotController();

  PromoteQrCodePage(this.url);

  @override
  Widget build(BuildContext context) {
    print('[QR] ---> build, url:$url, id:${LOGIN_USER_INFO.id}');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).invitate_qr,
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            color: Colors.white,
            tooltip: S.of(context).share,
            onPressed: () {
              _shareQr(context);
            },
          ),
        ],
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: WidgetShot(
        controller: _shotController,
        child: _body(context),
      ),
    );
  }


  Widget _body(BuildContext context) {
    print('[QR] ---> _body, url:$url, id:${LOGIN_USER_INFO.id}');

    var languageCode = Localizations.localeOf(context).languageCode;
    var shareAppImage = "";

    if (languageCode == "zh") {
      shareAppImage = "res/drawable/invitation_bg.png";
    } else {
      shareAppImage = "res/drawable/invitation_bg_en.png";
    }

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(shareAppImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 22,
          height: 96,
          child: Container(
            color: HexColor('#343434').withOpacity(1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin:
                      EdgeInsets.only(top: 18, bottom: 18, left: 30, right: 8),
                  child: QrImage(
                    data: url,
                    padding: EdgeInsets.all(0.0),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    version: 4,
                    size: 60,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      LOGIN_USER_INFO.id,
                      style:
                          TextStyle(color: HexColor('#FEFEFE'), fontSize: 16),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      S.of(context).invite_join + " " + S.of(context).app_name,
                      style:
                          TextStyle(color: HexColor('#FEFEFE'), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _shareQr(BuildContext context) async {
//    print('_shareQr --> action, _shotController: ${_shotController.hashCode}');
//    print('_shareQr --> action, globalKey:${_shotController.globalKey.currentContext}, context:${context}');

    Uint8List imageByte = await _shotController.makeImageUint8List();
    await Share.file(
        S.of(context).nav_share_app, 'app.png', imageByte, 'image/png');
  }
}