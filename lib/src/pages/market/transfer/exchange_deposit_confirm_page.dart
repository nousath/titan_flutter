import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:web3dart/json_rpc.dart';

class ExchangeDepositConfirmPage extends StatefulWidget {
  final CoinVo coinVo;
  final String transferAmount;
  final String exchangeAddress;

  ExchangeDepositConfirmPage(
    String coinVo,
    this.transferAmount,
    this.exchangeAddress,
  ) : coinVo = CoinVo.fromJson(FluroConvertUtils.string2map(coinVo));

  @override
  State<StatefulWidget> createState() {
    return _ExchangeDepositConfirmPageState();
  }
}

class _ExchangeDepositConfirmPageState
    extends BaseState<ExchangeDepositConfirmPage> {
  var isTransferring = false;
  var isLoadingGasFee = false;

  int selectedPriceLevel = 1;

  WalletVo activatedWallet;
  ActiveQuoteVoAndSign activatedQuoteSign;
  var gasPriceRecommend;

  @override
  void onCreated() {
    activatedQuoteSign = WalletInheritedModel.of(context)
        .activatedQuoteVoAndSign(widget.coinVo.symbol);
    activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    if (widget.coinVo.coinType == CoinType.BITCOIN) {
      gasPriceRecommend =
          WalletInheritedModel.of(context, aspect: WalletAspect.gasPrice)
              .btcGasPriceRecommend;
    } else {
      gasPriceRecommend =
          WalletInheritedModel.of(context, aspect: WalletAspect.gasPrice)
              .gasPriceRecommend;
    }
    _speedOnTap(1);
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<WalletCmpBloc>(context).add(UpdateGasPriceEvent());
  }

  Decimal get gasPrice {
    if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
      return Decimal.fromInt(1 * TokenUnit.G_WEI);
    }
    switch (selectedPriceLevel) {
      case 0:
        return gasPriceRecommend.safeLow;
      case 1:
        return gasPriceRecommend.average;
      case 2:
        return gasPriceRecommend.fast;
      default:
        return gasPriceRecommend.average;
    }
  }

  @override
  Widget build(BuildContext context) {
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    var quoteSign = activatedQuoteSign?.sign?.sign;
    var gasPriceEstimateStr = "";
    if (widget.coinVo.coinType == CoinType.BITCOIN) {
      gasPriceRecommend = WalletInheritedModel.of(
        context,
        aspect: WalletAspect.gasPrice,
      ).btcGasPriceRecommend;
      var fees = ConvertTokenUnit.weiToDecimal(
        BigInt.parse((gasPrice * Decimal.fromInt(BitcoinConst.BTC_RAWTX_SIZE))
            .toString()),
        8,
      );
      var gasPriceEstimate = fees * Decimal.parse(quotePrice.toString());
      gasPriceEstimateStr =
          "$fees BTC (≈ $quoteSign${FormatUtil.formatPrice(gasPriceEstimate.toDouble())})";
    } else if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
      //var gasPrice = Decimal.fromInt(1 * TokenUnit.G_WEI); // 1Gwei, TODO 写死1GWEI
      var hynQuotePrice = WalletInheritedModel.of(context)
              .activatedQuoteVoAndSign('HYN')
              ?.quoteVo
              ?.price ??
          0;
      var gasLimit = SettingInheritedModel.ofConfig(context)
          .systemConfigEntity
          .ethTransferGasLimit;
      var gasEstimate = ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse(
              (gasPrice * Decimal.fromInt(gasLimit)).toStringAsFixed(0)));
      var gasPriceEstimate =
          gasEstimate * Decimal.parse(hynQuotePrice.toString());
      gasPriceEstimateStr =
          '${(gasPrice / Decimal.fromInt(TokenUnit.G_WEI)).toStringAsFixed(1)} G_DUST (≈ $quoteSign${FormatUtil.formatCoinNum(gasPriceEstimate.toDouble())})';
    } else {
      var ethQuotePrice = WalletInheritedModel.of(context)
              .activatedQuoteVoAndSign('ETH')
              ?.quoteVo
              ?.price ??
          0;
      gasPriceRecommend =
          WalletInheritedModel.of(context, aspect: WalletAspect.gasPrice)
              .gasPriceRecommend;
      var gasLimit = widget.coinVo.symbol == "ETH"
          ? SettingInheritedModel.ofConfig(context)
              .systemConfigEntity
              .ethTransferGasLimit
          : SettingInheritedModel.ofConfig(context)
              .systemConfigEntity
              .erc20TransferGasLimit;
      var gasEstimate = ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse(
              (gasPrice * Decimal.fromInt(gasLimit)).toStringAsFixed(0)));
      var gasPriceEstimate =
          gasEstimate * Decimal.parse(ethQuotePrice.toString());
      gasPriceEstimateStr =
          "${(gasPrice / Decimal.fromInt(TokenUnit.G_WEI)).toStringAsFixed(1)} GWEI (≈ $quoteSign${FormatUtil.formatPrice(gasPriceEstimate.toDouble())})";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          S.of(context).exchange_deposit_confirm,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Color(0xFFF5F5F5),
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          ExtendsIconFont.send,
                          color: Theme.of(context).primaryColor,
                          size: 48,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8),
                          child: Text(
                            "-${widget.transferAmount} ${widget.coinVo.symbol}",
                            style: TextStyle(
                                color: Color(0xFF252525),
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                        Text(
                          "≈ $quoteSign${FormatUtil.formatPrice(double.parse(widget.transferAmount) * quotePrice)}",
                          style:
                              TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "From",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: HexColor('#FF999999'),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "${activatedWallet.wallet.keystore.name}",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF333333),
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                              Text(
                                "(${shortBlockChainAddress(WalletUtil.formatToHynAddrIfAtlasChain(
                                  widget.coinVo,
                                  widget.coinVo.address,
                                ))})",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF999999),
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              )
                            ],
                          ))
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                height: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "To",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: HexColor('#FF999999'),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            S.of(context).exchange_account,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          )),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                height: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${S.of(context).gas_fee}(${widget.coinVo.symbol == SupportedTokens.HYN_Atlas.symbol ? 'HYN' : 'ETH'})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: HexColor('#FF999999'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          height: 24,
                          child: Text(
                            gasPriceEstimateStr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isLoadingGasFee)
                          Container(
                            width: 24,
                            height: 24,
                            child: CupertinoActivityIndicator(),
                          )
                      ],
                    ),
                  ),
                  if (widget.coinVo.symbol != SupportedTokens.HYN_Atlas.symbol)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 12),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _speedOnTap(0);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: selectedPriceLevel == 0
                                        ? Colors.grey
                                        : Colors.grey[200],
                                    border: Border(),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        bottomLeft: Radius.circular(30))),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      S.of(context).speed_slow,
                                      style: TextStyle(
                                          color: selectedPriceLevel == 0
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      S.of(context).wait_min(gasPriceRecommend
                                          .safeLowWait
                                          .toString()),
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.black38),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            thickness: 2,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _speedOnTap(1);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: selectedPriceLevel == 1
                                        ? Colors.grey
                                        : Colors.grey[200],
                                    border: Border(),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(0))),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      S.of(context).speed_normal,
                                      style: TextStyle(
                                          color: selectedPriceLevel == 1
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      S.of(context).wait_min(
                                          gasPriceRecommend.avgWait.toString()),
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.black38),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            thickness: 2,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _speedOnTap(2);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: selectedPriceLevel == 2
                                        ? Colors.grey
                                        : Colors.grey[200],
                                    border: Border(),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30),
                                        bottomRight: Radius.circular(30))),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      S.of(context).speed_fast,
                                      style: TextStyle(
                                          color: selectedPriceLevel == 2
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      S.of(context).wait_min(gasPriceRecommend
                                          .fastWait
                                          .toString()),
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.black38),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
            SizedBox(
              height: 36,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 36, horizontal: 36),
              constraints: BoxConstraints.expand(height: 48),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                disabledColor: Colors.grey[600],
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                disabledTextColor: Colors.white,
                onPressed: isTransferring ? null : _transfer,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        isTransferring
                            ? S.of(context).please_waiting
                            : S.of(context).send,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
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

  void _speedOnTap(int index) {
    setState(() {
      selectedPriceLevel = index;
    });
  }

  Future _transfer() async {
    var walletPassword = await UiUtil.showWalletPasswordDialogV2(
      context,
      activatedWallet.wallet,
    );

    _transferWithPwd(walletPassword);
  }

  _transferWithPwd(String walletPassword) async {
    if (walletPassword == null) {
      return;
    }
    try {
      setState(() {
        isTransferring = true;
      });
      var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
      if (widget.coinVo.symbol == "ETH") {
        await _transferEth(
          walletPassword,
          ConvertTokenUnit.strToBigInt(
              widget.transferAmount, widget.coinVo.decimals),
          widget.exchangeAddress,
          activatedWallet.wallet,
        );
      } else if (widget.coinVo.coinType == CoinType.BITCOIN) {
        var activatedWalletVo = activatedWallet.wallet;
        var transResult = await activatedWalletVo.sendBitcoinTransaction(
            walletPassword,
            activatedWalletVo.getBitcoinZPub(),
            widget.exchangeAddress,
            gasPrice.toInt(),
            ConvertTokenUnit.decimalToWei(
                    Decimal.parse(widget.transferAmount), 8)
                .toInt());
        if (transResult["code"] != 0) {
          LogUtil.uploadException(transResult, "bitcoin upload");
          Fluttertoast.showToast(
              msg: "${transResult.toString()}", toastLength: Toast.LENGTH_LONG);
          return;
        }
      } else if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
        await HYNApi.sendTransferHYN(
          walletPassword,
          activatedWallet.wallet,
          toAddress: widget.exchangeAddress,
          amount: ConvertTokenUnit.strToBigInt(
            widget.transferAmount,
            widget.coinVo.decimals,
          ),
        );
      } else {
        await _transferErc20(
          walletPassword,
          ConvertTokenUnit.strToBigInt(
            widget.transferAmount,
            widget.coinVo.decimals,
          ),
          widget.exchangeAddress,
          activatedWallet.wallet,
        );
      }

      var msg;
      if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
        msg = S.of(context).atlas_transfer_broadcast_success_description;
      } else {
        msg = S.of(context).transfer_broadcase_success_description;
      }
      msg = FluroConvertUtils.fluroCnParamsEncode(msg);
      Application.router
          .navigateTo(context, Routes.confirm_success_papge + '?msg=$msg');

    } catch (_) {
      LogUtil.uploadException(_, "ETH or Bitcoin upload");
      setState(() {
        isTransferring = false;
      });
      if (_ is PlatformException) {
        if (_.code == WalletError.PASSWORD_WRONG) {
          Fluttertoast.showToast(msg: S.of(context).password_incorrect);
        } else {
          Fluttertoast.showToast(msg: S.of(context).transfer_fail);
        }
      } else if (_ is RPCError) {
        Fluttertoast.showToast(
            msg: MemoryCache.contractErrorStr(_.message),
            toastLength: Toast.LENGTH_LONG);
      } else {
        Fluttertoast.showToast(msg: S.of(context).transfer_fail);
      }
    }
  }

  Future _transferEth(
    String password,
    BigInt amount,
    String toAddress,
    Wallet wallet,
  ) async {
    final txHash = await wallet.sendEthTransaction(
      password: password,
      toAddress: toAddress,
      gasPrice: BigInt.parse(gasPrice.toStringAsFixed(0)),
      value: amount,
    );

    logger.i(
        'ETH transaction committed，txhash $txHash exchangeAddress: $toAddress walletAddress: ${activatedWallet.wallet.getEthAccount().address}');
  }

  Future _transferErc20(
    String password,
    BigInt amount,
    String toAddress,
    Wallet wallet,
  ) async {
    var contractAddress = widget.coinVo.contractAddress;

    final txHash = await wallet.sendErc20Transaction(
      contractAddress: contractAddress,
      password: password,
      gasPrice: BigInt.parse(gasPrice.toStringAsFixed(0)),
      value: amount,
      toAddress: toAddress,
    );

    logger.i(
        'HYN transaction committed，txhash $txHash exchangeAddress: $toAddress walletAddress: ${activatedWallet.wallet.getEthAccount().address}');
  }
}
