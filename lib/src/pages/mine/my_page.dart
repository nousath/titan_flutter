import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/mine/about_me_page.dart';
import 'package:titan/src/pages/mine/me_setting_page.dart';
import 'package:titan/src/pages/mine/my_encrypted_addr_page.dart';
import 'package:titan/src/pages/mine/my_map3_contract_page.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/utils.dart';

class MyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPageState();
  }
}

class _MyPageState extends State<MyPage> {
  String _pubKey = "";
  Wallet _wallet;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    _pubKey = await TitanPlugin.getPublicKey();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              height: 200.0 + MediaQuery.of(context).padding.top,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [/*Color(0xff041528),*/ Theme.of(context).primaryColor, Color(0xff99C3E6)],
                        begin: FractionalOffset(0, 0.4),
                        end: FractionalOffset(0, 1))),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (_wallet != null) _buildWalletManagerRow(),
                        SizedBox(height: 16),
                        _wallet == null ? _buildWalletCreateRow() : _buildWalletDetailRow(_wallet),
                        SizedBox(height: 16),
                        _buildSloganRow(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
//              padding: EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  _buildMenuBar("我发起的Map3节点抵押合约", Icons.menu,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyMap3ContractPage("我发起的Map3合约")))),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar("我参与的Map3节点抵押合约", Icons.menu,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyMap3ContractPage("我参与的Map3合约")))),
                  Divider(
                    height: 10,
                  ),
                  _buildMenuBar(S.of(context).share_app, Icons.share, () => shareApp()),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar(S.of(context).about_us, Icons.info,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => AboutMePage()))),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar(S.of(context).setting, Icons.settings,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => MeSettingPage()))),
                  Divider(
                    height: 0,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16, left: 16),
              child: Row(
                children: <Widget>[
                  Text(
                    S.of(context).dapp_setting,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Divider(height: 0),
                _buildDMapItem(Icons.location_on, S.of(context).private_share,
                    S.of(context).private_share_receive_address(shortBlockChainAddress(_pubKey)), () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyEncryptedAddrPage()));
                }),
                Divider(height: 0),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuBar(String title, IconData iconData, Function onTap) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Ink(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: <Widget>[
              Icon(
                iconData,
                color: Color(0xffb4b4b4),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  title,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
              Spacer(),
              Icon(
                Icons.chevron_right,
                color: Colors.black54,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDMapItem(IconData iconData, String title, String description, Function ontap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: ontap,
        child: Ink(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(iconData, color: Color(0xffb4b4b4), size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Spacer(),
              Icon(
                Icons.chevron_right,
                color: Colors.black54,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletManagerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        InkWell(
            onTap: () {
              Application.router
                  .navigateTo(context, Routes.wallet_manager + '?entryRouteName=${Uri.encodeComponent(Routes.root)}');
            },
            child: Text(S.of(context).wallet_manage, style: TextStyle(color: Colors.white70, fontSize: 14))),
      ],
    );
  }

  Widget _buildWalletCreateRow() {
    return Row(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: 52,
          height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
          child: InkWell(
            onTap: () {},
            child: Stack(
              children: <Widget>[
                Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "res/drawable/ic_logo.png",
                      width: 80,
                      height: 80,
                    )),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 12,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
              onTap: () {
                Application.router
                    .navigateTo(context, Routes.wallet_create+ '?entryRouteName=${Uri.encodeComponent(Routes.root)}');
              },
              child: Text(S.of(context).create_wallet, style: TextStyle(color: Colors.white70, fontSize: 14))),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
              onTap: () {
                Application.router
                    .navigateTo(context, Routes.wallet_import + '?entryRouteName=${Uri.encodeComponent(Routes.root)}');
              },
              child: Text(S.of(context).import_wallet, style: TextStyle(color: Colors.white70, fontSize: 14))),
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildWalletDetailRow(Wallet wallet) {

    KeyStore walletKeyStore = wallet.keystore;
    Account ethAccount = wallet.getEthAccount();
    String walletName = walletKeyStore.name[0].toUpperCase() + walletKeyStore.name.substring(1);

    return Row(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: 52,
          height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
          child: InkWell(
            onTap: () {},
            child: Stack(
              children: <Widget>[
                Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "res/drawable/ic_logo.png",
                      width: 80,
                      height: 80,
                    )),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 12,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                walletName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              SizedBox(
                height: 4,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  shortBlockChainAddress(ethAccount.address, limitCharsLength: 13),
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildSloganRow() {
    return Row(
      children: <Widget>[
        //Image.asset('res/drawable/ic_logo.png', width: 40.0),
        Image.asset(
          'res/drawable/logo_title.png',
          width: 72.0,
          height: 36,
        ),
        SizedBox(width: 16),
        Text(S.of(context).titan_encrypted_map_ecology, style: TextStyle(color: Colors.white70))
      ],
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
    await Share.file(S.of(context).nav_share_app, 'app.png', imageByte.buffer.asUint8List(), 'image/jpeg');
  }

}
