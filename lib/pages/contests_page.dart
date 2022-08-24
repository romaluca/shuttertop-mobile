import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/ui/contests/contest_list.dart';
import 'package:shuttertop/ui/contests/contest_list_home.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';

class ContestsPage extends StatefulWidget {
  final Function openDrawer;
  final bool searchMode;

  const ContestsPage({Key key, this.openDrawer, this.searchMode = false})
      : super(key: key);

  static const String routeName = '/contests';

  @override
  _ContestsPageState createState() => new _ContestsPageState();
}

class _ContestsPageState extends State<ContestsPage>
    with SingleTickerProviderStateMixin {
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tabController;
  ScrollController _scrollController;

  Category category;
  bool _isFilterChanging = false;
  int _contestsAdded = 0;

  TextEditingController _searchQuery;
  bool _isSearching = false;
  Timer debounceTimer;

  @override
  void initState() {
    super.initState();
    try {
      category = Contest.categories.first;
      _searchQuery = TextEditingController();
      _scrollController = new ScrollController();
      _isSearching = widget.searchMode;
      _tabController = TabController(vsync: this, length: 3);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQuery.clear();
      _contestsAdded += 1;
    });
  }

  /*
  Future<Null> _showOrderDialog() async {
    _isFilterChanging = true;
    final Category ret =
        await Navigator.of(context).push(new MaterialPageRoute<Category>(
            builder: (BuildContext context) {
              return new ContestFiltersDialog(category);
            },
            fullscreenDialog: true));

    if (ret != null)
      setState(() {
        category = ret;
      });
    _isFilterChanging = false;
  }*/

  void _showContestPage(Contest contest, {@required bool join}) {
    WidgetUtils.showContestPage(context, contest,
        join: join, showComments: false);
    setState(() {});
  }

  String _getFiltersString() {
    return (category.id > 0 ? "${category.name}" : "");
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQuery,
      autofocus: true,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).cercaUnContest,
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.black45),
      ),
      style: const TextStyle(color: Colors.black87, fontSize: 16.0),
      onChanged: (String query) {
        if (debounceTimer != null) {
          debounceTimer.cancel();
        }
        debounceTimer = Timer(Duration(milliseconds: 500), () {
          if (mounted) {
            print(_searchQuery.text);
            _isFilterChanging = true;
            setState(() {
              _contestsAdded += 1;
            });
            _isFilterChanging = false;
          }
        });
      },
    );
  }

  Widget _buildTitle() {
    return category.id > 0
        ? SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 6.0, bottom: 5.0),
                    child: Text(
                      AppLocalizations.of(context).contest,
                    )),
                Text(
                  _getFiltersString(),
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                )
              ]))
        : Text(
            AppLocalizations.of(context).contest,
            style: Styles.header,
          );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQuery == null || _searchQuery.text.isEmpty) {
              // Stop searching.
              Navigator.pop(context);
              return;
            }

            _clearSearchQuery();
          },
        ),
      ];
    }
    return <Widget>[
      /*
      IconButton(
        icon: Icon(Icons.filter_list),
        color: Colors.black54,
        tooltip: 'Ordina',
        onPressed: _showOrderDialog,
      ),*/
      IconButton(
        icon: Icon(Icons.search),
        color: Colors.black54,
        tooltip: AppLocalizations.of(context).cerca,
        onPressed: _startSearch,
      ),
    ];
  }

  Widget _getLeading() {
    if (_isSearching) return const BackButton();
    /*
    if (widget.openDrawer != null)
      return IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.black54,
          ),
          onPressed: () => widget.openDrawer());*/
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> categoryList = _isSearching // widget.searchMode
        ? <Tab>[Tab(text: AppLocalizations.of(context).nome)]
        : <Tab>[
            Tab(text: AppLocalizations.of(context).esplora),
            Tab(text: AppLocalizations.of(context).inGara),
            Tab(text: AppLocalizations.of(context).following)
          ].toList();
    final List<Widget> contestsList = _isSearching //? widget.searchMode
        ? <ContestList>[
            ContestList(
              category: category,
              search: _searchQuery.text,
              inProgress: true,
              searchMode: true,
              onTap: (Contest contest, {@required bool join}) {
                print(contest);
                Navigator.of(context).pop(contest);
              },
              order: ListOrder.name,
              contestsAdded: _contestsAdded,
            ),
          ]
        : <Widget>[
            ContestListHome(
              onTap: _showContestPage,
              scrollController: _scrollController,
            ),
            ContestList(
                category: category,
                search: _searchQuery.text,
                inProgress: true,
                type: ContestFetchType.joined,
                onTap: _showContestPage,
                order: ListOrder.top,
                contestsAdded: _contestsAdded),
            ContestList(
                category: category,
                search: _searchQuery.text,
                type: ContestFetchType.following,
                onTap: _showContestPage,
                order: ListOrder.news,
                contestsAdded: _contestsAdded),
          ].toList();

    if (_isFilterChanging)
      return Container();
    else
      return NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: Colors.white,
                //forceElevated: true,
                elevation: 1.0,
                pinned: true,
                floating: true,
                snap: false,
                title: _isSearching ? _buildSearchField() : _buildTitle(),
                centerTitle: true,

                leading: _getLeading(),
                actions: _buildActions(),
                bottom: _isSearching
                    ? null
                    : TabBar(
                        labelStyle: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w700),
                        indicatorWeight: 2.0,
                        isScrollable: false,
                        labelColor: Colors.grey[700],
                        unselectedLabelColor: Color(0xffCCCCCC),
                        indicatorColor: Colors.grey[500],
                        controller: _tabController,
                        tabs: categoryList),
              )
            ];
          },
          body: Container(
              child: TabBarView(
                controller: _tabController,
                children: contestsList,
              ),
              color: Colors.white));
  }
}
