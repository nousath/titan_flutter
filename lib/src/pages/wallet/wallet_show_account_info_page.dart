import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_detail_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:web3dart/web3dart.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'model/hyn_transfer_history.dart';
import 'model/transtion_detail_vo.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';

class WalletShowAccountInfoPage extends StatefulWidget {
  String hashTx;
  String symbol;
  final bool isContain;

  WalletShowAccountInfoPage(this.hashTx,this.symbol, {this.isContain = false});

  @override
  State<StatefulWidget> createState() {
    return WalletShowAccountInfoPageState();
  }


  static void jumpToAccountInfoPage(BuildContext context, String hashTx, String symbol){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WalletShowAccountInfoPage(
              hashTx,
              symbol,
              isContain: false,
            )));
  }
}

class WalletShowAccountInfoPageState extends BaseState<WalletShowAccountInfoPage> {
  var atlasApi = AtlasApi();
  List<String> _dataTitleList = [];
  List<String> _dataInfoList = List();
  var gasPriceStr = "";
  var isBillPage = false;
  AllPageState _currentState = LoadingState();
  var isContract = false;
  var isToken = false;
  TransactionDetailVo transactionDetail;
  WalletVo walletVo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    loadWalletInfo();

    super.onCreated();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future loadWalletInfo() async {
    //优先进行网络请求获取合约详情信息
    var hynTransferHistory = await atlasApi.queryHYNTxDetail(widget.hashTx);

    walletVo = WalletInheritedModel.of(context).activatedWallet;
    var type = 0;
    if (hynTransferHistory.from == walletVo.wallet.getAtlasAccount().address) {
      type = TransactionType.TRANSFER_OUT;
    } else if (hynTransferHistory.to == walletVo.wallet.getAtlasAccount().address) {
      type = TransactionType.TRANSFER_IN;
    }

    transactionDetail = TransactionDetailVo.fromHynHrc30TransferHistory(
        hynTransferHistory, type, widget.symbol);

    /*if (HYNApi.isHynHrc30ContractAddress(widget.transactionDetail.toAddress) ||
        HYNApi.isHynHrc30ContractAddress(widget.transactionDetail.contractAddress)) {
      widget.transactionDetail = TransactionDetailVo.fromHynHrc30TransferHistory(
          hynTransferHistory, widget.transactionDetail.type, widget.transactionDetail.symbol);
    }*/
    var transDetail = transactionDetail;
    isContract = (transDetail.internalTransactions != null && transDetail.internalTransactions.length != 0);

    isBillPage = (transactionDetail.hynType == MessageType.typeUnMicrostakingReturn ||
        transactionDetail.hynType == MessageType.typeTerminateMap3Return);

    isToken = widget.symbol == SupportedTokens.HYN_RP_HRC30.symbol;
    var fromAddressTitle = HYNApi.toAddressHint(transactionDetail.hynType, true);
    var toAddressTitle = HYNApi.toAddressHint(transactionDetail.hynType, false);

    if (isBillPage) {
      _dataTitleList = [
        S.of(context).transfer_amount,
        fromAddressTitle,
        toAddressTitle,
        S.of(context).description,
      ];
    } else {
      _dataTitleList = [
        S.of(context).transfer_amount,
        S.of(context).transfer_gas_fee,
        fromAddressTitle,
        toAddressTitle,
        S.of(context).transfer_id,
      ];
    }

    var amountText = "";
    var _toAddress = "";
    /*if (isContract) {
      *//*var tempTransDetail = TransactionDetailVo(
        type: transDetail.type,
        amount: ConvertTokenUnit.weiToEther(weiBigInt: transDetail.getAllContractValue()).toDouble(),
      );
      amountText = "${HYNApi.getValueByHynType(
        transDetail.hynType,
        transactionDetail: tempTransDetail,
        getAmountStr: true,
      )}";*//*
    } else {

    }*/

    if(isToken){
      amountText = ConvertTokenUnit.weiToEther(weiBigInt: transDetail.getAllContractValue()).toString();

      InternalTransactions internalTransaction = transDetail?.internalTransactions?.isEmpty??true?null:transDetail.internalTransactions[0];
      _toAddress = WalletUtil.ethAddressToBech32Address(internalTransaction?.to??'0');
    }else{
      amountText = "${HYNApi.getValueByHynType(
        transDetail.hynType,
        transactionDetail: transDetail,
        getAmountStr: true,
      )}";

