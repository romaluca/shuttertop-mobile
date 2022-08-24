import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:shuttertop/ui/widget/empty_list.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/ui/users/user_list_item.dart';
import 'package:shuttertop/ui/widget/load_list_view.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key key, this.openDrawer}) : super(key: key);
  final Function openDrawer;

  static const String routeName = '/users';

  @override
  _UsersPageState createState() => new _UsersPageState();
}

class _UsersPageState extends State<UsersPage> with TickerProviderStateMixin {
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int countryId;

  TextEditingController _searchQuery;
  bool _isSearching = false;
  //int _usersAdded = 0;
  Timer debounceTimer;

  List<User> elements;
  int refreshCounter = 0;
  UserListItemFormat selectedFilter = UserListItemFormat.scoreWeek;

  bool isLoading = false;
  ScrollController _scrollController;
  AnimationController _cloud1Controller;
  AnimationController _sunController;

  Animation<double> _cloud1;
  double _cloud1Top = 300;

  AnimationController _cloud2Controller;
  Animation<double> _cloud2;
  double _cloud2Top = 70;
  double top = 0;

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
      refreshCounter += 1;
    });
  }

  @override
  void initState() {
    super.initState();
    try {
      _searchQuery = TextEditingController();
      countryId = 0;
      _scrollController = new ScrollController();
      _scrollController.addListener(() {
        setState(() {
          top = _scrollController.offset;
        });
      });
      _sunController = new AnimationController(
        vsync: this,
        duration: new Duration(seconds: 5),
      );

      _sunController.repeat();
      elements = <User>[];
      new Future<void>.delayed(
          const Duration(milliseconds: 500), () => _setAnimation());
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    _cloud1Controller.dispose();
    _cloud2Controller.dispose();
    _scrollController.dispose();
    _sunController.dispose();
    super.dispose();
  }

  void _setAnimation() async {
    final double width = MediaQuery.of(context).size.width;
    _cloud1Controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100000));
    _cloud1 = new Tween<double>(begin: width + 10, end: -150.0).animate(
      new CurvedAnimation(
        parent: _cloud1Controller,
        curve: Curves.linear,
      ),
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          _cloud1Top = getCloudTop();
          _cloud1Controller.reset();
        } else if (status == AnimationStatus.dismissed && mounted) {
          _cloud1Controller.forward();
        }
      });
    _cloud1.addListener(() {
      if (mounted) setState(() {});
    });
    _cloud1Controller.forward();

    _cloud2Controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 60000));
    _cloud2 = new Tween<double>(begin: width + 5, end: -150.0).animate(
      new CurvedAnimation(
        parent: _cloud2Controller,
        curve: Curves.linear,
      ),
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          _cloud2Top = getCloudTop();
          print("_cloud2Top $_cloud2Top");
          _cloud2Controller.reset();
        } else if (status == AnimationStatus.dismissed && mounted) {
          _cloud2Controller.forward();
        }
      });
    _cloud2.addListener(() {
      if (mounted) setState(() {});
    });
    _cloud2Controller.forward();
  }

  double getCloudTop() {
    return new Random().nextDouble() * 350;
  }

  Future<RequestListPage<User>> loadUsers(int page) async {
    return await shuttertop.userRepository.fetch(
        search: _searchQuery.text,
        type: _isSearching ? ListUserType.name : ListUserType.score,
        filterType: selectedFilter,
        page: page);
  }

  Widget adapt(List<User> users, int index) {
    if (elements.isEmpty) return Container();

    if (index < 3 && !_isSearching) {
      if (index == 0) return _getPodium(users);
      return Container(
        height: 0,
      );
    }
    if (index == 3 && !_isSearching)
      return Container(
          padding: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36), topRight: Radius.circular(36))),
          child: Column(
            children: <Widget>[
              Container(
                width: 20.0,
                height: 3.0,
                margin: EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey.withOpacity(0.4)),
              ),
              adaptUser(users, index)
            ],
          ));
    else
      return Container(color: Colors.white, child: adaptUser(users, index));
  }

  Widget _getPodium(List<User> users) {
    if (elements.isEmpty) return Container();
    return Container(
        height: 450,
        child: Stack(children: <Widget>[
          Positioned(
              left: 0,
              right: 0,
              top: top,
              child: Container(
                  height: 450.0,
                  child: Stack(children: <Widget>[
                    Positioned(
                        left: _cloud1?.value ?? -200,
                        top: _cloud1Top,
                        child: Icon(
                          Icons.cloud,
                          size: 80.0,
                          color: Colors.white.withOpacity(0.5),
                        )),
                    Positioned(
                        left: _cloud2?.value ?? -200,
                        top: _cloud2Top,
                        child: Icon(
                          Icons.cloud,
                          size: 80.0,
                          color: Colors.white.withOpacity(0.4),
                        )),
                    Positioned(
                        top: 20,
                        left: 0.0,
                        right: 0,
                        child: Container(
                            height: 430,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 0.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                adaptTop(users, 1),
                                adaptTop(users, 0),
                                adaptTop(users, 2)
                              ],
                            ))),
                    Positioned(
                        top: 42,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                            child: Row(
                          children: <Widget>[
                            _getFilter(
                                "Settimanale", UserListItemFormat.scoreWeek),
                            _getFilter(
                                "Mensile", UserListItemFormat.scoreMonth),
                            _getFilter("Sempre", UserListItemFormat.score)
                          ],
                        ))),
                    Positioned(
                        right: 16,
                        top: 90,
                        child: InkWell(
                            onTap: _startSearch,
                            child: Icon(
                              Icons.search,
                              size: 24.0,
                              color: Colors.white.withOpacity(0.6),
                            ))),
                  ])))
        ]));
  }

  Widget _getFilter(String text, UserListItemFormat filter) {
    final bool isSelected = filter == selectedFilter;
    final Widget e = Container(
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 0 : 16.0),
        child: InkWell(
          onTap: () {
            selectedFilter = filter;
            refreshCounter++;
            setState(() {});
          },
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "Raleway",
                fontSize: isSelected ? 26.0 : 16.0,
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w800),
          ),
        ));
    return isSelected ? Expanded(child: e) : e;
  }

  int _getUserScore(User user) {
    switch (selectedFilter) {
      case UserListItemFormat.scoreMonth:
      case UserListItemFormat.scoreWeek:
        return user.scorePartial;
      default:
        return user.score;
    }
  }

  Widget adaptTop(List<User> users, int index) {
    const List<Color> colors = <Color>[
      Color(0x884E342E),
      Color(0x884E342E),
      Color(0x884E342E)
    ];
    final Widget svg = new SvgPicture.asset(
      'assets/images/award.svg',
      color: colors[index],
    );

    return Container(
        width: 90.0,
        margin: EdgeInsets.only(top: 32.0),
        child: InkWell(
          onTap: () => _showUserPage(users[index]),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Avatar(
                  users[index].getImageUrl(ImageFormat.thumb_small),
                  backColor: Colors.white.withOpacity(0.3),
                  size: 40.0 + ((2 - index) * 15),
                  border: 6.0,
                  shadow: 0.0,
                  shadowColor: Colors.transparent,
                ),
                Container(
                    padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                    child: Text(users[index].name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: "Raleway",
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0))),
                Container(
                    margin: EdgeInsets.only(top: 0.0, bottom: 12),
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(16)),
                    child: Text(
                      "${_getUserScore(users[index])}pts",
                      style: TextStyle(
                          fontFamily: "Raleway",
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 13.0),
                    )),
                Container(
                  width: 90.0,
                  height: 3.0,
                  decoration: BoxDecoration(
                      color: Color(0xFFD4CFA9),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0))),
                ),
                Container(
                  width: 90,
                  height: 85 + ((2 - index) * 40.0),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                        Color(0xFFF4EFC9),
                        Color(0xFFD4CFA9)
                      ])),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.only(top: 16),
                                height: 60,
                                width: 60,
                                child: svg),
                            Container(
                                child: Text(
                              (index + 1).toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0x884E342E),
                                  fontSize: 28,
                                  fontFamily: "Raleway",
                                  fontWeight: FontWeight.w300),
                            ))
                          ],
                        ),
                      ]),
                ),
                Container(
                  width: 90.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                      color: Color(0xFFD4CFA9),
                      borderRadius: BorderRadius.all(Radius.circular(2.0))),
                ),
              ]),
        ));
  }

  Widget adaptUser(List<User> users, int index) {
    return UserListItem(
      users[index],
      _showUserPage,
      position: index + 1,
      format: _isSearching ? UserListItemFormat.normal : selectedFilter,
    );
  }

  void _showUserPage(User user) {
    WidgetUtils.showUserPage(context, user);
    setState(() {});
  }

  String _getFiltersString() {
    if (countryId == 0)
      return AppLocalizations.of(context).mondiale;
    else
      return "";
  }

  Widget _buildTitle() {
    return countryId == 0
        ? Text(
            AppLocalizations.of(context).classifica,
            style: Styles.header,
          )
        : SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 6.0, bottom: 5.0),
                    child: Text(
                      AppLocalizations.of(context).classifica,
                    )),
                Text(
                  _getFiltersString(),
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                )
              ]));
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQuery,
      autofocus: true,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).cercaUtenti,
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
            setState(() {
              refreshCounter += 1;
            });
          }
        });
      },
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
    final double statusbarHeight = MediaQuery.of(context).padding.top;
    final Widget svg = new SvgPicture.asset(
      'assets/images/rays.svg',
      color: Colors.lightBlueAccent[100].withOpacity(0.8),
    );

    return NestedScrollView(
        //controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return _isSearching
              ? <Widget>[
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    //forceElevated: true,
                    elevation: 1.0,
                    pinned: true,
                    leading: _getLeading(),
                    floating: true,
                    snap: false,
                    centerTitle: true,
                    title: _isSearching ? _buildSearchField() : _buildTitle(),

                    actions: _buildActions(),
                  )
                ]
              : <Widget>[
                  /*SliverAppBar(
                      leading: Container(),
                      floating: false,
                      snap: false,
                      pinned: true,
                      expandedHeight: 426,
                      elevation: 0,
                      forceElevated: false,
                      flexibleSpace: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return _getPodium(elements);
                      }))*/
                ];
        },
        body: _isSearching
            ? LoadingListView<User>(loadUsers,
                elements: elements,
                widgetAdapter: adapt,
                refreshRequestCounter: refreshCounter,
                indexer: (User e) => e.id,
                emptyWidget: EmptyList(Icons.people, "Nessun utente trovato"))
            : Stack(children: <Widget>[
                Material(
                    color: Colors.white,
                    child: Container(
                        margin: EdgeInsets.only(top: statusbarHeight),
                        height: 455,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(36),
                                topRight: Radius.circular(36)),
                            gradient: LinearGradient(
                                colors: <Color>[
                                  Colors.lightBlue,
                                  Colors.lightBlue[300],
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomCenter)))),
                Positioned(
                    top: -150,
                    left: -100,
                    right: -100,
                    child: new AnimatedBuilder(
                      animation: _sunController,
                      child: Container(height: 600, width: 600, child: svg),
                      builder: (BuildContext context, Widget _widget) {
                        return new Transform.rotate(
                          angle: _sunController.value * 6.3,
                          child: _widget,
                        );
                      },
                    )),
                LoadingListView<User>(loadUsers,
                    elements: elements,
                    widgetAdapter: adapt,
                    refreshRequestCounter: refreshCounter,
                    scrollController: _scrollController,
                    indexer: (User e) => e.id,
                    emptyWidget:
                        EmptyList(Icons.people, "Nessun utente trovato"))
              ]));
  }

/*
  Future<Null> _showOrderDialog() async {
    final int o = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("Paesi"),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 0);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: Text("Tutti"),
                  )),
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 1);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: Text("Italia"),
                  )),
            ],
          );
        });
    if (o != null) setState(() => countryId = o);
  }
*/
  void onError(String message) {
    print("UsersPage onError");
    //_scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
