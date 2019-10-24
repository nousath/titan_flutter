import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:titan/src/business/me/contract/contract_bloc/bloc.dart';
import 'package:titan/src/business/me/contract/order_contract/order_contract_state.dart';
import 'package:titan/src/business/me/purchase_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/progress_dialog_mask/bloc/bloc.dart';

import '../model/contract_info_v2.dart';
import '../my_hash_rate_page.dart';
import 'contract_bloc/contract_state.dart';
import 'order_contract/bloc.dart';

class BuyHashRatePageV2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BuyHashRateStateV2();
  }
}

class _BuyHashRateStateV2 extends State<BuyHashRatePageV2> {
  UserService _userService = UserService();

  List<ContractInfoV2> contractList = [ContractInfoV2(0, "", "", "", 0, 0, 0, 0, 0, 0, 0)];

  ContractInfoV2 _selectedContractInfo = ContractInfoV2(0, "", "", "", 0, 0, 0, 0, 0, 0, 0);

  NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.#####");

  ContractBloc _contractBloc;

  OrderContractBloc _orderContractBloc;

  ProgressMaskDialogBloc _progressMaskDialogBloc;

  @override
  void initState() {
    super.initState();
    _contractBloc = ContractBloc(_userService);
    _orderContractBloc = OrderContractBloc(_userService, _contractBloc);
    _contractBloc.add(LoadContracts());
  }

  @override
  Widget build(BuildContext context) {
    print("lallal,build");
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          title: Text(
            "购买算力合约",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<ContractBloc, ContractState>(
            bloc: _contractBloc,
            builder: (BuildContext context, ContractState contractState) {
              print("lalala, first builder");

              if (contractState is LoadedState) {
                contractList = contractState.contrctInfoList;
                _selectedContractInfo = contractList[0];
              } else if (contractState is ContractSwitchedState) {
                _selectedContractInfo = contractList[contractState.index];
              }
              return BlocBuilder<OrderContractBloc, OrderContractState>(
                bloc: _orderContractBloc,
                builder: (context, orderContractState) {
                  if (orderContractState is! OrderingState) {
                    _progressMaskDialogBloc?.add(CloseDialogEvent());
                    _progressMaskDialogBloc = null;
                  }

                  if (orderContractState is OrderSuccessState) {
                    print(" lalala OrderSuccessState lalalal");

                    _orderContractBloc.add(ResetToInit());
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PurchasePage(
                                    contractInfo: _selectedContractInfo,
                                    payOrder: orderContractState.payOrder,
                                  )));
                      return;
                    });
                  } else if (orderContractState is OrderFreeSuccessState) {
                    _orderContractBloc.add(ResetToInit());
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHashRatePage()));
                      return;
                    });
                  } else if (orderContractState is OrderOverRangeState) {
                    Fluttertoast.showToast(msg: "超过购买限制数量");
                  } else if (orderContractState is OrderFailState) {
                    Fluttertoast.showToast(msg: "购买失败");
                  }

                  return Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: Container(),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Container(
                              child: CarouselSlider(
                                onPageChanged: _onPageChanged,
                                height: 250.0,
                                enlargeCenterPage: true,
                                items: contractList.map((_contractInfoTemp) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                              color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  FadeInImage.assetNetwork(
                                                    image: _contractInfoTemp.icon,
                                                    placeholder: 'res/drawable/img_placeholder.jpg',
//                                          width: 170,
                                                    height: 130,
                                                    fit: BoxFit.cover,
                                                  )
                                                ],
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.max,
                                              ),
                                              Spacer(),
                                              Row(
                                                children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      Text(
                                                        _contractInfoTemp.name,
                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            DOUBLE_NUMBER_FORMAT.format(_contractInfoTemp.amount),
                                                            style: TextStyle(
                                                                color: Color(0xFFf6927f),
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                          Text("  USDT")
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  Column(
                                                    children: <Widget>[
                                                      Text(
                                                        "${_contractInfoTemp.timeCycle}天产出(USDT)",
                                                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            DOUBLE_NUMBER_FORMAT.format(
                                                                _contractInfoTemp.monthInc + _contractInfoTemp.amount),
                                                            style: TextStyle(
                                                                color: Color(0xFFf6927f),
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.normal),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ));
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Container(
                              margin: EdgeInsets.only(left: 32, right: 32, bottom: 16, top: 16),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "合约介绍",
                                        style:
                                            TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Text(
                                        "每人限购${_selectedContractInfo.limit}份",
                                        style: TextStyle(color: Colors.grey, fontSize: 14),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        _selectedContractInfo.description,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  RaisedButton(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    color: Theme.of(context).primaryColor,
                                    onPressed: orderContractState is OrderingState ? null : _orderSubmit,
                                    child: Container(
                                      constraints: BoxConstraints.expand(height: 48),
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              orderContractState is OrderingState
                                                  ? "提交中"
                                                  : (_selectedContractInfo.amount != 0 ? "购买" : "免费领取"),
                                              style: TextStyle(
                                                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  );
                },
              );
            }));
  }

  Future _onPageChanged(int index) {
    _contractBloc.add(SwtichContract(index));
  }

  Function _orderSubmit() {
    _progressMaskDialogBloc = UtilUi.showMaskDialog(context);
    if (_selectedContractInfo.amount > 0) {
      _orderContractBloc.add(OrderContract(_selectedContractInfo.id));
    } else {
      _orderContractBloc.add(OrderFreeContract(_selectedContractInfo.id));
    }
  }
}