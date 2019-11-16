import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/business/me/model/user_eth_address.dart';
import 'package:titan/src/business/me/model/user_info.dart';
import 'package:titan/src/business/me/recharge_by_titan_finish_page.dart';
import 'package:titan/src/business/wallet/model/wallet_vo.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/business/wallet/wallet_create_new_account_page.dart';
import 'package:titan/src/business/wallet/wallet_import_account_page.dart';
import 'package:titan/src/business/wallet/wallet_send_page.dart';
import 'package:titan/src/utils/utils.dart';

import '../../global.dart';
import 'model/quotes.dart';
import 'service/user_service.dart';

class RechargePurchasePage extends StatefulWidget {
  RechargePurchasePage();

  @override
  State<StatefulWidget> createState() {
    return _RechargePurchaseState();
  }
}

class _RechargePurchaseState extends State<RechargePurchasePage> {
  var service = UserService();

  WalletService _walletService = WalletService();

  Quotes quotes;

  UserInfo userInfo;

  UserEthAddress userEthAddress;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      var data = await service.getUserEthAddress();
      setState(() {
        userEthAddress = data;
      });
    } catch (e) {
      logger.e(e);
      Fluttertoast.showToast(msg: "获取用户充值地址失败");
    }

    //行情
    var quotesData = await service.quotes();
    setState(() {
      quotes = quotesData;
    });

    //用户余额等信息
    var _userInfo = await service.getUserInfo();
    setState(() {
      userInfo = _userInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    var payTypeName = "";
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "充值",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildHynPayBox(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHynPayBox() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (quotes != null)
                Text(
                  '当前 ${quotes?.to} 兑换 ${quotes?.currency} 的比例为',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                )
              else
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              SizedBox(
                height: 8,
              ),
              if (quotes != null)
                Text(
                  '1${quotes?.to} ≈ ${NumberFormat("#,###.####").format(quotes?.rate == null ? 0 : (1 / quotes?.rate))}${quotes?.currency}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800]),
                )
              else
                Text(
                  '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800]),
                ),

              if (userEthAddress?.qrCode != null)
                Image.memory(
                  Base64Decoder().convert(userEthAddress?.qrCode),
                  height: 240,
                  width: 240,
                )
              else
                Container(
                  color: Colors.white,
                  height: 240,
                  width: 240,
                ),
              InkWell(
                onTap: () {
                  if (userEthAddress?.address != null) {
                    Clipboard.setData(ClipboardData(text: userEthAddress?.address));
                    Fluttertoast.showToast(msg: "地址复制成功");
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "转入地址: ${shortEthAddress(userEthAddress?.address)}",
                      style: TextStyle(fontSize: 14),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.content_copy,
                        size: 16,
                        color: Colors.black54,
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(
                height: 16,
              ),

//              Text(
//                '推荐使用imToken扫码支付',
//                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.grey[500]),
//              ),
              Padding(
                padding: const EdgeInsets.only(top: 22.0),
                child: RaisedButton(
                  color: Color(0xFFD6A734),
                  onPressed: () async {
                    WalletVo _walletVo = await _walletService.getDefaultWalletVo();
                    if (_walletVo == null) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Platform.isIOS
                                ? CupertinoAlertDialog(
                                    title: Text('提示'),
                                    content: Text('你还没有钱包.'),
                                    actions: <Widget>[
                                      new FlatButton(
                                        onPressed: () {
                                          createWalletPopUtilName = "/recharge_purchase_page";
                                          Navigator.push(
                                              context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
                                        },
                                        child: new Text("创建"),
                                      ),
                                      new FlatButton(
                                        onPressed: () {
                                          createWalletPopUtilName = "/recharge_purchase_page";
                                          Navigator.push(
                                              context, MaterialPageRoute(builder: (context) => ImportAccountPage()));
                                        },
                                        child: new Text("导入"),
                                      ),
                                      new FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: new Text("取消"),
                                      ),
                                    ],
                                  )
                                : AlertDialog(
                                    title: new Text("提示"),
                                    content: new Text("你还没有钱包"),
                                    actions: <Widget>[
                                      new FlatButton(
                                        onPressed: () {
                                          createWalletPopUtilName = "/recharge_purchase_page";
                                          Navigator.push(
                                              context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
                                        },
                                        child: new Text("创建"),
                                      ),
                                      new FlatButton(
                                        onPressed: () {
                                          createWalletPopUtilName = "/recharge_purchase_page";
                                          Navigator.push(
                                              context, MaterialPageRoute(builder: (context) => ImportAccountPage()));
                                        },
                                        child: new Text("导入"),
                                      ),
                                      new FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: new Text("取消"),
                                      ),
                                    ],
                                  );
                          });
                    } else {
                      isRechargeByTianWalletFinish = false;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WalletSendPage(null,
                                  receiverAddress: userEthAddress.address,
                                  backRouteName: "/recharge_purchase_page"))).then((value) {
                        if (isRechargeByTianWalletFinish) {
                          Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (context) => RechargeByTitanFinishPage()));
                        }
                      });
                    }
                  },
                  child: SizedBox(
                    height: 48,
                    width: 192,
                    child: Center(
                      child: Text(
                        "使用HYN钱包转入",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: RaisedButton(
                  color: Color(0xFF73C42D),
                  onPressed: () async {
                    var ret = await service.confirmRechargeV2(LOGIN_USER_INFO.balance);
                    if (ret.code == 0) {
                      //支付成功
                      Fluttertoast.showToast(msg: '充值成功');
//                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyAssetPage()));
                      Navigator.pop(context, true);
                    } else {
                      if (ret.code == -1007) {
                        Fluttertoast.showToast(msg: '已到达上限');
                      } else {
                        Fluttertoast.showToast(msg: '暂未发现转入信息，请稍后再试');
                      }
                    }
                  },
                  child: SizedBox(
                    height: 48,
                    width: 192,
                    child: Center(
                      child: Text(
                        "我已使用外部钱包转入",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 8, right: 8),
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.notification_important,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  "勿往上述地址转入非HYN资产，否则资产将不可找回。您转入后，需要整个网络节点的确认，大约需要10-30分钟。",
                  style: TextStyle(color: Color(0xFFCE9D40), fontSize: 13),
                  softWrap: true,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}