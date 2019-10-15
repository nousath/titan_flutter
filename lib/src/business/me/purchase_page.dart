import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/user_info.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/utils/utils.dart';

import '../../global.dart';
import 'model/contract_info.dart';
import 'model/pay_order.dart';
import 'model/quotes.dart';
import 'my_hash_rate_page.dart';
import 'service/user_service.dart';

class PurchasePage extends StatefulWidget {
  final ContractInfo contractInfo;

  PurchasePage({@required this.contractInfo});

  @override
  State<StatefulWidget> createState() {
    return _PurchaseState();
  }
}

class _PurchaseState extends State<PurchasePage> {
  int payType = 0; //0: HYN 1：HYN余额

  var service = UserService();

  PayOrder payOrder;
  Quotes quotes;
  UserInfo userInfo;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      var data = await service.createOrder(contractId: widget.contractInfo.id);
      setState(() {
        payOrder = data;
      });
    } catch (e) {
      logger.e(e);
      Fluttertoast.showToast(msg: "创建订单失败");
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
    var payTypeName = payType == 0 ? "HYN支付" : "余额支付";
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text("支付"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2)), shape: BoxShape.rectangle),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "购买产品：",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          "${widget.contractInfo.power} T算力",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "金额：",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(widget.contractInfo.amount)} U",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          )),
                      child: Row(
                        children: <Widget>[
                          Text(payTypeName),
                          Spacer(),
                          GestureDetector(
                            onTapUp: (detail) {
                              RenderBox overlay = Overlay.of(context).context.findRenderObject();
                              var position = RelativeRect.fromRect(
                                  detail.globalPosition & Size(80, 80), // smaller rect, the touch area
                                  Offset.zero & overlay.size // Bigger rect, the entire screen
                                  );
                              showMenu(
                                      context: context,
                                      position: position,
                                      items: <PopupMenuEntry>[
                                        PopupMenuItem(
                                          value: 0,
                                          child: Text(
                                            "HYN",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 1,
                                          child: Text("余额支付", style: TextStyle(fontSize: 14)),
                                        ),
                                      ],
                                      initialValue: payType)
                                  .then((selected) {
                                print("selected:$selected ");
                                if (selected == null) {
                                  return;
                                }
                                payType = selected;
                                setState(() {});
                              });
                            },
                            child: Text(
                              "切换支付方式>",
                              style: TextStyle(fontSize: 14, color: HexColor("#9E101010")),
                            ),
                          )
                        ],
                      )),
                  if (payType == 0) _buildHynPayBox(),
                  if (payType == 1) _buildHynBalancePayBox(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  RelativeRect _getPosition(BuildContext context) {
    final RenderBox bar = context.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        bar.localToGlobal(bar.size.bottomRight(Offset.zero), ancestor: overlay),
        bar.localToGlobal(bar.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    return position;
  }

  Widget _buildHynPayBox() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (payOrder?.qr_code != null)
                Image.memory(
                  Base64Decoder().convert(payOrder?.qr_code),
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
                  if (payOrder?.address != null) {
                    Clipboard.setData(ClipboardData(text: payOrder?.address));
                    Fluttertoast.showToast(msg: "地址复制成功");
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "支付地址",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text('${shortEthAddress(payOrder?.address)}', style: TextStyle(fontSize: 14)),
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
              InkWell(
                onTap: () {
                  if (payOrder?.hyn_amount != null) {
                    Clipboard.setData(ClipboardData(text: payOrder?.hyn_amount));
                    Fluttertoast.showToast(msg: "支付金额复制成功");
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "请支付",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          '${payOrder?.hyn_amount} HYN',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFCE9D40)),
                        ),
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
              ),
              Text(
                '请务必支付指定的HYN金额！',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red[800]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 22.0),
                child: RaisedButton(
                  color: Color(0xFFD6A734),
                  onPressed: () {
                    Fluttertoast.showToast(msg: 'HYN钱包即将开放');
                  },
                  child: SizedBox(
                    height: 48,
                    width: 192,
                    child: Center(
                      child: Text(
                        "使用HYN钱包支付",
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
                    var ret = await service.confirmPay(orderId: payOrder.order_id, payType: 'HYN');
                    if (ret.code == 0) {
                      //支付成功
                      Fluttertoast.showToast(msg: '购买成功');
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHashRatePage()));
                    } else {
                      if (ret.code == -1007) {
                        Fluttertoast.showToast(msg: '已到达购买上限');
                      } else {
                        Fluttertoast.showToast(msg: '暂未发现转账信息，请稍后再试');
                      }
                    }
                  },
                  child: SizedBox(
                    height: 48,
                    width: 192,
                    child: Center(
                      child: Text(
                        "我已使用外部钱包支付",
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
          margin: EdgeInsets.only(top: 8),
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
                  "当前 ${quotes?.currency} 兑换 ${quotes?.to} 的汇率为: 1${quotes?.currency} = ${quotes?.rate}${quotes?.to}。\n请勿往上述地址转入非HYN资产，否则资产将不可找回。您支付后后，需要整个网络节点的确认，大约需要20分钟。",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  softWrap: true,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHynBalancePayBox() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "请支付",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        '${payOrder?.amount}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFCE9D40)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'USDT',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFCE9D40)),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "账户余额 ${userInfo?.balance} USDT",
                    style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: RaisedButton(
                  elevation: 1,
                  color: Color(0xFFD6A734),
                  onPressed: () async {
                    if (userInfo != null && payOrder != null) {
                      if (userInfo.balance < payOrder.amount) {
                        Fluttertoast.showToast(msg: '余额不足');
                      } else {
                        try {
                          var ret = await service.confirmPay(orderId: payOrder.order_id, payType: 'B_HYN');
                          if (ret.code == 0) {
                            //支付成功
                            Fluttertoast.showToast(msg: '购买成功');
                            Navigator.pushReplacement(
                                context, MaterialPageRoute(builder: (context) => MyHashRatePage()));
                          } else {
                            if (ret.code == -1007) {
                              Fluttertoast.showToast(msg: '已到达购买上限');
                            } else {
                              Fluttertoast.showToast(msg: '暂未发现转账信息，请稍后再试');
                            }
                          }
                        } catch (e) {
                          logger.e(e);
                          Fluttertoast.showToast(msg: '支付异常');
                        }
                      }
                    } else {
                      Fluttertoast.showToast(msg: "数据异常，请重新购买");
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: SizedBox(
                        height: 40,
                        width: 192,
                        child: Center(
                            child: Text(
                          "确认支付",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ))),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
