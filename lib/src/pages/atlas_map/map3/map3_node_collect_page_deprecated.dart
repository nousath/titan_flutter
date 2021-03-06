import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
import 'package:titan/src/widget/wallet_widget.dart';

class Map3NodeCollectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeCollectState();
  }
}

class _Map3NodeCollectState extends State<Map3NodeCollectPage> {
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
    //var ethQuotePrice = WalletInheritedModel.of(context).activatedQuoteVoAndSign('ETH')?.quoteVo?.price ?? 0; //
    var coinVo = WalletInheritedModel.of(context).getCoinVoOfHyn();

    return Scaffold(
      appBar: BaseAppBar(
        baseTitle:S.of(context).collect_reward,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: BaseGestureDetector(
              context: context,
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
                              child: Text(S.of(context).receive_wallet, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16, right: 8),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 42,
                              height: 42,
                              child: walletHeaderWidget(
                                "_map3infoEntity.name",
                                isShowShape: false,
                                address: "0xcccc",
                                isCircle: false,
                              ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                "HYN",
                                style: TextStyle(fontSize: 18, color: HexColor("#35393E")),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Flexible(
                              flex: 1,
                              child: Form(
                                key: _formKey,
                                child: RoundBorderTextField(
                                  controller: _textEditingController,
                                  keyboardType: TextInputType.number,
                                  //inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                  hint: "请输入数量",
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              ])),
            ),
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
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, top: 10),
        child: Center(
          child: ClickOvalButton(
            "确认提取",
            () {
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
            },
            height: 46,
            width: MediaQuery.of(context).size.width - 37 * 2,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
