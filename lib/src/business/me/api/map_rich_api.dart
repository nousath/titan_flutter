import 'dart:core';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/business/me/api/map_rich_http.dart';
import 'package:titan/src/business/me/model/bill_info.dart';
import 'package:titan/src/business/me/model/contract_info.dart';
import 'package:titan/src/business/me/model/contract_info_v2.dart';
import 'package:titan/src/business/me/model/fund_token.dart';
import 'package:titan/src/business/me/model/mortgage_info.dart';
import 'package:titan/src/business/me/model/mortgage_info_v2.dart';
import 'package:titan/src/business/me/model/node_mortgage_info.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/model/pay_order.dart';
import 'package:titan/src/business/me/model/power_detail.dart';
import 'package:titan/src/business/me/model/promotion_info.dart';
import 'package:titan/src/business/me/model/recharge_order_info.dart';
import 'package:titan/src/business/me/model/quotes.dart';
import 'package:titan/src/business/me/model/user_eth_address.dart';
import 'package:titan/src/business/me/model/user_info.dart';
import 'package:titan/src/business/me/model/user_level_info.dart';
import 'package:titan/src/business/me/model/user_token.dart';
import 'package:titan/src/business/me/model/withdrawal_info.dart';
import 'package:titan/src/business/me/model/withdrawal_info_log.dart';
import 'package:titan/src/domain/gaode_model.dart';
import 'package:titan/src/model/gaode_poi.dart';
import 'package:titan/src/business/me/model/checkin_history.dart';

class MapRichApi {
  ///
  /// 登录接口
  Future<UserToken> login(String email, String password) async {
    return await MapRichHttpCore.instance.postEntity(
        "login", EntityFactory<UserToken>((json) => UserToken.fromJson(json)),
        params: {"email": email, "password": password});
  }

  ///
  /// 发送验证码
  Future<int> verificationCode(String email) async {
    return await MapRichHttpCore.instance
        .postEntity("verification", EntityFactory((json) => json), params: {"email": email});
  }

  ///注册
  Future<String> signUp(
      String email, String password, int verificationCode, String invitationCode, String fundPassword) async {
    return await MapRichHttpCore.instance.postEntity("sign_up", EntityFactory((json) => json), params: {
      "email": email,
      "password": password,
      "verification_code": verificationCode,
      "invitation_code": invitationCode,
      "fund_password": fundPassword,
    });
  }

  ///重置密码
  Future resetPassword(String email, String password, int verificationCode) async {
    await MapRichHttpCore.instance.patchEntity("users/attr/password", EntityFactory((json) => json),
        params: {"email": email, "verification_code": verificationCode, "new_password": password});
  }

  ///重置密码
  Future resetFundPassword(String email, String loginPassword, String fundPassword, int verificationCode) async {
    await MapRichHttpCore.instance.patchEntity("users/attr/fund_password", EntityFactory((json) => json), params: {
      "email": email,
      "verification_code": verificationCode,
      "login_password": loginPassword,
      "new_password": fundPassword
    });
  }

  ///checkin
  Future checkIn(String token, String userId) async {
    await MapRichHttpCore.instance.postEntity("sign_in/$userId", EntityFactory((json) => json),
        options: RequestOptions(headers: {"Authorization": token}));
  }

  ///获取checkincount
  Future<int> checkInCount(String token, String userId) async {
    return await MapRichHttpCore.instance.getEntity("sign_in/$userId/stats", EntityFactory((json) => json as int),
        options: RequestOptions(headers: {"Authorization": token}));
  }

  ///获取checkinhistory
  Future<PageResponse<CheckinHistory>> getHistoryList(String token, String userId, int page) async {
    return await MapRichHttpCore.instance.getEntity("sign_in/$userId/stats/history", EntityFactory<PageResponse<CheckinHistory>>((json) {
      var currentPage = json["page"] as int;
      var totalPages = json["totalPages"] as int;
      var dataList = json["history"] as List;
      var historyList = dataList.map((itemMap) {
        return CheckinHistory.fromJson(itemMap);
      }).toList();
      return PageResponse<CheckinHistory>(currentPage, totalPages, historyList);}), params: {"page": page}, options: RequestOptions(headers: {"Authorization": token}));
  }

  ///获取用户Eth address
  Future<UserEthAddress> getUserEthAddress(String token, String userId) async {
    return await MapRichHttpCore.instance.getEntity(
        "users/$userId/addr", EntityFactory((json) => UserEthAddress.fromJson(json)),
        options: RequestOptions(headers: {"Authorization": token}));
  }

