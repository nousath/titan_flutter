import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/model/heaven_map_poi_info.dart';
import 'package:titan/src/widget/draggable_bottom_sheet.dart';

class NightLifePanel extends StatefulWidget {
  final HeavenMapPoiInfo poi;
  final ScrollController scrollController;

  NightLifePanel({this.poi, this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return NightLifePanelState();
  }
}

class NightLifePanelState extends State<NightLifePanel> {

  @override
  void initState() {
    super.initState();

    //动态设置sheet 收起高度
    SchedulerBinding.instance.addPostFrameCallback((_) {
      HeaderHeightNotification(height: 180).dispatch(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              widget.poi.name,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  IconData(0xe601, fontFamily: 'iconfont'),
                  color: Colors.purple[300],
                  size: 20,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      widget.poi.service?.replaceAll('141', 'night-life') ?? '私密服务',
                      style: TextStyle(color: Colors.purple, fontSize: 15),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.phone,
                  color: Colors.green,
                  size: 20,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        (widget.poi.phone != null && widget.poi.phone.isNotEmpty) ? widget.poi.phone?.replaceAll('141', 'night-life') : '暂无填写',
                        style: TextStyle(fontSize: 15)),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.location_on,
                  color: Colors.grey[600],
                  size: 20,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      (widget.poi.address != null && widget.poi.address.isNotEmpty) ? widget.poi.address : '暂无填写',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Divider(
              height: 16,
            ),
          ),
          buildInfoItem('服务时间', widget.poi.time, hint: '暂无填写'),
          buildInfoItem('区域', widget.poi.area, hint: '暂无填写'),
          buildInfoItem('描述', widget.poi.desc, hint: '暂无填写'),
          SizedBox(
            height: 56,
          ),
        ],
      ),
    );
  }

  Widget buildInfoItem(String tag, String info, {String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
          child: Text(
            tag,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
          child: Text((info != null && info.isNotEmpty) ? info : hint, style: TextStyle(fontSize: 15)),
        ),
      ],
    );
  }

}