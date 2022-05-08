import 'package:flutter/material.dart';

import 'package:azlistview/azlistview.dart';
import 'package:azlistview_example/common/index.dart';

import 'package:github_language_colors/github_language_colors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class GitHubLanguagePage extends StatefulWidget {
  const GitHubLanguagePage({
    Key? key,
    this.fromType,
  }) : super(key: key);
  final int? fromType;

  @override
  _GitHubLanguagePageState createState() => _GitHubLanguagePageState();
}

class _GitHubLanguagePageState extends State<GitHubLanguagePage> {
  /// Controller to scroll or jump to a particular item.
  final ItemScrollController itemScrollController = ItemScrollController();

  List<Languages> originList = [];
  List<Languages> dataList = [];

  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    loadData();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void loadData() async {
    originList = LanguageHelper.getGithubLanguages().map((v) {
      Languages model = Languages.fromJson(v.toJson());
      String tag = model.name.substring(0, 1).toUpperCase();
      if (RegExp("[A-Z]").hasMatch(tag)) {
        model.tagIndex = tag;
      } else {
        model.tagIndex = "#";
      }
      return model;
    }).toList();
    _handleList(originList);
  }

  void _handleList(List<Languages> list) {
    dataList.clear();
    if (ObjectUtil.isEmpty(list)) {
      setState(() {});
      return;
    }
    dataList.addAll(list);

    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(dataList);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(dataList);

    setState(() {});

    if (itemScrollController.isAttached) {
      itemScrollController.jumpTo(index: 0);
    }
  }

  Widget getSusItem(BuildContext context, String tag, {double susHeight = 40}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '$tag',
        style: TextStyle(
          fontSize: 14,
          // height: 18 / 14,
          color: Color(0xff919499),
        ),
      ),
    );
    // return Container(
    //   height: susHeight,
    //   width: MediaQuery.of(context).size.width,
    //   padding: EdgeInsets.only(left: 16.0),
    //   color: Color(0xFFF3F4F5),
    //   alignment: Alignment.centerLeft,
    //   child: Text(
    //     '$tag',
    //     softWrap: false,
    //     style: TextStyle(
    //       fontSize: 14.0,
    //       color: Color(0xFF666666),
    //     ),
    //   ),
    // );
  }

  Widget getListItem(BuildContext context, Languages model, int index,
      {double susHeight = 0}) {
    String susTag = model.getSuspensionTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Offstage(
          offstage: model.isShowSuspension != true || susTag == "A",
          child: Container(
            height: 1,
            color: Colors.red,
          ),
        ),
        Offstage(
          offstage: model.isShowSuspension != true,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '$susTag',
              style: TextStyle(
                fontSize: 14,
                height: 18 / 14,
                color: Color(0xff919499),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            model.name,
            style: TextStyle(
              fontSize: 16,
              height: 22 / 16,
              color: Color(0xff292C33),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Offstage(
        //   offstage: model.isShowSuspension != true,
        //   child: Text('界限', style: TextStyle(
        //     fontSize: 20
        //   ),),
        // ),
      ],
    );
    // return ListTile(
    //   contentPadding: EdgeInsets.zero,
    //   minVerticalPadding: 0,
    //   title: Text(model.name),
    //   onTap: () {
    //     LogUtil.v("onItemClick : $model");
    //     Utils.showSnackBar(context, "onItemClick : $model");
    //   },
    // );
  }

  void _search(String text) {
    if (ObjectUtil.isEmpty(text)) {
      _handleList(originList);
    } else {
      List<Languages> list = originList.where((v) {
        return v.name.toLowerCase().contains(text.toLowerCase());
      }).toList();
      _handleList(list);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AzListView(
                data: dataList,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: dataList.length,
                // susPosition: Offset(0, 0),
                itemBuilder: (BuildContext context, int index) {
                  Languages model = dataList[index];
                  return getListItem(context, model, index);
                },
                itemScrollController: itemScrollController,
                // susPosition: ,
                susItemHeight: 0,
                // susItemBuilder: (BuildContext context, int index) {
                //   Languages model = dataList[index];
                //   return getSusItem(context, model.getSuspensionTag());
                // },
                indexBarOptions: IndexBarOptions(
                  needRebuild: true,
                  hapticFeedback: true,
                  textStyle: TextStyle(
                    color: Color(0xff919499),
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                  // indexHintPosition: Offset(0,0),
                  selectTextStyle: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      color: Color(0xff6E66FA),
                      fontWeight: FontWeight.w500),
                  selectItemDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFffffff),
                  ),
                  indexHintWidth: 40,
                  indexHintHeight: 40,
                  indexHintDecoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        Utils.getImgPath('ic_index_bar_bubble_white'),
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                  indexHintAlignment: Alignment.centerRight,
                  indexHintTextStyle:
                      TextStyle(fontSize: 24.0, color: Color(0xff6E66FA)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
