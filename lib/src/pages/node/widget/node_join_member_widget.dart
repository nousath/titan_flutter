import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

class NodeJoinMemberWidget extends StatefulWidget {
  final String contractId;
  final String shareName;
  final String shareUrl;
  final bool isShowInviteItem;
  final LoadDataBloc loadDataBloc;

  NodeJoinMemberWidget(this.contractId, this.shareName, this.shareUrl, {this.isShowInviteItem = true, this.loadDataBloc});

  @override
  State<StatefulWidget> createState() {
    return _NodeJoinMemberState();
  }
}

class _NodeJoinMemberState extends State<NodeJoinMemberWidget> {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  int _currentPage = 0;
  NodeApi _nodeApi = NodeApi();
  List<ContractDelegatorItem> memberList = [];

  @override
  void initState() {
    super.initState();

    if (widget.loadDataBloc != null) {
      widget.loadDataBloc.listen((state){
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
    _currentPage = 0;
    List<ContractDelegatorItem> tempMemberList =
    await _nodeApi.getContractDelegator(int.parse(widget.contractId), page: _currentPage);

    // print("[widget] --> build, length:${tempMemberList.length}");
    if (mounted) {
      setState(() {
        if (tempMemberList.length > 0) {
          memberList = [];
        }
        memberList.addAll(tempMemberList);
      });
    }
  }

  void getJoinMemberMoreData() async {
    try {
      _currentPage++;
      List<ContractDelegatorItem> tempMemberList =
      await _nodeApi.getContractDelegator(int.parse(widget.contractId), page: _currentPage);

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
      height: 160,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Text(S.of(context).part_member, style: TextStyle(fontSize: 16, color: HexColor("#333333")))),
                  /*Text(
                    "剩余时间：${widget.remainDay}天",
                    style: TextStyles.textC999S14,
                  ),*/
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
            Expanded(
              child: LoadDataContainer(
                  bloc: loadDataBloc,
                  enablePullDown: false,
                  hasFootView: false,
                  //onLoadData: getJoinMemberData,
                  onLoadingMore: () {
                    getJoinMemberMoreData();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      var i = index;
                      var delegatorItem = memberList[i];
                      return _item(delegatorItem, i == 0);
                    },
                    itemCount: widget.isShowInviteItem ? memberList.length : memberList.length,
                    scrollDirection: Axis.horizontal,
                  )),
            ),
          ],
        ),
      ),
    );
  }


  Widget _item(ContractDelegatorItem item, bool isFirst) {
    String showName = item.userName;
    if (item.userName.isNotEmpty) {
      showName = item.userName.substring(0, 1);
    }

    return InkWell(
      onTap: () {
        var url = EtherscanApi.getAddressDetailUrl(item.userAddress,
            SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel.isChinaMainland);
        url = FluroConvertUtils.fluroCnParamsEncode(url);
        Application.router.navigateTo(context,
            Routes.toolspage_webview_page + '?initUrl=$url');
      },
      child: Padding(
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
                  blurRadius: 40.0,
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
//                      height: 50,
//                      width: 50,
                        child: circleIconWidget(showName, isShowShape: false, address: item.userAddress)
                        /*Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(13.0)),
                          ),
                          child: Center(
                              child: Text(
                            "$showName",
                            style: TextStyle(fontSize: 15, color: HexColor("#000000")),
                          )),
                        )*/
                        ,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5),
                        child: Text("${item.userName}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HexColor("#000000"))),
                      ),
//                    SizedBox(
//                      height: 4,
//                    ),
                      Text("${FormatUtil.stringFormatNum(item.amountDelegation)}",
                          style: TextStyle(fontSize: 10, color: HexColor("#9B9B9B")))
                    ],
                  ),
                ),
                if (isFirst)
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
      ),
    );
  }
}

/*

Runes
在Dart中，符文是字符串的UTF-32代码点。

Unicode为世界上所有书写系统中使用的每个字母，数字和符号定义唯一的数值。 由于Dart字符串是UTF-16代码单元的序列，因此在字符串中表示32位Unicode值需要特殊语法。

表达Unicode代码点的常用方法是\ uXXXX，其中XXXX是4位十六进制值。 例如，心脏角色（♥）是\ u2665。 要指定多于或少于4个十六进制数字，请将值放在大括号中。 例如，笑的表情符号（?）是\ u {1f600}。

String类有几个属性可用于提取符文信息。 codeUnitAt和codeUnit属性返回16位代码单元。 使用runes属性获取字符串的符文。
————————————————
版权声明：本文为CSDN博主「mafanwei」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/qwe25878/java/article/details/94434117
*/

Widget circleIconWidget(String shortName, {bool isShowShape = true, String address = "#000000"}) {
  String hexColor = address;
  if (address.length>6) {
    hexColor = "#"+address.substring(address.length-6);
  }
  HexColor color = HexColor(hexColor);
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.grey[300],
          blurRadius: 8.0,
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          shortName.toUpperCase(),
          style: TextStyle(fontSize: 15, color: HexColor("#FFFFFF"), fontWeight: FontWeight.w500),
        ),
      ),
    ),
  );
}
