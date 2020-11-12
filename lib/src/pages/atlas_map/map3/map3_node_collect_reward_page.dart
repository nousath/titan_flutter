import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/widget/atlas_collectable_list_page.dart';
import 'package:titan/src/pages/atlas_map/widget/map3_collectable_list_page.dart';
import 'package:titan/src/routes/routes.dart';

class Map3NodeCollectRewardPage extends StatefulWidget {
  Map3NodeCollectRewardPage();

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeCollectRewardPageState();
  }
}

class _Map3NodeCollectRewardPageState extends State<Map3NodeCollectRewardPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, vsync: this, length: 2);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Scaffold(
          appBar: BaseAppBar(
            baseTitle: '我的奖励',
            actions: [
              FlatButton(
                onPressed: () {
                  Application.router.navigateTo(
                    context,
                    Routes.map3node_my_page_reward,
                  );
                },
                child: Text(
                  '提取记录',
                  style: TextStyle(
                    color: HexColor("#1F81FF"),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: TabBar(
                        isScrollable: true,
                        indicatorColor: HexColor("#228BA1"),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 2,
                        controller: _tabController,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: HexColor("#333333"),
                        tabs: [
                          Tab(
                            child: Text(
                              'Map3奖励',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Tab(
                            child: Text(
                              'Atlas奖励',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Map3CollectableListPage(),
                    AtlasCollectableLisPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
