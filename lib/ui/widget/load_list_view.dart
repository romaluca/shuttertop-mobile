import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';

class LoadingListView<T> extends StatefulWidget {
  LoadingListView(this.pageRequest,
      {this.pageSize: 30,
      this.pageThreshold: 5,
      @required this.widgetAdapter,
      this.reverse: false,
      this.indexer,
      this.topStream,
      this.padding = const EdgeInsets.all(0.0),
      @required this.elements,
      this.refreshRequestCounter = 0,
      this.withRefresh: true,
      this.initialRefresh: false,
      this.scrollDirection: Axis.vertical,
      this.scrollController,
      this.loadingWidget = const Center(child: CircularProgressIndicator()),
      this.emptyWidget});

  final PageRequest<T> pageRequest;
  final int pageSize;
  final int pageThreshold;
  final WidgetAdapter<T> widgetAdapter;
  final bool reverse;
  final bool withRefresh;
  final int refreshRequestCounter;
  final Widget loadingWidget;
  final EdgeInsets padding;
  final Indexer<T> indexer;
  final ScrollController scrollController;
  final List<T> elements;
  final bool initialRefresh;
  final Widget emptyWidget;
  final Axis scrollDirection;

  /// New elements will appear at the start
  final Stream<T> topStream;

  @override
  State<StatefulWidget> createState() {
    return _LoadingListViewState<T>();
  }
}

class _LoadingListViewState<T> extends State<LoadingListView<T>> {
  Map<int, int> index = <int, int>{};
  Future<Null> request;
  int totObjects;
  bool _isLoading = true;
  bool _isComplete = false;
  int _lastPage = -1;
  int _lastRefreshRequestCounter;
  Notification notify;

  @override
  Widget build(BuildContext context) {
    if (_lastRefreshRequestCounter != widget.refreshRequestCounter) {
      _lastRefreshRequestCounter = widget.refreshRequestCounter;
      onRefresh();
    }
    if (_isLoading)
      return widget.scrollDirection == Axis.horizontal
          ? Container()
          : widget.loadingWidget;
    if (!_isLoading &&
        _lastPage == 0 &&
        widget.elements.isEmpty &&
        widget.emptyWidget != null) return widget.emptyWidget;

    final ListView listView = ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: widget.scrollDirection,
      itemBuilder: itemBuilder,
      itemCount: widget.elements.length,
      reverse: widget.reverse,
      controller: widget.scrollController,
      padding: widget.padding,
    );
    if (!widget.withRefresh) return listView;

    final RefreshIndicator refreshIndicator =
        RefreshIndicator(onRefresh: onRefresh, child: listView);
    return NotificationListener<ListElementUpdate<T>>(
        child: refreshIndicator, onNotification: onUpdate);
  }

  @override
  void initState() {
    super.initState();
    print("LoadListView initState");
    //if (widget.initialRefresh)
    //  widget.elements.clear();
    notify = new LoadedNotification();
    _lastRefreshRequestCounter = widget.refreshRequestCounter;
    lockedLoadNext(widget.initialRefresh);
    if (widget.topStream != null) {
      widget.topStream.listen((T t) {
        setState(() {
          if (widget.reverse)
            widget.elements.insert(0, t);
          else
            widget.elements.insert(widget.elements.length, t);
          reIndex();
        });
      });
    }
  }

  Widget itemBuilder(BuildContext context, int index) {
    if (!_isComplete &&
        (totObjects == null ||
            (totObjects > widget.elements.length &&
                index + widget.pageThreshold > widget.elements.length))) {
      print(
          "itemBuilder totObjects: $totObjects length: ${widget.elements.length}");
      notifyThreshold();
    }
    if (widget.widgetAdapter == null) return Container(height: 0.0, width: 0.0);
    return widget.widgetAdapter(widget.elements, index);
  }

  void notifyThreshold() {
    print("-----notifyThreshold");
    lockedLoadNext();
  }

  bool onUpdate(ListElementUpdate<T> update) {
    if (widget.indexer == null) {
      debugPrint("ListElementUpdate on un-indexed list");
      return false;
    }

    final int i = index[update.key];
    if (i == null) {
      debugPrint("ListElementUpdate index not found");
      return false;
    }

    setState(() {
      widget.elements[i] = update.instance;
    });
    return true;
  }

  Future<Null> onRefresh() async {
    _lastPage = 0;
    request?.timeout(const Duration());
    final RequestListPage<T> fetched = await widget.pageRequest(0);
    setState(() {
      widget.elements.clear();
      index.clear();
      addObjects(fetched.entries);
      _isComplete = false;
    });
  }

  void lockedLoadNext([bool clear = false]) {
    print("lockedLoadNext ${widget.elements.length}");
    if (request == null) {
      request = loadNext(clear).then((Null x) {
        request = null;
        _isLoading = false;
      });
    }
  }

  Future<Null> loadNext([bool clear = false]) async {
    if (!mounted) return;
    final int page =
        clear ? 0 : (widget.elements.length / widget.pageSize).ceil();
    if (_lastPage == page && !clear) {
      _isComplete = true;
      return;
    }
    print("LoadListView loadNext ${page + 1}");
    final RequestListPage<T> fetched = await widget.pageRequest(page + 1);

    if (mounted && fetched != null) {
      print("LoadListView fetched entries: ${fetched.entries.length}");
      setState(() {
        addObjects(fetched.entries);
        totObjects = fetched.totalEntries;
        _lastPage = page;
        _isComplete = (fetched.entries.isEmpty);
      });
      notify.dispatch(context);
    }
  }

  void addObjects(Iterable<T> objects) {
    if (widget.reverse) objects = objects.toList().reversed.toList();
    objects.forEach((T object) {
      if (!widget.elements.contains(object)) {
        widget.elements.add(object);
      }
      if (widget.indexer == null ||
          !index.containsKey(widget.indexer(object))) {
        final int index = widget.elements.length;

        //widget.elements.add(object);
        if (widget.indexer != null) this.index[widget.indexer(object)] = index;
      }
    });
  }

  void reIndex() {
    index.clear();
    if (widget.indexer != null) {
      int i = 0;
      widget.elements.forEach((T object) {
        index[widget.indexer(object)] == i;
        i++;
      });
    }
  }
}
