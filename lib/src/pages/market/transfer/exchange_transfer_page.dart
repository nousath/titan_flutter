import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/transfer/exchange_transfer_history_list_page.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/DottedLine.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/plugins/wallet/convert.dart';

class ExchangeTransferPage extends StatefulWidget {
  final String coinSymbol;

  ExchangeTransferPage(this.coinSymbol);

  @override
  State<StatefulWidget> createState() {
    return _ExchangeTransferPageState();
  }
}

class _ExchangeTransferPageState extends BaseState<ExchangeTransferPage> {
  String _selectedCoinSymbol = 'HYN';
  TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _fromExchangeToWallet = false;
  ExchangeApi _exchangeApi = ExchangeApi();
  WalletVo activatedWallet;

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
    activatedWallet = WalletInheritedModel.of(context).activatedWallet;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedCoinSymbol = widget.coinSymbol ?? 'HYN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                _appBar(),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // hide keyboard when touch other widgets
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: ListView(
                                children: <Widget>[
                                  _transferTypeSelection(),
                                  _coinTypeSelection(),
                                  _amount(),
                                  //_transferHint(),
                                ],
                              ),
                            ),
                            _confirm()
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Expanded(
          child: Text(
            S.of(context).exchange_transfer,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ExchangeTransferHistoryListPage(
                          _selectedCoinSymbol,
                        )));
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Image.asset(
              'res/drawable/ic_transfer_history.png',
              width: 20,
              height: 20,
            ),
          ),
        )
      ],
    );
  }

  _transferTypeItem(bool _isExchange) {
    if (_isExchange) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Text(
          S.of(context).exchange_account,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Row(
          children: <Widget>[
            Text(
              S.of(context).wallet,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' (${activatedWallet?.wallet?.keystore?.name ?? ''})',
              style: TextStyle(
                fontSize: 14,
                color: HexColor('#FF999999'),
              ),
            )
          ],
        ),
      );
    }
  }

  _transferTypeSelectDecoration() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: HexColor('#FF0F95B0'),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            Container(
              height: 40,
              child: DottedLine(color: Colors.grey),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: HexColor('#FFCB5454'),
                borderRadius: BorderRadius.circular(10.0),
              ),
            )
          ],
        ),
      ),
    );
  }

  _transferTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              _transferTypeSelectDecoration(),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 50,
                            child: Text(
                              S.of(context).exchange_from,
                              style: TextStyle(
                                color: HexColor('#FF777777'),
                              ),
                            ),
                          ),
                          _transferTypeItem(_fromExchangeToWallet),
                        ],
                      ),
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 50,
                          child: Text(
                            S.of(context).exchange_to,
                            style: TextStyle(
                              color: HexColor('#FF777777'),
                            ),
                          ),
                        ),
                        _transferTypeItem(!_fromExchangeToWallet),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 8,
              ),
              InkWell(
                child: Image.asset(
                  'res/drawable/ic_btn_transfer.png',
                  width: 50,
                  height: 50,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    _fromExchangeToWallet = !_fromExchangeToWallet;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _coinTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            S.of(context).coin_type,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        InkWell(
          child: Row(
            children: <Widget>[
              Text(
                _getTokenNameBySymbol(_selectedCoinSymbol),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: HexColor('#FF999999'),
                ),
              )
            ],
          ),
          onTap: () {
            _showCoinSelectDialog();
          },
        ),
        Divider()
      ],
    );
  }

  _getTokenNameBySymbol(String symbol) {
    if (symbol == SupportedTokens.HYN_Atlas.symbol) {
      return 'HYN';
    } else if (symbol == SupportedTokens.USDT_ERC20.symbol) {
      return 'USDT';
    } else if (symbol == SupportedTokens.HYN_RP_HRC30.symbol) {
      return 'RP';
    } else {
      return '';
    }
  }

  _showCoinSelectDialog() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
        ),
        builder: (BuildContext context) {
          return Container(
            height: 170,
            child: Column(
              children: <Widget>[
                _coinItem('HYN'),
                // _coinItem('ETH'),
                _coinItem('USDT'),
                //   _coinItem('RP'),

                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        S.of(context).cancel,
                        style: TextStyle(
                          color: HexColor('#FF777777'),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  _confirm() {
    return Container(
      width: double.infinity,
      height: 50,
      child: RaisedButton(
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
              borderRadius: BorderRadius.circular(4.0)),
          child: Text(
            _fromExchangeToWallet
                ? S.of(context).exchange_withdraw
                : S.of(context).exchange_deposit,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          onPressed: () async {
            debounce(() {
              FocusScope.of(context).requestFocus(FocusNode());
              if (_formKey.currentState.validate()) {
                _transfer();
              }
            }, 200)();
          }),
    );
  }

  _divider(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: HexColor('#FFEEEEEE'),
    );
  }

  _coinItem(String symbol) {
    return Column(
      children: [
        InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                _getTokenNameBySymbol(symbol),
                style: TextStyle(
                    color: _selectedCoinSymbol == symbol
                        ? Theme.of(context).primaryColor
                        : HexColor('#FF777777')),
              ),
            ),
          ),
          onTap: () {
            setState(() {
              _selectedCoinSymbol = symbol;
              // _gasFeeFullStrFunc();
            });
            Navigator.of(context).pop();
          },
        ),
        _divider(1)
      ],
    );
  }

  _amount() {
    var _minTransferText = _fromExchangeToWallet
        ? S.of(context).exchange_withdraw_min
        : S.of(context).exchange_deposit_min;

    ///no limit in deposit
    var _maxTransferText = S.of(context).exchange_withdraw_max;

    var _amountInputHint = _fromExchangeToWallet
        ? S.of(context).exchange_deposit_input_hint
        : S.of(context).exchange_withdraw_input_hint;
    var _minTransferAmount = _fromExchangeToWallet
        ? ExchangeInheritedModel.of(context)
                .exchangeModel
                .activeAccount
                ?.assetList
                ?.getAsset(_selectedCoinSymbol)
                ?.withdrawMin ??
            '0'
        : ExchangeInheritedModel.of(context)
                .exchangeModel
                .activeAccount
                ?.assetList
                ?.getAsset(_selectedCoinSymbol)
                ?.rechargeMin ??
            '0';
    var _maxTransferAmount = ExchangeInheritedModel.of(context)
            .exchangeModel
            .activeAccount
            .assetList
            ?.getAsset(_selectedCoinSymbol)
            ?.withdrawMax ??
        '0';

    var minAndMaxAmountHint = '';

    if (_fromExchangeToWallet) {
      minAndMaxAmountHint =
          '$_minTransferText $_minTransferAmount $_selectedCoinSymbol' +
              ',' +
              '$_maxTransferText $_maxTransferAmount $_selectedCoinSymbol';
    } else {
      minAndMaxAmountHint =
          '$_minTransferText $_minTransferAmount $_selectedCoinSymbol';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(S.of(context).exchange_transfer_amount),
              SizedBox(
                width: 8.0,
              ),
              Text(
                '($minAndMaxAmountHint)',
                style: TextStyle(
                  color: HexColor('#FFAAAAAA'),
                  fontSize: 11,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _amountController,
                  validator: (value) {
                    value = value.trim();
                    if (value == '0') {
                      return S.of(context).input_corrent_count_hint;
                    }
                    if (!RegExp(r"\d+(\.\d+)?$").hasMatch(value)) {
                      return S.of(context).input_corrent_count_hint;
                    }

                    if (Decimal.parse(value) >
                        Decimal.parse(_availableAmount())) {
                      return S.of(context).input_count_over_balance;
                    }

                    if (Decimal.parse(value) >
                            Decimal.parse(_maxTransferAmount) &&
                        _fromExchangeToWallet) {
                      return S.of(context).exchange_withdraw_over_than_max;
                    }

                    if (Decimal.parse(value) <
                        Decimal.parse(_minTransferAmount)) {
                      return _fromExchangeToWallet
                          ? S.of(context).exchange_withdraw_less_than_min
                          : S.of(context).exchange_deposit_less_than_min;
                    }

                    return null;
                  },
                  onChanged: (data) {
                    _formKey.currentState.validate();
                  },
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: HexColor('#FFD7D7D7'),
                      )),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: HexColor('#FFD7D7D7'),
                      )),
                      hintText: _amountInputHint,
                      hintStyle: TextStyle(
                        color: HexColor('#FF999999'),
                        fontSize: 12,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          width: 150,
                          child: Row(
                            children: <Widget>[
                              Spacer(),
                              Text(
                                _selectedCoinSymbol,
                                style: TextStyle(
                                  color: HexColor('#FF777777'),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '  |  ',
                                style: TextStyle(color: HexColor('#FFD8D8D8')),
                              ),
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    S.of(context).all,
                                    style: TextStyle(
                                        color: HexColor('#FF333333'),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onTap: () {
                                  _amountController.text = _availableAmount();

                                  _amountController.selection =
                                      TextSelection.fromPosition(TextPosition(
                                    affinity: TextAffinity.downstream,
                                    offset: _amountController.text.length,
                                  ));
                                  _formKey.currentState.validate();
                                  setState(() {});
                                },
                              )
                            ],
                          ),
                        ),
                      )),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          children: <Widget>[
            Spacer(),
            Text.rich(TextSpan(children: [
              TextSpan(
                text:
                    '${_fromExchangeToWallet ? S.of(context).exchange_account_balance : S.of(context).exchange_wallet_balance} ',
                style: TextStyle(
                  color: HexColor('#FFAAAAAA'),
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: _availableAmount(),
                style: TextStyle(
                  color: HexColor('#FF333333'),
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: ' $_selectedCoinSymbol',
                style: TextStyle(
                  color: HexColor('#FFAAAAAA'),
                  fontSize: 12,
                ),
              ),
            ])),
          ],
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  _availableAmount() {
    if (_fromExchangeToWallet) {
      var _exchangeAvailable = ExchangeInheritedModel.of(context)
          .exchangeModel
          .activeAccount
          ?.assetList
          ?.getAsset(_selectedCoinSymbol)
          ?.exchangeAvailable;
      if (_exchangeAvailable != null) {
        return FormatUtil.truncateDecimalNum(
            Decimal.parse(_exchangeAvailable), 6);
      } else {
        return '0';
      }
    } else {
      return FormatUtil.coinBalanceByDecimal(
        WalletInheritedModel.of(
          context,
          aspect: WalletAspect.activatedWallet,
        ).getCoinVoBySymbol(_selectedCoinSymbol),
        6,
      );
    }
  }

  _transfer() async {
    try {
      if (_fromExchangeToWallet) {
        _withdraw();
      } else {
        ///HYN-Atlas and HYN-ERC20 both use symbol [HYN]
        var symbol = _selectedCoinSymbol == SupportedTokens.HYN_ERC20.symbol
            ? SupportedTokens.HYN_Atlas.symbol
            : _selectedCoinSymbol;
        var ret = await _exchangeApi.getAddress(symbol);
        var exchangeAddress = ret['address'];
        _deposit(exchangeAddress);
      }
    } catch (e) {
      if (e is HttpResponseCodeNotSuccess) {
        Fluttertoast.showToast(msg: e.message);
      }
    }
  }

  _deposit(String exchangeAddress) async {
    if (context == null) return;

    var coinVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbol(_selectedCoinSymbol);

    var voStr = FluroConvertUtils.object2string(coinVo.toJson());
    Application.router.navigateTo(
      context,
      '${Routes.exchange_deposit_confirm_page}?coinVo=$voStr&transferAmount=${_amountController.text}&exchangeAddress=$exchangeAddress',
    );
  }

  _withdraw() async {
    var coinVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbol(_selectedCoinSymbol);
    var coinVoStr = FluroConvertUtils.object2string(coinVo.toJson());

    var _withdrawAmount = _amountController.text;

    var _withDrawFeeByGas = ExchangeInheritedModel.of(context)
        .exchangeModel
        .activeAccount
        .assetList
        ?.getAsset(_selectedCoinSymbol)
        ?.withdrawFeeByGas;

    Application.router.navigateTo(
      context,
      '${Routes.exchange_withdraw_confirm_page}?coinVo=$coinVoStr&amount=$_withdrawAmount&withdrawFeeByGas=$_withDrawFeeByGas',
    );
  }
}