  ///getFundToken
  Future<FundToken> getFundToken(String token, String userId, String password) async {
    return await MapRichHttpCore.instance.postEntity(
        "users/$userId/fund_token", EntityFactory((json) => FundToken.fromJson(json)),
        params: {"password": password}, options: RequestOptions(headers: {"Authorization": token}));
  }

  // todo: jison edit_userInfo
  ///getUserInfo
  Future<UserInfo> getUserInfo(String token, String userId) async {
    return await MapRichHttpCore.instance.getEntity(
        "v2/users/$userId", EntityFactory<UserInfo>((json) => UserInfo.fromJson(json)),
        options: RequestOptions(headers: {"Authorization": token}));
  }

  /*
  Future<UserInfo> getUserInfo(String token, String userId) async {
    return await MapRichHttpCore.instance.getEntity(
        "users/$userId", EntityFactory<UserInfo>((json) => UserInfo.fromJson(json)),
        options: RequestOptions(headers: {"Authorization": token}));
  }
  */

  ///获取算力列表
  Future<PageResponse<PowerDetail>> getPowerList(String token, String userId, int page) async {
    return MapRichHttpCore.instance.getEntity("powers/${userId}", EntityFactory<PageResponse<PowerDetail>>((json) {
      var currentPage = json["page"] as int;
      var totalPages = json["total_pages"] as int;
      var dataList = json["data"] as List;
      var powerDetailList = dataList.map((powerItemMap) {
        return PowerDetail.fromJson(powerItemMap);
      }).toList();
      return PageResponse<PowerDetail>(currentPage, totalPages, powerDetailList);
    }), params: {"page": page}, options: RequestOptions(headers: {"Authorization": token}));
  }

  ///获取推广列表
  // todo: jison edit_promotion
  Future<PageResponse<PromotionInfo>> getPrmotionsList(String token, String userId, int page) async {
    return MapRichHttpCore.instance.getEntity("v2/promotions/${userId}",
        EntityFactory<PageResponse<PromotionInfo>>((json) {
      var currentPage = json["page"] as int;
      var totalPages = json["total_pages"] as int;
      var dataList = json["data"] as List;
      var promotionList = dataList.map((promotionItemMap) {
        return PromotionInfo.fromJson(promotionItemMap);
      }).toList();
      return PageResponse<PromotionInfo>(currentPage, totalPages, promotionList);
    }), params: {"page": page}, options: RequestOptions(headers: {"Authorization": token}));
  }

  /*
  Future<PageResponse<PromotionInfo>> getPrmotionsList(String token, String userId, int page) async {
    return MapRichHttpCore.instance.getEntity("promotions/${userId}",
        EntityFactory<PageResponse<PromotionInfo>>((json) {
          var currentPage = json["page"] as int;
          var totalPages = json["total_pages"] as int;
          var dataList = json["data"] as List;
          var promotionList = dataList.map((promotionItemMap) {
            return PromotionInfo.fromJson(promotionItemMap);
          }).toList();
          return PageResponse<PromotionInfo>(currentPage, totalPages, promotionList);
        }), params: {"page": page}, options: RequestOptions(headers: {"Authorization": token}));
  }*/

  ///getContractList
  Future<List<ContractInfo>> getContractList(String token) async {
    return await MapRichHttpCore.instance.getEntity("contracts", EntityFactory<List<ContractInfo>>((json) {
      return (json as List).map((contractJson) {
        return ContractInfo.fromJson(contractJson);
      }).toList();
    }), options: RequestOptions(headers: {"Authorization": token}));
  }

  ///getContractList
  Future<List<ContractInfoV2>> getContractListV2(String token) async {
    return await MapRichHttpCore.instance.getEntity("contractsV2", EntityFactory<List<ContractInfoV2>>((json) {
      return (json as List).map((contractJson) {
        return ContractInfoV2.fromJson(contractJson);
      }).toList();
    }), options: RequestOptions(headers: {"Authorization": token}));
  }

  ///订单创建
  Future<PayOrder> createOrder({@required int contractId, @required String token}) async {
    return await MapRichHttpCore.instance.postEntity(
        'order/create', EntityFactory<PayOrder>((json) => PayOrder.fromJson(json)),
        params: {"contractId": contractId}, options: RequestOptions(headers: {"Authorization": token}));
  }

