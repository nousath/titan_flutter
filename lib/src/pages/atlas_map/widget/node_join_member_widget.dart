import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_user_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:characters/characters.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/wallet_widget.dart';

class NodeJoinMemberWidget extends StatefulWidget {
  final String nodeId;
  final bool isShowInviteItem;
  final LoadDataBloc loadDataBloc;

  NodeJoinMemberWidget({this.nodeId, this.isShowInviteItem = true, this.loadDataBloc});

  @override
  State<StatefulWidget> createState() {
    return _NodeJoinMemberState();
  }
}

class _NodeJoinMemberState extends State<NodeJoinMemberWidget> {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  int _currentPage = 1;
  AtlasApi _atlasApi = AtlasApi();
  List<Map3UserEntity> memberList = [];

  @override
  void initState() {
    super.initState();

    if (widget.loadDataBloc != null) {
      widget.loadDataBloc.listen((state) {
        if (state is RefreshSuccessState) {
          getJoinMemberData();
        }
      });
    } else {
      getJoinMemberData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    loadDataBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _getJoinMemberView();
  }

  void getJoinMemberData() async {
    _currentPage = 1;
    List<Map3UserEntity> tempMemberList = await _atlasApi.getMap3UserList(widget.nodeId, page: _currentPage);

    // print("[widget] --> build, length:${tempMemberList.length}");
    if (mounted) {
      setState(() {
        if (tempMemberList.length > 0) {
          memberList = [];
        }
        memberList.addAll(tempMemberList);
        loadDataBloc.add(RefreshSuccessEvent());
      });
    }
  }

  void getJoinMemberMoreData() async {
    _currentPage++;

    try {
      List<Map3UserEntity> tempMemberList = await _atlasApi.getMap3UserList(
        widget.nodeId,
        page: _currentPage,
        size: 10,
      );

      if (tempMemberList.length > 0) {
        memberList.addAll(tempMemberList);
        loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        loadDataBloc.add(LoadMoreEmptyEvent());
      }
      setState(() {});
    } catch (e) {
      setState(() {
        loadDataBloc.add(LoadMoreFailEvent());
      });
    }
  }

  Widget _getJoinMemberView() {
    return Container(
      height: memberList.isNotEmpty ? 160 : 260,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child:
                          Text(S.of(context).part_member, style: TextStyle(fontSize: 16, color: HexColor("#333333")))),
                  Text(
                    S.of(context).total_member_count(memberList.length.toString()),
                    style: TextStyles.textC999S14,
                  ),
                  SizedBox(
                    width: 14,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 12,
            ),
            memberList.isNotEmpty
                ? Expanded(
                    child: LoadDataContainer(
                        bloc: loadDataBloc,
                        enablePullDown: false,
                        hasFootView: false,
                        onLoadData: getJoinMemberData,
                        onLoadingMore: () {
                          getJoinMemberMoreData();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemBuilder: (context, index) {
                            var i = index;
                            var model = memberList[i];
                            return _itemBuilder(model);
                          },
                          itemCount: memberList.length,
                          scrollDirection: Axis.horizontal,
                        )),
                  )
                : Expanded(child: emptyListWidget(title: "参与地址为空", isAdapter: false)),
          ],
        ),
      ),
    );
  }

  Widget _itemBuilder(Map3UserEntity entity) {
    String showName = entity.name;
    if (showName.isNotEmpty) {
      showName = showName.characters.first;
    }
    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: 4.0),
      child: SizedBox(
        width: 91,
        height: 111,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[200],
                blurRadius: 3.0,
              ),
            ],
          ),
          margin: const EdgeInsets.only(right: 12),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      child: walletHeaderWidget(
                        showName,
                        isShowShape: false,
                        address: entity.address,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0, right: 5),
                      child: Text(entity.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HexColor("#000000"))),
                    ),
                    Text(
                        "${FormatUtil.stringFormatCoinNum(ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(entity.staking)).toString())}",
                        style: TextStyle(fontSize: 10, color: HexColor("#9B9B9B")))
                  ],
                ),
              ),
              if (entity.creator == 1)
                Positioned(
                  top: 15,
                  right: 4,
                  child: Container(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                        color: DefaultColors.colorffdb58,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(S.of(context).sponsor, style: TextStyle(fontSize: 8, color: HexColor("#322300")))),
                )
            ],
          ),
        ),
      ),
    );
  }

  /*
  void _pushTransactionDetailAction(Map3UserEntity item) {
    var url = EtherscanApi.getAddressDetailUrl(
        item.address, SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel.isChinaMainland);
    if (url != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewContainer(
                    initUrl: url,
                    title: "",
                  )));
    }
  }*/

}
