import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_confirm_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class Map3CollectableListPage extends StatefulWidget {
  Map3CollectableListPage();

  @override
  State<StatefulWidget> createState() {
    return Map3CollectableListPageState();
  }
}

class Map3CollectableListPageState extends State<Map3CollectableListPage> {
  AtlasApi _atlasApi = AtlasApi();
  final _client = WalletUtil.getWeb3Client(true);

  List<Map3InfoEntity> _joinNodeList = List();
  List<Map3InfoEntity> _createdNodeList = List();

  LoadDataBloc _loadDataBloc = LoadDataBloc();

  var _walletName = '';
  String _address = '';

  Map<String, dynamic> _rewardMap = {};
  Decimal _totalAmount = Decimal.fromInt(0);

  int _currentPage = 1;
  int _pageSize = 30;

  @override
  void initState() {
    super.initState();
    var activatedWallet =
        WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getAtlasAccount()?.address ?? "";
    _walletName = activatedWallet?.wallet?.keystore?.name ?? "";
    _getData();
    _loadDataBloc.add(LoadingEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _loadDataBloc.close();
  }

  _getData() {
    _getCreatedNodeList();
    _getRewardMap();
  }

  _getCreatedNodeList() async {
    ///not use pagination, use 9999 as size to request list
    ///
    try {
      var _list = await _atlasApi.getMap3NodeListByMyCreate(
        _address,
        page: 1,
        size: 9999,
        status: [
          Map3InfoStatus.CONTRACT_HAS_STARTED.index,
        ],
      );

      if (_list != null && _list.isNotEmpty) {
        _createdNodeList.clear();
        _createdNodeList.addAll(_list);
      }
    } catch (e) {}
    if (mounted) setState(() {});
  }

  _getRewardMap() async {
    _rewardMap = await _client.getAllMap3RewardByDelegatorAddress(
      EthereumAddress.fromHex(_address),
    );
    setState(() {});
    print('------rewardMap: $_rewardMap');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            LoadDataContainer(
                bloc: _loadDataBloc,
                onLoadData: () async {
                  await _refreshData();
                },
                onRefresh: () async {
                  _getData();
                  await _refreshData();
                },
                onLoadingMore: () {
                  _loadMoreData();
                  setState(() {});
                },
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          16.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '我创建的',
                              style: TextStyle(
                                color: DefaultColors.color999,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _myCreateNodeList(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          16.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '我参与的',
                              style: TextStyle(
                                color: DefaultColors.color999,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _myJoinNodeList(),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 50,
                      ),
                    )
                  ],
                )),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 50,
                child: ClickOvalButton(
                  '全部提取',
                  _collect,
                  radius: 0,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _emptyListHint() {
    return SliverToBoxAdapter(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'res/drawable/ic_empty_contract.png',
                width: 100,
                height: 100,
              ),
            ),
            Text(
              S.of(context).exchange_empty_list,
              style: TextStyle(
                fontSize: 13,
                color: DefaultColors.color999,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _myCreateNodeList() {
    if (_createdNodeList.isNotEmpty) {
      return SliverList(
          delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            height: 60,
            child: _nodeCollectItem(_createdNodeList[index]),
          );
        },
        childCount: _createdNodeList.length,
      ));
    } else {
      return _emptyListHint();
    }
  }

  _myJoinNodeList() {
    if (_joinNodeList.isNotEmpty) {
      return SliverList(
          delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            height: 60,
            child: _nodeCollectItem(_joinNodeList[index]),
          );
        },
        childCount: _joinNodeList.length,
      ));
    } else {
      return _emptyListHint();
    }
  }

  _collect() async {
    ///refresh reward map
    await _getRewardMap();

    var count = _rewardMap?.values?.length ?? 0;
    if (count == 0) {
      Fluttertoast.showToast(msg: S.of(context).current_reward_zero);
      return;
    }

    try {
      if (_rewardMap.isNotEmpty) {
        ///clear amount first;
        _totalAmount = Decimal.fromInt(0);

        _rewardMap.forEach((key, value) {
          var bigIntValue = BigInt.tryParse(value) ?? BigInt.from(0);
          Decimal valueByDecimal = ConvertTokenUnit.weiToEther(
            weiBigInt: bigIntValue,
          );
          _totalAmount = _totalAmount + valueByDecimal;
        });
      } else {
        var lastTxIsPending = await AtlasApi.checkLastTxIsPending(
            MessageType.typeCollectMicroStakingRewards);
        if (lastTxIsPending) {
          Fluttertoast.showToast(msg: '请先等待上一笔交易处理完成');
          return;
        }
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: '未知错误，请稍后重试！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    var preText =
        "${S.of(context).you_create_or_join_node('${_rewardMap?.values?.length ?? 0}')}，";

    UiUtil.showAlertView(
      context,
      title: S.of(context).collect_reward,
      actions: [
        ClickOvalButton(
          S.of(context).confirm_collect,
          () {
            Navigator.pop(context);

            var entity = PledgeMap3Entity();
            var message = ConfirmCollectMap3NodeMessage(
              entity: entity,
              amount: _totalAmount.toString(),
              addressList:
                  _rewardMap?.keys?.map((e) => e.toString())?.toList() ?? [],
            );
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Map3NodeConfirmPage(
                    message: message,
                  ),
                ));
          },
          width: 200,
          height: 38,
          fontSize: 16,
        ),
      ],
      content: S.of(context).confirm_collect_reward_to_wallet(
            '',
            "${FormatUtil.stringFormatCoinNum(_totalAmount.toString())}",
          ),
      boldContent: "($_walletName)",
      boldStyle: TextStyle(
        color: HexColor("#999999"),
        fontSize: 12,
        height: 1.8,
      ),
      suffixContent: " ？",
    );
  }

  _refreshData() async {
    _currentPage = 1;
    try {
      var _list = await _atlasApi.getMap3NodeListByMyJoin(_address,
          page: _currentPage,
          size: _pageSize,
          status: [
            Map3InfoStatus.CONTRACT_HAS_STARTED.index,
          ]);

      if (_list != null) {
        _joinNodeList.clear();
        _joinNodeList.addAll(_list);
      }
      _loadDataBloc.add(RefreshSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(RefreshFailEvent());
    }
    if (mounted) setState(() {});
  }

  _loadMoreData() async {
    try {
      var _list = await _atlasApi.getMap3NodeListByMyJoin(_address,
          page: _currentPage + 1,
          size: _pageSize,
          status: [
            Map3InfoStatus.CONTRACT_HAS_STARTED.index,
          ]);

      if (_list != null && _list.isNotEmpty) {
        _joinNodeList.addAll(_list);
        _currentPage++;
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
    if (mounted) setState(() {});
  }

  _nodeCollectItem(Map3InfoEntity map3infoEntity) {
    if (map3infoEntity == null) return Container();
    var nodeName = map3infoEntity?.name ?? "";
    var nodeAddress = '${UiUtil.shortEthAddress(
      WalletUtil.ethAddressToBech32Address(map3infoEntity?.address ?? ""),
      limitLength: 8,
    )}';
    var valueInRewardMap =
        _rewardMap?.containsKey(map3infoEntity.address?.toLowerCase()) ?? false
            ? _rewardMap[map3infoEntity.address?.toLowerCase()]
            : '0';
    var bigIntValue = BigInt.tryParse(valueInRewardMap) ?? BigInt.from(0);
    var _collectable = ConvertTokenUnit.weiToEther(
      weiBigInt: bigIntValue,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          iconMap3Widget(map3infoEntity),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: nodeName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      )),
                  TextSpan(text: "", style: TextStyles.textC333S14bold),
                ])),
                Container(
                  height: 4,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      '${S.of(context).node_addrees}: ${nodeAddress}',
                      style: TextStyle(
                          color: DefaultColors.color999, fontSize: 11),
                    )
                  ],
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  '${FormatUtil.stringFormatCoinNum(_collectable.toString())}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                height: 4,
              ),
              Text(
                '可提奖励',
                style: TextStyle(
                  color: DefaultColors.color999,
                  fontSize: 12,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
