import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:titan/src/widget/gas_input_widget.dart';

class Map3NodeCollectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeColletState();
  }
}

class _Map3NodeColletState extends State<Map3NodeCollectPage> {
  TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double minTotal = 0;
  double remainTotal = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var ethQuotePrice = QuotesInheritedModel.of(context).activatedQuoteVoAndSign('ETH')?.quoteVo?.price ?? 0; //
    var coinVo = WalletInheritedModel.of(context).getCoinVoOfHyn();

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("提币")),
      //backgroundColor: Color(0xffF3F0F5),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 18),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text("到账钱包", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 16, right: 8),
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            "res/drawable/map3_node_default_avatar.png",
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text.rich(TextSpan(children: [
                                TextSpan(text: "天道酬勤唐唐", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                TextSpan(text: "", style: TextStyles.textC333S14bold),
                              ])),
                              Container(
                                height: 4,
                              ),
                              Text("${UiUtil.shortEthAddress("钱包地址 oxfdaf89fda47sn43sff", limitLength: 6)}",
                                  style: TextStyles.textC9b9b9bS12),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 16, right: 16),
                      child: Container(
                        color: HexColor("#F2F2F2"),
                        height: 0.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 16, bottom: 12, right: 8),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text("提取数量", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          ),
                          Expanded(
                            child: Text("（可用余额 20，000）", style: TextStyle(color: HexColor("#B8B8B8"))),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 12, right: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "HYN",
                            style: TextStyle(fontSize: 18, color: HexColor("#35393E")),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Flexible(
                            flex: 1,
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: _textEditingController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  focusedErrorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: HexColor("#FF4C3B")),
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  errorStyle: TextStyle(color: HexColor("#FF4C3B"), fontSize: 14),
                                  hintStyle: TextStyle(color: HexColor("#B8B8B8"), fontSize: 12),
                                  labelStyle: TextStyles.textC333S14,
                                  hintText: S.of(context).mintotal_buy(FormatUtil.formatNumDecimal(minTotal)),
                                  //border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                validator: (textStr) {
                                  if (textStr.length == 0) {
                                    return S.of(context).please_input_hyn_count;
                                  } else if (minTotal == 0) {
                                    return "抵押已满";
                                  } else if (int.parse(textStr) < minTotal) {
                                    return S.of(context).mintotal_hyn(FormatUtil.formatNumDecimal(minTotal));
                                  } else if (int.parse(textStr) > remainTotal) {
                                    return "不能超过剩余份额";
                                  } else if (Decimal.parse(textStr) >
                                      Decimal.parse(FormatUtil.coinBalanceHumanRead(coinVo))) {
                                    return S.of(context).hyn_balance_no_enough;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                          ),
                          /*Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: FlatButton(
                              child: Text(
                                "全部提取",
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {},
                            ),
                          ),*/
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: _flatButton(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Text(
                                  "全部提取",
                                  style: TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              ),
                              onTap: () {
                                _formKey.currentState?.validate();
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
                child: Container(
                  color: HexColor("#F4F4F4"),
                ),
              ),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GasInputWidget(
                      currentEthPrice: ethQuotePrice,
                      callback: (double gasPrice, double gasPriceLimit) {
                        print("[input] gasPrice:$gasPrice, gasPriceLimit:$gasPriceLimit");
                      }),
                ),
              ),
            ])),
          ),
          _confirmButtonWidget(),
        ],
      ),
    );
  }

  Widget _flatButton({Widget child, VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: child,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [HexColor("#1096B1"), HexColor("#15B3D3")],
              begin: FractionalOffset(1, 0.5),
              end: FractionalOffset(0, 0.5)),
        ),
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4.0,
          ),
        ],
      ),
      constraints: BoxConstraints.expand(height: 50),
      child: RaisedButton(
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColor)),
          child: Text("提交", style: TextStyle(fontSize: 16, color: Colors.white)),
          onPressed: () {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return EnterWalletPasswordWidget();
                }).then((walletPassword) async {
              if (walletPassword == null) {
                return;
              }
            });
          }),
    );
  }
}