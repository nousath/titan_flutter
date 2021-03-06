import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/map3page/my_map3_contracts_page_v8.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';

class NodeActiveContractWidgetV8 extends StatefulWidget {
  final LoadDataBloc loadDataBloc;

  NodeActiveContractWidgetV8(this.loadDataBloc);

  @override
  State<StatefulWidget> createState() {
    return _NodeActiveContractStateV8();
  }
}

class _NodeActiveContractStateV8 extends State<NodeActiveContractWidgetV8> {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  int _currentPage = 0;
  NodeApi _nodeApi = NodeApi();
  List<ContractNodeItem> contractList = [];

  @override
  void initState() {
    super.initState();

    if (widget.loadDataBloc != null) {
      widget.loadDataBloc.listen((state) {
        if (state is RefreshSuccessState) {
          getContractActiveList();
        }
      });
    } else {
      getContractActiveList();
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
    return activeContractWidget();
  }

  void getContractActiveList() async {
    _currentPage = 0;
    List<ContractNodeItem> tempMemberList = await _nodeApi.getContractActiveList(page: _currentPage);

    //print("[widget] --> build, length:${tempMemberList.length}");
    if (mounted) {
      setState(() {
        if (tempMemberList.length > 0) {
          contractList = [];
        }
        contractList.addAll(tempMemberList);
      });
    }
  }

  Widget activeContractWidget() {
    return Container(
      color: Colors.white,
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyMap3ContractPage(MyContractModelV8(S.of(context).latest_boot_node, MyContractTypeV8.active))));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                          S.of(context).latest_boot_node,
                      style: TextStyle(fontWeight: FontWeight.w500, color: HexColor("#000000")),
                    )),
                    Text(
                      S.of(context).see_more,
                      style: TextStyles.textC999S14,
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.black54,
                    ),
                    SizedBox(
                      width: 14,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  var i = index;
                  var delegatorItem = contractList[i];
                  return _item(delegatorItem);
                },
                itemCount: contractList.length > 3 ? 3 : contractList.length,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(ContractNodeItem item) {
    var width = (MediaQuery.of(context).size.width - 3.0 * 8) / 3.0;
    return InkWell(
      onTap: () {
        Application.router.navigateTo(context, Routes.map3node_contract_detail_page_v8 + "?contractId=${item.id}");
      },
      child: Padding(
        padding: EdgeInsets.only(top: 4, bottom: 4.0),
        child: SizedBox(
          width: width,
//          height: 160,
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
                      Image.asset(
                        "res/drawable/ic_map3_node_item_contract.png",
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5),
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                              text: S.of(context).number, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          TextSpan(text: "${item.contractCode ?? ""}", style: TextStyles.textC333S14bold),
                        ])),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(UiUtil.shortEthAddress(item.ownerName),
                          style: TextStyles.textC9b9b9bS12),
//                      Text(item.ownerName,
//                          style: TextStyle(fontSize: 14, color: HexColor("#9B9B9B")))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
