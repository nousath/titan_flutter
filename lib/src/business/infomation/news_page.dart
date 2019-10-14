import 'package:flutter/material.dart';
import 'package:titan/src/business/infomation/api/news_api.dart';
import 'package:titan/src/business/infomation/info_state.dart';
import 'package:titan/src/widget/smart_pull_refresh.dart';

class NewsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewsState();
  }
}

class _NewsState extends InfoState<NewsPage> {
  final String CATEGORY = "1";
  final int FIRST_PAGE = 1;
  List<InfoItemVo> _InfoItemVoList = [];
  int selectedTag = 26;
  NewsApi _newsApi = NewsApi();
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    _getPowerList(CATEGORY, selectedTag.toString(), FIRST_PAGE);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 48,
              child: Row(
                children: <Widget>[
                  _buildTag("最新资讯", 26),
                  _buildTag("官方公告", 22),
                  _buildTag("教程", 30),
                ],
              ),
            ),
          ),
          Expanded(
            child: SmartPullRefresh(
              onRefresh: () {
                _getPowerList(CATEGORY, selectedTag.toString(), FIRST_PAGE);
              },
              onLoading: () {
                _getPowerList(CATEGORY, selectedTag.toString(), currentPage + 1);
              },
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    return buildInfoItem(_InfoItemVoList[index]);
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: _InfoItemVoList.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, int value) {
    Color textColor = value == selectedTag ? Theme.of(context).primaryColor : Color(0xFF252525);

    Color borderColor = value == selectedTag ? Theme.of(context).primaryColor : Color(0xFFB7B7B7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () async {
          if (selectedTag == value) {
            return;
          }
          selectedTag = value;
          currentPage = 1;
          _getPowerList(CATEGORY, selectedTag.toString(), currentPage);
          setState(() {});
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            text,
            style: TextStyle(fontSize: 15, color: textColor),
          ),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: borderColor)),
        ),
      ),
    );
  }

  Future _getPowerList(String categories, String tags, int page) async {
    var newsResponseList = await _newsApi.getNewsList(categories, tags, page);

    var newsVoList = newsResponseList.map((newsResponse) {
      return InfoItemVo(
          id: newsResponse.id,
          url: newsResponse.outlink,
          photoUrl: newsResponse.customCover,
          title: newsResponse.title,
          publisher: "",
          publishTime: newsResponse.date * 1000);
    }).toList();
    if (page == FIRST_PAGE) {
      _InfoItemVoList.clear();
      _InfoItemVoList.addAll(newsVoList);
    } else {
      if (newsVoList.length == 0) {
        return;
      }
      _InfoItemVoList.addAll(newsVoList);
    }
    currentPage = page;
    if (mounted) {
      setState(() {});
    }
  }
}
