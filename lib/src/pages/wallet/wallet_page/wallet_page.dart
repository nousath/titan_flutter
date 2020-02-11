import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/bloc/quotes_cmp_bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';

import 'view/wallet_empty_widget.dart';
import 'view/wallet_show_widget.dart';

class WalletPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletPageState();
  }
}

class _WalletPageState extends State<WalletPage> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    doDidPopNext();
  }

  Future doDidPopNext() async {
//    var activatedWallet = WalletViewModel.of(context, aspect: WalletAspect.activatedWallet).activatedWallet;
//    if (activatedWallet != null) {
//      String defaultWalletFileName = await _walletService.getDefaultWalletFileName();
//      String updateWalletFileName = activatedWallet.wallet.keystore.fileName;
//      if (defaultWalletFileName == updateWalletFileName) {
//        _walletBloc.add(UpdateWalletEvent(activatedWallet));
//      } else {
//        _walletBloc.add(ScanWalletEvent());
//      }
//    } else {
//      _walletBloc.add(ScanWalletEvent());
//    }
  }

  @override
  void initState() {
    super.initState();

    //update quotes
    BlocProvider.of<QuotesCmpBloc>(context).add(UpdateQuotesEvent());
    //update all coin balance
    BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
  }

  @override
  Widget build(BuildContext context) {
    //hyn quote
    ActiveQuoteVoAndSign hynQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign('HYN');

    return Column(
      children: <Widget>[
        Expanded(child: _buildWalletView(context)),
        //hyn quotes view
        Container(
          padding: EdgeInsets.all(8),
          color: Color(0xFFF5F5F5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset(
                        'res/drawable/ic_hyperion.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                    Text(
                      S.of(context).hyn_price,
                      style: TextStyle(color: Color(0xFF6D6D6D), fontSize: 14),
                    ),
                    //Container(width: 100,),
                    Spacer(),
                    //quote
                    Text(
                      '${hynQuoteSign != null ? '${hynQuoteSign.quoteVo.price} ${hynQuoteSign.sign.sign}' : '--'}',
                      style: TextStyle(color: HexColor('#333333'), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildWalletView(BuildContext context) {
    var activatedWalletVo = WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet).activatedWallet;
    if (activatedWalletVo != null) {
      return ShowWalletView(activatedWalletVo);
    }

    return BlocBuilder<WalletCmpBloc, WalletCmpState>(
      builder: (BuildContext context, WalletCmpState state) {
        switch (state.runtimeType) {
          case LoadingWalletState:
            return loadingView(context);
          default:
            return EmptyWalletView();
        }
      },
    );
  }

  Widget loadingView(context) {
    return Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
      ),
    );
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    super.dispose();
  }
}