  ///订单创建
  Future<PayOrder> createFreeOrder({@required int contractId, @required String token}) async {
    return await MapRichHttpCore.instance.postEntity(
        'order/free', EntityFactory<PayOrder>((json) => PayOrder.fromJson(json)),
        params: {"contractId": contractId}, options: RequestOptions(headers: {"Authorization": token}));
  }

  ///充值订单创建
  Future<RechargeOrderInfo> createRechargeOrder({@required double amount, @required String token}) async {
    return await MapRichHttpCore.instance.postEntity(
        'recharge/create', EntityFactory<RechargeOrderInfo>((json) => RechargeOrderInfo.fromJson(json)),
        params: {"amount": amount}, options: RequestOptions(headers: {"Authorization": token}));
  }

  ///确认支付订单
  Future<ResponseEntity<dynamic>> confirmPay(
      {@required int orderId, @required String payType, @required String token, @required String fundToken}) async {
    return await MapRichHttpCore.instance.postResponseEntity('order/pay', null,
        params: {"orderId": orderId, "payType": payType},
        options: RequestOptions(headers: {"Authorization": token, "Fund-Token": fundToken}));
  }

  ///确认支付订单
  Future<ResponseEntity<dynamic>> confirmRecharge({@required int orderId, @required String token}) async {
    return await MapRichHttpCore.instance.postResponseEntity('recharge/pay', null,
        params: {"orderId": orderId}, options: RequestOptions(headers: {"Authorization": token}));
  }

  ///行情
  Future<Quotes> quotes() async {
    return await MapRichHttpCore.instance
        .getEntity('exchange_rate', EntityFactory<Quotes>((json) => Quotes.fromJson(json)));
  }

  ///提币信息
  Future<WithdrawalInfo> withdrawalInfo({@required String token, @required String type}) async {
    return await MapRichHttpCore.instance.getEntity(
        'withdrawal/info', EntityFactory<WithdrawalInfo>((json) => WithdrawalInfo.fromJson(json)),
        params: {"type": type}, options: RequestOptions(headers: {"Authorization": token}));
  }

  ///提币
  Future<dynamic> withdrawalApply(
      {@required double amount,
      @required String address,
      @required String token,
      @required String fundToken,
      @required int type}) async {
    return await MapRichHttpCore.instance.postEntity('withdrawal/apply', null,
        params: {"amount": amount, "address": address, "type": type},
        options: RequestOptions(headers: {"Authorization": token, "Fund-Token": fundToken}));
  }

  ///getMortgageList
  Future<List<MortgageInfo>> getMortgageList(String token) async {
    return await MapRichHttpCore.instance.getEntity("mortgage/list", EntityFactory<List<MortgageInfo>>((json) {
      return (json as List).map((mortgageJson) {
        return MortgageInfo.fromJson(mortgageJson);
      }).toList();
    }), options: RequestOptions(headers: {"Authorization": token}));
  }

  ///getMortgageListV2
  Future<List<MortgageInfoV2>> getMortgageListV2(String token) async {
    return await MapRichHttpCore.instance.getEntity("mortgage/listV2", EntityFactory<List<MortgageInfoV2>>((json) {
      return (json as List).map((mortgageJson) {
        return MortgageInfoV2.fromJson(mortgageJson);
      }).toList();
    }), options: RequestOptions(headers: {"Authorization": token}));
  }

  ///getDailyBillDetail
  Future<List<BillInfo>> getDailyBillDetail(String token, int id, int page) async {
    return await MapRichHttpCore.instance.getEntity("dailyBills/detail", EntityFactory<List<BillInfo>>((json) {
      return (json as List).map((billJson) {
        return BillInfo.fromJson(billJson);
      }).toList();
    }), params: {"id": id, "page": page}, options: RequestOptions(headers: {"Authorization": token}));
  }

  ///getBillList
  // todo: jison edit_userInfo
  Future<List<BillInfo>> getBillList(String token, int page) async {
    return await MapRichHttpCore.instance.getEntity("dailyBills", EntityFactory<List<BillInfo>>((json) {
      return (json as List).map((billJson) {
        return BillInfo.fromJson(billJson);
      }).toList();
    }), params: {"page": page}, options: RequestOptions(headers: {"Authorization": token}));
  }

