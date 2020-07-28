import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_k_chart/entity/k_line_entity.dart';
import 'package:flutter_k_chart/utils/number_util.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_config.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/entity/market_symbol_list.dart';
import 'package:titan/src/pages/market/exchange_assets_page.dart';
import 'package:titan/src/pages/market/exchange/bloc/exchange_bloc.dart';
import 'package:titan/src/pages/market/exchange/bloc/exchange_state.dart';
import 'package:titan/src/pages/market/exchange/exchange_auth_page.dart';
import 'package:titan/src/pages/market/exchange_detail/exchange_detail_page.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/click_oval_icon_button.dart';

import '../quote/kline_detail_page.dart';
import 'bloc/bloc.dart';

class ExchangePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExchangePageState();
  }
}

class _ExchangePageState extends BaseState<ExchangePage> {
  var _selectedCoin = 'USDT';
  var _exchangeType = ExchangeType.SELL;
  ExchangeBloc _exchangeBloc = ExchangeBloc();
  List<MarketItemEntity> _marketItemList = List();
  ExchangeApi _exchangeApi = ExchangeApi();
  double usdtToCurrency;
  double ethToCurrency;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _exchangeBloc.close();
  }

  @override
  void onCreated() {
    // TODO: implement onCreated
    ///
    super.onCreated();
    BlocProvider.of<SocketBloc>(context).add(SubChannelEvent(
      channel: SocketConfig.channelKLine24Hour,
    ));
    _initCurrency();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAllSymbols();
    _sub24HourChannel();
  }

  _initCurrency() async {
    usdtToCurrency = await _getCurrencyFromType(
      'USDT',
      QuotesInheritedModel.of(context)
          .activatedQuoteVoAndSign('USDT')
          ?.sign
          ?.quote,
    );

    ethToCurrency = await _getCurrencyFromType(
      'ETH',
      QuotesInheritedModel.of(context)
          .activatedQuoteVoAndSign('USDT')
          ?.sign
          ?.quote,
    );
    setState(() {});
  }

  _getAllSymbols() async {
    var response = await _exchangeApi.getMarketAllSymbol();

    MarketSymbolList marketSymbolList = MarketSymbolList.fromJson(response);

    if (marketSymbolList.hynusdt != null) {
      _marketItemList.add(MarketItemEntity(
        'hynusdt',
        marketSymbolList.hynusdt,
        symbolName: 'USDT',
      ));
    }
    if (marketSymbolList.hyneth != null) {
      _marketItemList.add(MarketItemEntity(
        'hyneth',
        marketSymbolList.hyneth,
        symbolName: 'ETH',
      ));
    }
//    if (marketSymbolList.hynbtc != null) {
//      _marketItemList.add(MarketItemEntity(
//        'hynbtc',
//        marketSymbolList.hynbtc,
//        symbolName: 'HYN/BTC',
//      ));
//    }
    setState(() {});
  }

  // 24hour
  void _sub24HourChannel() {
    var channel = SocketConfig.channelKLine24Hour;
    _subChannel(channel);
  }

  // sub
  void _subChannel(String channel) {
    BlocProvider.of<SocketBloc>(context).add(SubChannelEvent(channel: channel));
  }

  _updateMarketItemList(dynamic data,
      {bool isReplace = true, String symbol = ''}) {
    if (!(data is List)) {
      return;
    }

    List dataList = data;
    List kLineDataList = dataList.map((item) {
      Map<String, dynamic> json = {};
      if (item is List) {
        List itemList = item;
        if (itemList.length >= 7) {
          json = {
            'open': double.parse(itemList[1].toString()),
            'high': double.parse(itemList[2].toString()),
            'low': double.parse(itemList[3].toString()),
            'close': double.parse(itemList[4].toString()),
            'vol': double.parse(itemList[5].toString()),
            'amount': 0,
            'count': 0,
            'id': int.parse(itemList[0].toString()) / 1000,
          };
        }
      }
      return KLineEntity.fromJson(json);
    }).toList();
    bool _isNewSymbol = true;
    _marketItemList.forEach((element) {
      if (element.symbol == symbol) {
        _isNewSymbol = false;
        element = MarketItemEntity(symbol, kLineDataList.last);
      }
    });
    print('_updateQuoteItemList: isNewSymbol: $_isNewSymbol');
    if (_isNewSymbol) {
      _marketItemList.add(MarketItemEntity(symbol, kLineDataList.last));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ExchangeBloc, ExchangeState>(
          bloc: _exchangeBloc,
          listener: (context, state) {},
        ),
        BlocListener<SocketBloc, SocketState>(
          listener: (context, state) {
            if (state is SubChannelState) {
              print('[ExchangePage] SubChannelState :${state.period}');
            } else if (state is ReceivedDataState) {
              print('[ExchangePage] ReceivedDataState: ${state.response}');
            } else if (state is ChannelKLine24HourState) {
              _updateMarketItemList(state.response, symbol: state.symbol);
            }
          },
        ),
      ],
      child: BlocBuilder<ExchangeBloc, ExchangeState>(
        bloc: _exchangeBloc,
        builder: (context, state) {
          if (state is SwitchToAuthState) {
            return ExchangeAuthPage();
          } else if (state is SwitchToContentState) {
            return _contentView();
          }
          return _contentView();
        },
      ),
    );
  }

  _contentView() {
    return Column(
      children: <Widget>[
        _banner(),
        _account(),
        _exchange(),
        _divider(),
        _quotesView(),
        _authorizedView()
      ],
    );
  }

  _banner() {
    return Container(
      color: HexColor('#141FB9C7'),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.hearing,
                size: 20,
              ),
            ),
            Expanded(
              child: Text(
                '由于网络拥堵，近期闪兑交易矿工费较高',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
              ),
            )
          ],
        ),
      ),
    );
  }

  _exchange() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            elevation: 3.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                children: <Widget>[
                  _exchangeItem(_exchangeType == ExchangeType.SELL),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Image.asset(
                        'res/drawable/market_exchange_btn_icon.png',
                        width: 25,
                        height: 25,
                      ),
                      onPressed: () {
                        setState(() {
                          _exchangeType = _exchangeType == ExchangeType.BUY
                              ? ExchangeType.SELL
                              : ExchangeType.BUY;
                        });
                      },
                    ),
                  ),
                  _exchangeItem(_exchangeType == ExchangeType.BUY),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 8.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '汇率',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              Text(
                _exchangeType == ExchangeType.SELL
                    ? '1HYN = ${_getMarketItem(_selectedCoin)?.kLineEntity?.close ?? '--'} $_selectedCoin'
                    : '1$_selectedCoin = ${1 / (_getMarketItem(_selectedCoin)?.kLineEntity?.close) ?? '--'} HYN',
              ),
              Spacer(),
              ClickOvalIconButton(
                '交易',
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ExchangeDetailPage(
                              selectedCoin: _selectedCoin,
                              exchangeType: _exchangeType)));
                },
                width: 88,
                height: 38,
                radius: 6,
                child: Icon(
                  Icons.arrow_forward,
                  size: 15,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 8,
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: HexColor('#FFF2F2F2'),
              borderRadius: BorderRadius.circular(3.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    '24H 量 ${_getMarketItem(_selectedCoin)?.kLineEntity?.amount ?? '--'} ',
                    style: TextStyle(
                      color: HexColor('#FF999999'),
                      fontSize: 14,
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: Text(
                      '最新兑换1HYN — ${_getMarketItem(_selectedCoin)?.kLineEntity?.close ?? '--'} $_selectedCoin',
                      style: TextStyle(
                        color: HexColor('#FF999999'),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 16,
        )
      ],
    );
  }

  _account() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          if (ExchangeInheritedModel.of(context).exchangeModel.activeAccount !=
              null) {
            Application.router.navigateTo(
                context,
                Routes.exchange_assets_page +
                    '?entryRouteName=${Uri.encodeComponent(Routes.exchange_assets_page)}');
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ExchangeAuthPage()));
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Image.asset(
                'res/drawable/ic_market_account.png',
                width: 20,
                height: 20,
              ),
            ),
            Text(
              '交易账户',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 17,
              ),
            ),
            Spacer(),
            _assetView(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            )
          ],
        ),
      ),
    );
  }

  _assetView() {
    var symbolQuote =
        QuotesInheritedModel.of(context).activatedQuoteVoAndSign('USDT');
    if (ExchangeInheritedModel.of(context).exchangeModel.activeAccount !=
        null) {
      return Text.rich(
        TextSpan(children: [
          TextSpan(
              text: ExchangeInheritedModel.of(context)
                      .exchangeModel
                      .isShowBalances
                  ? "${FormatUtil.formatPrice(10000.0 * (symbolQuote?.quoteVo?.price ?? 0))}"
                  : '******'),
          TextSpan(
              text: ' (${symbolQuote?.sign?.quote ?? ''})',
              style: TextStyle(color: Colors.grey, fontSize: 13))
        ]),
        textAlign: TextAlign.center,
      );
    } else {
      return Text('未授权登录');
    }
  }

  _exchangeItem(bool isHynCoin) {
    return isHynCoin
        ? Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _coinItem(
                'HYN',
                'res/drawable/hyn_logo.png',
                false,
              ),
            ),
          )
        : Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _coinList(),
            ),
          );
  }

  _coinItem(
    String name,
    String logoPath,
    bool isOnlinePath,
  ) {
    return Row(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF9B9B9B), width: 0),
            shape: BoxShape.circle,
          ),
          child: isOnlinePath
              ? FadeInImage.assetNetwork(
                  placeholder: 'res/drawable/img_placeholder_circle.png',
                  image: logoPath,
                  fit: BoxFit.cover,
                )
              : Image.asset(logoPath),
        ),
        SizedBox(
          width: 8.0,
        ),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
        )
      ],
    );
  }

  _coinList() {
    List<DropdownMenuItem> availableCoinItemList = List();
    availableCoinItemList.add(
      DropdownMenuItem(
        value: 'USDT',
        child: _coinItem(
          'USDT',
          'res/drawable/usdt_logo.png',
          false,
        ),
      ),
    );
    availableCoinItemList.add(
      DropdownMenuItem(
        value: 'ETH',
        child: _coinItem(
          'ETH',
          'res/drawable/eth_logo.png',
          false,
        ),
      ),
    );

    return DropdownButtonHideUnderline(
      child: DropdownButton(
        onChanged: (value) {
          setState(() {
            _selectedCoin = value;
          });
        },
        value: _selectedCoin,
        items: availableCoinItemList,
      ),
    );
  }

  _quotesView() {
    return Expanded(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '名称',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '最新价',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Spacer(),
                      Text(
                        '跌涨幅',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _quotesItemList()
        ],
      ),
    );
  }

  _quotesItemList() {
    return Expanded(
      child: ListView.builder(
          itemCount: _marketItemList.length,
          itemBuilder: (context, index) {
            return _marketItem(_marketItemList[index]);
          }),
    );
  }

  _marketItem(MarketItemEntity marketItemEntity) {
    var symbolQuote =
        QuotesInheritedModel.of(context).activatedQuoteVoAndSign('USDT');

    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => KLineDetailPage()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: 'HYN',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontSize: 20,
                        )),
                    TextSpan(
                        text: '/${marketItemEntity.symbolName}',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                          fontSize: 16,
                        )),
                  ])),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    '24H量 ${marketItemEntity.kLineEntity.amount}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${FormatUtil.formatPrice(marketItemEntity.kLineEntity.close)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      '${symbolQuote?.sign?.sign} ${_getCurrencyFromMarketItem(marketItemEntity)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Spacer(),
                  Container(
                    width: 80,
                    height: 39,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: marketItemEntity.kLineEntity.close -
                                  marketItemEntity.kLineEntity.open >
                              0
                          ? HexColor('#FF53AE86')
                          : HexColor('#FFCC5858'),
                    ),
                    child: Center(
                      child: Text(
                        '${(marketItemEntity.kLineEntity.close - marketItemEntity.kLineEntity.open) > 0 ? '+' : ''}${(marketItemEntity.kLineEntity.close - marketItemEntity.kLineEntity.open) / marketItemEntity.kLineEntity.open * 100}%',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  MarketItemEntity _getMarketItem(String coinType) {
    var result;
    _marketItemList.forEach((element) {
      if (element.symbolName == coinType) {
        result = element;
      }
    });
    return result;
  }

  Future<double> _getCurrencyFromType(String type, String currency) async {
    var ret = await _exchangeApi.type2currency(type, currency);
    return double.parse(ret.toString());
  }

  _getCurrencyFromMarketItem(MarketItemEntity marketItemEntity) {
    return marketItemEntity.symbolName == 'USDT'
        ? usdtToCurrency == null
            ? '--'
            : FormatUtil.formatPrice(
                usdtToCurrency * marketItemEntity.kLineEntity.close)
        : ethToCurrency == null
            ? '--'
            : FormatUtil.formatPrice(
                ethToCurrency * marketItemEntity.kLineEntity.close);
  }

  Widget _authorizedView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Spacer(),
          Image.asset(
            'res/drawable/logo_manwu.png',
            width: 23,
            height: 23,
            color: Colors.grey[500],
          ),
          SizedBox(
            width: 4.0,
          ),
          Text(
            S.of(context).safety_certification_by_organizations,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12.0,
            ),
          ),
          Spacer()
        ],
      ),
    );
  }

  _divider() {
    return Container(
      height: 8,
      color: HexColor('#FFF5F5F5'),
    );
  }
}

///
class MarketItemEntity {
  String symbol;
  String symbolName;
  KLineEntity kLineEntity;

  MarketItemEntity(
    this.symbol,
    this.kLineEntity, {
    this.symbolName,
  });
}
