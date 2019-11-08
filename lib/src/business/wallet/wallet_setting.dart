import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/wallet_backup_notice_page.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

class WalletSettingPage extends StatefulWidget {
  Wallet trustWallet;

  WalletSettingPage(this.trustWallet);

  @override
  State<StatefulWidget> createState() {
    return _WalletSettingState();
  }
}

class _WalletSettingState extends State<WalletSettingPage> {
  TextEditingController _walletNameController = TextEditingController();

  KeyStore _walletKeyStore;

  Account _ethAccount;

  @override
  void initState() {
    _walletKeyStore = widget.trustWallet.keystore;
    _ethAccount = widget.trustWallet.getEthAccount();
    _walletNameController.text = _walletKeyStore.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "钱包设置",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "钱包名称",
                  style: TextStyle(
                    color: Color(0xFF6D6D6D),
                    fontSize: 16,
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: TextFormField(
                  controller: _walletNameController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "请输入钱包名称";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  keyboardType: TextInputType.text),
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              children: <Widget>[
                Text(
                  "备份选项",
                  style: TextStyle(
                    color: Color(0xFF6D6D6D),
                    fontSize: 16,
                  ),
                )
              ],
            ),
            Divider(),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => WalletBackupNoticePage()));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.event_note,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      "显示恢复短语",
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xFFD2D2D2),
                    )
                  ],
                ),
              ),
            ),
            Divider(),
            Text(
              "如果你无法访问这个设备，你的资金将无法找回，除非你备份了！",
              style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
            ),
            SizedBox(
              height: 36,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 36, horizontal: 36),
              constraints: BoxConstraints.expand(height: 48),
              child: RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                disabledColor: Colors.grey[600],
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                disabledTextColor: Colors.white,
                onPressed: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "保存",
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
