import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:titan/env.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/signer.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/market/api/exchange_const.dart';
import 'package:titan/src/pages/market/entity/market_info_entity.dart';
import 'package:titan/src/pages/market/model/asset_history.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/pages/market/order/entity/order_detail.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:cookie_jar/cookie_jar.dart';

class ExchangeHttp extends BaseHttpCore {
  factory ExchangeHttp() => _getInstance();

  ExchangeHttp._internal()
      : super(
          Dio(
            BaseOptions(
              baseUrl: Const.EXCHANGE_DOMAIN,
              contentType: 'application/x-www-form-urlencoded',
            ),
          )..interceptors.add(CookieManager(CookieJar())), //cookie 存在内存而已
        );

  static ExchangeHttp _instance;

  static ExchangeHttp get instance => _getInstance();

  static ExchangeHttp _getInstance() {
    if (_instance == null) {
      _instance = ExchangeHttp._internal();
      if (env.buildType == BuildType.DEV) {
        _instance.dio.interceptors
            .add(LogInterceptor(responseBody: true, requestBody: true));
      }
    }
    return _instance;
  }
}

class ExchangeApi {
  Future<String> ping(String name) async {
    return await ExchangeHttp.instance.postEntity(
      'api/index/ping',
      EntityFactory((json) => json),
      params: {'name': name},
    );
  }