      var ethAddress = HYNApi.getHynToAddress(transactionDetail);
      _toAddress = WalletUtil.ethAddressToBech32Address(ethAddress);
    }
    amountText = "$amountText ${widget.symbol}";

    var gasPriceGwei = ConvertTokenUnit.weiToGWei(weiBigInt: BigInt.parse(transDetail.gasPrice));
    var gasPriceEth = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(transDetail.gasPrice));
    gasPriceStr = "$gasPriceGwei Gdust";

    var gasLimit = Decimal.parse(transDetail.gas);
    var gasEstimate = "${gasPriceEth * gasLimit} HYN";

    if (isBillPage) {
      _dataInfoList = [
        amountText,
        WalletUtil.ethAddressToBech32Address(transDetail.fromAddress),
        _toAddress,
        "结算(节点终止)",
      ];
    } else {
      _dataInfoList = [
        amountText,
        gasEstimate,
        WalletUtil.ethAddressToBech32Address(transDetail.fromAddress),
        _toAddress,
        transDetail.hash,
      ];
    }

    setState(() {
      _currentState = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(baseTitle: S.of(context).detail),
      body: _pageView(),
    );
  }

  Widget accountInfoItem(String leftText, String rightText,
      {String bottomText, bool normalLine = true, bool isBillItem = false}) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 18, left: 15, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  leftText,
                  style: TextStyles.textC999S13,
                ),
                Spacer(),
                Container(
                  width: 198,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        rightText ?? "",
                        style: TextStyles.textC333S13,
                        textAlign: TextAlign.end,
                      ),
                      if (bottomText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(bottomText, style: TextStyles.textC999S11, textAlign: TextAlign.end),
                        ),
                      if (isBillItem)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text("抵押 ${transactionDetail.getBillDelegate()} HYN",
                              style: TextStyles.textC999S11, textAlign: TextAlign.end),
                        ),
                      if (isBillItem)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text("奖励 ${transactionDetail.getBillReward()} HYN",
                              style: TextStyles.textC999S11, textAlign: TextAlign.end),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (normalLine)
            Divider(
              color: DefaultColors.colorf2f2f2,
              indent: 15,
              endIndent: 15,
              height: 1,
            ),
          if (!normalLine)
            Container(
              height: 11,
              color: DefaultColors.colorf2f2f2,
            )
        ],
      ),
    );
  }

  _pageView() {
    if (_currentState != null) {
      return Scaffold(
        body: AllPageStateContainer(_currentState, () {
          setState(() {
            _currentState = LoadingState();
          });
          loadWalletInfo();
        }),
      );
    }

    var infoItemTitle;
    var infoItemStatusImage;
    getAccountPageTitle(context, transactionDetail,
        (pageTitle, pageStatusImage, pageDetailColor, pageDetailStatusImage) {
      infoItemTitle = pageTitle;
      infoItemStatusImage = pageStatusImage;
    });

    return Container(
      color: DefaultColors.colorf2f2f2,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0, bottom: 20),
                    child: Image.asset(
                      infoItemStatusImage,
                      width: 63,
                      height: 63,
                    ),
                  ),
                  Text(
                    infoItemTitle,
                    style: TextStyle(fontSize: 16, color: DefaultColors.color333, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 34),
                    child: Text(
                      FormatUtil.formatDate(transactionDetail.time, isSecond: true, isMillisecond: true),
                      style: TextStyle(color: DefaultColors.color999, fontSize: 13),
                    ),
                  ),
                  Container(
                    height: 11,
                    color: DefaultColors.colorf2f2f2,
                  )
                ],
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            var leftText = _dataTitleList[index];
            var rightText = _dataInfoList[index];
            if (isBillPage) {
              if (index == 0) {
                return accountInfoItem(leftText, rightText, isBillItem: isBillPage);
              } else if (index == 3) {
                return accountInfoItem(leftText, rightText, normalLine: false);
              }
            } else {
              if (index == 1) {
                var bottomText = "GasPrice($gasPriceStr) * Gas(${transactionDetail.gas})";
                return accountInfoItem(leftText, rightText, bottomText: bottomText);
              } else if (index == 4) {
                return accountInfoItem(leftText, rightText, normalLine: false);
              }
            }
            return accountInfoItem(leftText, rightText);
          }, childCount: _dataTitleList.length)),
          if (!isBillPage)
            SliverToBoxAdapter(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WalletShowAccountDetailPage(
                                transactionDetail,
                                isContain: widget.isContain,
                              )));
                },
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16.0, left: 15),
                        child: Text(
                          S.of(context).check_for_detail_info,
                          style: TextStyles.textC333S13,
                        ),
                      ),
                      Spacer(),
                      Image.asset(
                        "res/drawable/add_position_image_next.png",
                        height: 13,
                      ),
                      SizedBox(
                        width: 15,
                      )
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }


}

void getAccountPageTitle(BuildContext context, TransactionDetailVo transactionDetail, Function function) {
  var pageTitle = "";
  var pageStatusImage = "";
  var pageDetailColor = HexColor("#22F2F2F2");
  var pageDetailStatusImage = "";
  if (transactionDetail.state == 1 || transactionDetail.state == 2) {
    pageTitle = S.of(context).pending;
    pageStatusImage = "res/drawable/ic_transfer_account_info_pending.png";

    pageDetailColor = HexColor("#22F2F2F2");
    pageDetailStatusImage = "res/drawable/ic_transfer_account_detail_pending.png";
  } else if (transactionDetail.state == 3) {
    if (transactionDetail.hynType == MessageType.typeNormal) {
      pageTitle = S.of(context).transfer_successful;
    } else {
      pageTitle = S.of(context).completed;
    }
    pageStatusImage = "res/drawable/ic_transfer_account_info_success.png";

    pageDetailColor = HexColor("#2207C160");
    pageDetailStatusImage = "res/drawable/ic_transfer_account_detail_success.png";
  } else if (transactionDetail.state == 4 || transactionDetail.state == 5) {
    if (transactionDetail.hynType == MessageType.typeNormal) {
      pageTitle = S.of(context).transfer_fail;
    } else {
      pageTitle = S.of(context).failed;
    }
    pageStatusImage = "res/drawable/ic_transfer_account_info_fail.png";

    pageDetailColor = HexColor("#22FF5E5E");
    pageDetailStatusImage = "res/drawable/ic_transfer_account_detail_fail.png";
  }
  function(pageTitle, pageStatusImage, pageDetailColor, pageDetailStatusImage);
}
