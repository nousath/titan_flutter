import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

import 'event_bus_event.dart';

class FinishImportPage extends StatefulWidget {
  Wallet wallet;

  FinishImportPage(this.wallet);

  @override
  State<StatefulWidget> createState() {
    return _FinishImportState();
  }
}

class _FinishImportState extends State<FinishImportPage> {
  WalletService _walletService = WalletService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Image.asset(
                  "res/drawable/check_outline.png",
                  height: 60,
                  width: 60,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "账户导入成功",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "恭喜，您的私密钱包已经导入成功",
                  style: TextStyle(color: Color(0xFF9B9B9B)),
                ),
              ),
              SizedBox(
                height: 36,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                constraints: BoxConstraints.expand(height: 48),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  disabledColor: Colors.grey[600],
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  disabledTextColor: Colors.white,
                  onPressed: () async {
                    await _walletService.saveDefaultWalletFileName(widget.wallet.keystore.fileName);
                    eventBus.fire(ReScanWalletEvent());
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "使用该私密账户",
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}