  ///使用[address]钱包地址 和 访问路径[path]获取一个种子
  Future<String> _getAccessSeed(String address, String path) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_GET_ACCESS_SEED,
      null,
      params: {
        'address': address,
        'path': path,
      },
    );
  }

  Future<dynamic> sendSms({String email, String language = 'zh-CN'}) async {
    return await ExchangeHttp.instance.postEntity(
      '/api/user/mregister',
      null,
      params: {
        'email': email,
        'type': 1,
        'language': language,
      },
    );
  }

  ///使用钱包注册/登录
  Future<dynamic> walletSignLogin({
    Wallet wallet,
    String password,
    String address,
  }) async {
    //get a seed
    var seed = await _getAccessSeed(
      address,
      ExchangeConst.PATH_LOGIN_REGISTER,
    );
    var params = {
      'address': address,
      'seed': seed,
    };
    //sign request with seed
    var signed = await Signer.signApi(
      wallet,
      password,
      'POST',
      Const.EXCHANGE_DOMAIN.split('//')[1],
      ExchangeConst.PATH_LOGIN_REGISTER,
      params,
    );
    params['sign'] = signed;

    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_LOGIN_REGISTER,
      null,
      params: params,
    );
  }

  Future<dynamic> getAssetsList() async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_ACCOUNT_ASSETS,
      null,
      params: {},
    );
  }

  Future<dynamic> type2currency(String _type, String _currency) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_TYPE_TO_CURRENCY,
      null,
      params: {
        'type': _type,
        'currency': _currency,
      },
    );
  }

  Future<dynamic> testRecharge(String type, double balance) async {
    return await ExchangeHttp.instance
        .postEntity(ExchangeConst.PATH_QUICK_RECHARGE, null, params: {
      "type": type,
      "balance": balance,
    });
  }

  Future<ResponseEntity> withdraw(
    String type,
    String outerAddress,
    String balance,
  ) async {
    return await ExchangeHttp.instance.postResponseEntity(
      ExchangeConst.PATH_WITHDRAW,
      null,
      params: {
        'type': type,
        'outer_address': outerAddress,
        'balance': balance,
      },
    );
  }

  Future<ResponseEntity> getAddress(
    String type,
  ) async {
    return await ExchangeHttp.instance.postResponseEntity(
      ExchangeConst.PATH_GET_ADDRESS,
      null,
      params: {
        'type': type,
      },
    );
  }

  Future<ResponseEntity> transferAccountToExchange(
    String type,
    String balance,
  ) async {
    return await ExchangeHttp.instance.postResponseEntity(
      ExchangeConst.PATH_TO_EXCHANGE,
      null,
      params: {
        "type": type,
        "balance": balance,
      },
    );
  }

  Future<ResponseEntity> transferExchangeToAccount(
    String type,
    String balance,
  ) async {
    return await ExchangeHttp.instance.postResponseEntity(
      ExchangeConst.PATH_TO_ACCOUNT,
      null,
      params: {
        "type": type,
        "balance": balance,
      },
    );
  }

  Future<MarketInfoEntity> getMarketInfo(String market) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_MARKET_INFO,
      EntityFactory<MarketInfoEntity>(
          (marketInfo) => MarketInfoEntity.fromJson(marketInfo)),
      params: {
        "market": market,
      },
    );
  }

  Future<dynamic> getMarketAllSymbol() async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_MARKET_ALL,
      null,
      params: {},
    );
  }

  Future<dynamic> orderPutLimit(
      String market, exchangeType, String price, String amount) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_ORDER_LIMIT,
      null,
      params: {
        "market": market,
        "side": exchangeType,
        "price": price,
        "amount": amount,
        "option": "GTC",
      },
    );
  }

  Future<dynamic> orderPutMarket(
      String market, exchangeType, String amount) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_ORDER_MARKET,
      null,
      params: {
        "market": market,
        "side": exchangeType,
        "amount": amount,
      },
    );
  }

  Future<dynamic> orderCancel(String orderId) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_ORDER_CANCEL,
      null,
      params: {"order_id": orderId},
    );
  }

  Future<dynamic> historyTrade(String symbol, {String limit = '100'}) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_HISTORY_TRADE,
      null,
      params: {
        "symbol": symbol,
        "limit": limit,
      },
    );
  }

  Future<dynamic> historyDepth(String symbol, {int precision = -1}) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_HISTORY_DEPTH,
      null,
      params: {
        "symbol": symbol,
        "precision": precision,
      },
    );
  }

  Future<List<Order>> getOrderList(
    String market,
    int page,
    int size,
    String method,
  ) async {
    return await ExchangeHttp.instance.postEntity(ExchangeConst.PATH_ORDER_LIST,
        EntityFactory<List<Order>>((response) {
      var orderList = List<Order>();
      if (response is Map && response.length == 0) {
        return orderList;
      }
      var dataList = response['data'];
      (dataList as List).forEach((item) {
        orderList.add(Order.fromJson(item));
      });
      return orderList;
    }), params: {
      'market': market,
      'page': page,
      'size': size,
      'method': method,
    });
  }

  Future<List<AssetHistory>> getAccountHistory(
    String type,
    int page,
    int size,
    String action,
  ) async {
    return await ExchangeHttp.instance
        .postEntity(ExchangeConst.PATH_ASSETS_HISTORY,
            EntityFactory<List<AssetHistory>>((response) {
      var assetHistoryList = List<AssetHistory>();
      if (response is Map && response.length == 0) {
        return assetHistoryList;
      }
      var dataList = response['data'];
      (dataList as List).forEach((item) {
        assetHistoryList.add(AssetHistory.fromJson(item));
      });
      return assetHistoryList;
    }), params: {
      'type': type,
      'page': page,
      'size': size,
      'action': action,
    });
  }

  Future<List<OrderDetail>> getOrderDetailList(
    String market,
    int page,
    int size,
  ) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_ORDER_LOG_LIST,
      EntityFactory<List<OrderDetail>>((response) {
        var orderDetailList = List<OrderDetail>();
        if (response is Map && response.length == 0) {
          return orderDetailList;
        }
        var dataList = response['data'];
        (dataList as List).forEach((item) {
          orderDetailList.add(OrderDetail.fromJson(item));
        });
        return orderDetailList;
      }),
      params: {
        'market': market,
        'page': page,
        'size': size,
      },
    );
  }

  Future<dynamic> historyKline(String symbol, {String period = '15min'}) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_HISTORY_KLINE,
      null,
      params: {
        "name": symbol,
        "period": period,
      },
    );
  }
}