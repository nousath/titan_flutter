import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:titan/generated/l10n.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/pages/market/exchange_detail/exchange_detail_page.dart';
import 'package:titan/src/pages/mine/my_encrypted_addr_page.dart';
import 'package:titan/src/pages/wallet_demo/ApiDemo.dart';
import 'package:titan/src/pages/wallet_demo/WalletDemo.dart';
import 'package:titan/src/pages/wallet/wallet_page/wallet_page.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/smart_drawer.dart';

import 'package:titan/src/pages/mine/about_me_page.dart';
import 'package:titan/src/widget/webview_demo_page.dart';
import 'package:titan/src/widget/widget_demo_page.dart';

class DrawerComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DrawerComponentState();
  }
}

class _DrawerComponentState extends State<DrawerComponent> {
  String _pubKey = "";
  String _pubKeyAutoRefreshTip = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    var expireTime = await TitanPlugin.getExpiredTime();
    var timeLeft = (expireTime - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
    if (timeLeft <= 0) {
      _pubKeyAutoRefreshTip = getExpiredTimeShowTip(context, expireTime);
      _pubKey = '';
      setState(() {});

      TitanPlugin.getPublicKey().then((pub) async {
        _pubKey = pub;
        expireTime = await TitanPlugin.getExpiredTime();
        _pubKeyAutoRefreshTip = getExpiredTimeShowTip(context, expireTime);
        setState(() {});
      });
    } else {
      _pubKey = await TitanPlugin.getPublicKey();
      _pubKeyAutoRefreshTip = getExpiredTimeShowTip(context, expireTime);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartDrawer(
      widthPercent: 0.72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xff212121), Color(0xff000000)],
                    begin: FractionalOffset(0, 0.4),
                    end: FractionalOffset(0, 1))),
            height: 200.0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image.asset('res/drawable/ic_logo.png', width: 40.0),
                        SizedBox(width: 8),
                        Image.asset('res/drawable/logo_title.png', width: 72.0)
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(S.of(context).nav_my_privacy_map,
                        style: TextStyle(color: Colors.white70))
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyEncryptedAddrPage()));
                  },
                  leading: Icon(Icons.lock),
                  title: Text(S.of(context).main_my_public_key),
                  trailing: Icon(Icons.navigate_next),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(8),
                  color: Colors.grey[200],
                  child: GestureDetector(
                    onTap: () {
                      if (_pubKey.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: _pubKey));
                        Fluttertoast.showToast(
                            msg: S.of(context).public_key_copied);
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Flexible(
                            child: Text(
                          _pubKey,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        )),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.content_copy,
                            size: 16,
                            color: Colors.black45,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(_pubKeyAutoRefreshTip,
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                Container(height: 8, color: Colors.grey[100]),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Scaffold(
                                  body: SafeArea(child: WalletPage()),
                                )));
                  },
                  leading: Icon(Icons.account_balance_wallet),
                  title: Text(S.of(context).wallet),
                  trailing: Icon(Icons.navigate_next),
                ),
                Container(height: 1, color: Colors.grey[100]),
                ListTile(
                  onTap: () {},
                  leading: Icon(Icons.account_box),
                  title: Text(S.of(context).my_page),
                  trailing: Icon(Icons.navigate_next),
                ),
                Container(height: 1, color: Colors.grey[100]),
                ListTile(
                  onTap: shareApp,
                  leading: Icon(Icons.share),
                  title: Text(S.of(context).nav_share_app),
                  trailing: Icon(Icons.navigate_next),
                ),
                Container(height: 1, color: Colors.grey[100]),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AboutMePage()));
                  },
                  leading: Icon(Icons.info),
                  title: Text(S.of(context).nav_about_us),
                  trailing: Icon(Icons.navigate_next),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ExchangeDetailPage(selectedCoin:"USDT", exchangeType:0)));
                  },
                  leading: Icon(Icons.monetization_on),
                  title: Text('交易详情页'),
                  trailing: Icon(Icons.navigate_next),
                ),
                Container(height: 1, color: Colors.grey[100]),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => WalletDemo()));
                  },
                  leading: Icon(Icons.monetization_on),
                  title: Text('钱包测试'),
                  trailing: Icon(Icons.navigate_next),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ApiDemo()));
                  },
                  leading: Icon(Icons.http),
                  title: Text('API Demo'),
                  trailing: Icon(Icons.navigate_next),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WidgetDemoPage()));
                  },
                  leading: Icon(Icons.monetization_on),
                  title: Text('widget demo'),
                  trailing: Icon(Icons.navigate_next),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WebviewDemoPage()));
                  },
                  leading: Icon(Icons.monetization_on),
                  title: Text('webview page'),
                  trailing: Icon(Icons.navigate_next),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void shareApp() async {
    var languageCode = Localizations.localeOf(context).languageCode;
    var shareAppImage = "";

    if (languageCode == "zh") {
      shareAppImage = "res/drawable/share_app_zh_android.jpeg";
    } else {
      shareAppImage = "res/drawable/share_app_en_android.jpeg";
    }

    final ByteData imageByte = await rootBundle.load(shareAppImage);
    await Share.file(S.of(context).nav_share_app, 'app.png',
        imageByte.buffer.asUint8List(), 'image/jpeg');
  }
}