  /*
  Future<List<BillInfo>> getBillList(String token, int page) async {
    return await MapRichHttpCore.instance.getEntity("bills", EntityFactory<List<BillInfo>>((json) {
      return (json as List).map((billJson) {
        return BillInfo.fromJson(billJson);
      }).toList();
    }), params: {"page": page}, options: RequestOptions(headers: {"Authorization": token}));
  }
  */

  ///获取推广列表
  Future<PageResponse<NodeMortgageInfo>> getNodeMortgageList(String token, int page) async {
    return MapRichHttpCore.instance.getEntity("mortgage/my", EntityFactory<PageResponse<NodeMortgageInfo>>((json) {
      var currentPage = json["page"] as int;
      var totalPages = json["total_pages"] as int;
      var dataList = json["data"] as List;
      var promotionList = dataList.map((promotionItemMap) {
        return NodeMortgageInfo.fromJson(promotionItemMap);
      }).toList();
      return PageResponse<NodeMortgageInfo>(currentPage, totalPages, promotionList);
    }), params: {"page": page}, options: RequestOptions(headers: {"Authorization": token}));
  }

  /// 获取用户等级
  Future<List<UserLevelInfo>> getUserLevelList() async {
    return await MapRichHttpCore.instance.getEntity("levels", EntityFactory<List<UserLevelInfo>>((json) {
      return (json as List).map((levelInfoJson) {
        return UserLevelInfo.fromJson(levelInfoJson);
      }).toList();
    }));
  }

  ///获取提币列表
  Future<PageResponse<WithdrawalInfoLog>> getWithdrawalLogList(String token, int page) async {
    return MapRichHttpCore.instance.getEntity("withdrawal/list", EntityFactory<PageResponse<WithdrawalInfoLog>>((json) {
      var currentPage = json["page"] as int;
      var totalPages = json["total_pages"] as int;
      var dataList = json["data"] as List;
      var withdrawalList = dataList.map((withdrawalItemMap) {
        return WithdrawalInfoLog.fromJson(withdrawalItemMap);
      }).toList();
      return PageResponse<WithdrawalInfoLog>(currentPage, totalPages, withdrawalList);
    }), params: {"page": page}, options: RequestOptions(headers: {"Authorization": token}));
  }

  ///抵押
  Future<dynamic> mortgage({@required int confId, @required token, @required String fundToken}) async {
    return await MapRichHttpCore.instance.postEntity('mortgage/buy', null,
        params: {"confId": confId},
        options: RequestOptions(headers: {"Authorization": token, "Fund-Token": fundToken}));
  }

  ///抵押抢注
  Future<dynamic> mortgageSnapUp({@required int confId, @required String token, @required String fundToken}) async {
    return await MapRichHttpCore.instance.postEntity('mortgage/snap_up', null,
        params: {"confId": confId},
        options: RequestOptions(headers: {"Authorization": token, "Fund-Token": fundToken}));
  }

  ///赎回
  Future<dynamic> redemption({@required int id, @required token, @required String fundToken}) async {
    return await MapRichHttpCore.instance.postEntity('mortgage/redemption', null,
        params: {"id": id}, options: RequestOptions(headers: {"Authorization": token, "Fund-Token": fundToken}));
  }

  ///cookie
  Future<String> getDianpingCookies() async {
    return await MapRichHttpCore.instance.getEntity('cookie', EntityFactory<String>((json) => json));
  }

  ///确认支付订单V2
  Future<ResponseEntity<dynamic>> rechargePayV2({@required token, @required double balance}) async {
    return await MapRichHttpCore.instance.postResponseEntity('recharge/v2/pay', null,
        params: {"balance": balance}, options: RequestOptions(headers: {"Authorization": token}));
  }

  ///附近可以分享的位置
  Future<GaodeModel> searchByGaode({
    @required double lat,
    @required double lon,
    @required String token,
    int type,
    double radius = 100,
    int page = 1,
    CancelToken cancelToken,
  }) async {
    return await MapRichHttpCore.instance.getEntity(
      'map/around',
      EntityFactory<GaodeModel>((json) {
        var data = (json['data'] as List).map((map) {
          return GaodePoi.fromJson(map);
        }).toList();
        var gaodeModel = GaodeModel(page: json['page'], totalPage: json['total_pages'], data: data);
        return gaodeModel;
      }),
      params: {
        "lat": lat,
        "lon": lon,
        "radius": radius,
        "type": type,
        "page": page,
      },
      options: RequestOptions(headers: {"Authorization": token}, cancelToken: cancelToken),
    );
  }
}