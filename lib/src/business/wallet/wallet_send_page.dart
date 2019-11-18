import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/wallet/model/wallet_vo.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/business/wallet/wallet_send_confirm_page.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

import '../../global.dart';
import 'model/wallet_account_vo.dart';

class WalletSendPage extends StatefulWidget {
  final WalletAccountVo walletAccountVo;
  final String receiverAddress;
  final double count;
  final String symbol;
  final String currencyUnit = "CNY";
  final String backRouteName;

  WalletSendPage(this.walletAccountVo, {this.receiverAddress, this.count, this.symbol = "HYN", this.backRouteName});

  @override
  State<StatefulWidget> createState() {
    return _WalletSendState();
  }
}

class _WalletSendState extends State<WalletSendPage> {
  final TextEditingController _receiverAddressController = TextEditingController();
  final TextEditingController _countController = TextEditingController();

  final _fromKey = GlobalKey<FormState>();

  double amount = 0;

  static NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.####");

  WalletService _walletService = WalletService();

  var walletAccountVo;

  var symbol;
  var currencyUnit;

  @override
  void initState() {
    symbol = widget.walletAccountVo != null ? widget.walletAccountVo.symbol : widget.symbol;
    currencyUnit = widget.walletAccountVo != null ? widget.walletAccountVo.currencyUnit : widget.currencyUnit;
    loadData();
    super.initState();
  }

  Future loadData() async {
    if (widget.receiverAddress != null) {
      _receiverAddressController.text = widget.receiverAddress;
    }
    if (widget.count != null) {
      _countController.text = widget.count.toString();
    }
    if (mounted) {
      setState(() {});
    }
    if (widget.walletAccountVo == null) {
      WalletVo _walletVo = await _walletService.getDefaultWalletVo();
      logger.i("walletVo:$_walletVo");

      var account = _walletVo.accountList.firstWhere((accountTemp) {
        return accountTemp.symbol == symbol;
      }, orElse: () {
        return null;
      });
      if (account == null) {
        Fluttertoast.showToast(msg: "账户错误");
        return;
      }
      walletAccountVo = account;
    } else {
      walletAccountVo = widget.walletAccountVo;
    }

    await _walletService.updateAccountBalance(widget.walletAccountVo, widget.walletAccountVo.wallet);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "发送 ${symbol}",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _fromKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "接收者地址",
                          style: TextStyle(
                            color: Color(0xFF6D6D6D),
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: onPaste,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              ExtendsIconFont.copy_content,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onScan,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              ExtendsIconFont.qrcode_scan,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "接收地址不能位空";
                            }
                            return null;
                          },
                          controller: _receiverAddressController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          keyboardType: TextInputType.text),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "${symbol}数量",
                          style: TextStyle(
                            color: Color(0xFF6D6D6D),
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            _countController.text = walletAccountVo.balance.toString();
                            amount = double.parse(_countController.text) * walletAccountVo.currencyRate;
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                            child: Text(
                              "全部",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  textBaseline: TextBaseline.ideographic),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      child: TextFormField(
                        validator: (value) {
                          if (value == "0") {
                            return "请输入正确的数量";
                          }
                          if (!RegExp(r"\d+(\.\d+)?$").hasMatch(value)) {
                            return "请输入正确的数量";
                          }
                          if (double.parse(value) > walletAccountVo.balance) {
                            return "超过余额";
                          }
                          return null;
                        },
                        controller: _countController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          amount = double.parse(value) * walletAccountVo.currencyRate;
                          setState(() {});
                        },
                        onFieldSubmitted: (value) {
                          amount = double.parse(_countController.text) * walletAccountVo.currencyRate;
                          setState(() {});
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.only(left: 8, top: 8), child: Text("≈ ${amount} ${currencyUnit}")),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                  ],
                ),
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
                  onPressed: walletAccountVo == null ? null : submit,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "下一步",
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
      ),
    );
  }

  void submit() {
    if (_fromKey.currentState.validate()) {
      if (walletAccountVo == null) {
        Fluttertoast.showToast(msg: "账户为空");
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WalletSendConfirmPage(
                    walletAccountVo,
                    double.parse(_countController.text),
                    _receiverAddressController.text,
                    backRouteName: widget.backRouteName,
                  )));
    }
  }

  Future onScan() async {
//    print('TODO scan');
    try {
      String barcode = await BarcodeScanner.scan();
      _receiverAddressController.text = barcode;
      setState(() => {});
    } catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Fluttertoast.showToast(msg: S.of(context).open_camera, toastLength: Toast.LENGTH_SHORT);
      } else {
        logger.e("", e);
        setState(() => _receiverAddressController.text = "");
      }
    }
  }

  Future onPaste() async {
    var text = await Clipboard.getData(Clipboard.kTextPlain);
    _receiverAddressController.text = text.text;
    setState(() {});
  }
}
