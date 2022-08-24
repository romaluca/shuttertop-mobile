import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';

class LoadingGridView<T> extends StatefulWidget {
  LoadingGridView(
    this.pageRequest, {
    this.pageSize: 30,
    this.pageThreshold: 5,
    @required this.widgetAdapter,
    this.reverse: false,
    this.indexer,
    this.topStream,
    this.withRefresh: true,
  });

  final PageRequest<T> pageRequest;
  final int pageSize;
  final int pageThreshold;
  final WidgetAdapter<T> widgetAdapter;
  final bool reverse;
  final bool withRefresh;
  final Indexer<T> indexer;

  /// New elements will appear at the start
  final Stream<T> topStream;

  @override
  State<StatefulWidget> createState() {
    return new _LoadingGridViewState<T>();
  }
}

class _LoadingGridViewState<T> extends State<LoadingGridView<T>> {
  List<T> objects = <T>[];
  Map<int, int> index = <int, int>{};
  Future<Null> request;
  int totObjects;
  bool _isLoading = true;
  bool _isComplete = false;
  int _lastPage = -1;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: WidgetUtils.spinLoader());

    final GridView listView = GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        //childAspectRatio: 3.0,
      ),
      itemBuilder: itemBuilder,
      itemCount: objects.length,
      reverse: widget.reverse,
      padding: EdgeInsets.all(0.0),
    );

    if (!widget.withRefresh) return listView;

    final RefreshIndicator refreshIndicator = RefreshIndicator(
      onRefresh: onRefresh,
      child: listView,
    );
    return NotificationListener<ListElementUpdate<T>>(
        child: refreshIndicator, onNotification: onUpdate);
  }

  @override
  void initState() {
    super.initState();
    lockedLoadNext();
    if (widget.topStream != null) {
      widget.topStream.listen((T t) {
        setState(() {
          objects.insert(0, t);
          reIndex();
        });
      });
    }
  }

  Widget itemBuilder(BuildContext context, int index) {
    if (!_isComplete &&
        (totObjects == null ||
            (totObjects > objects.length &&
                index + widget.pageThreshold > objects.length))) {
      print("itemBuilder totObjects: $totObjects length: ${objects.length}");
      notifyThreshold();
    }

    return widget.widgetAdapter != null
        ? widget.widgetAdapter(objects, index)
        : Container();
  }

  void notifyThreshold() {
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
      objects[i] = update.instance;
    });
    return true;
  }

  Future<Null> onRefresh() async {
    _lastPage = -1;
    request?.timeout(const Duration());
    final RequestListPage<T> fetched = await widget.pageRequest(0);
    setState(() {
      objects.clear();
      index.clear();
      addObjects(fetched.entries);
      _isComplete = false;
    });
  }

  void lockedLoadNext() {
    if (request == null) {
      request = loadNext().then((Null x) {
        request = null;
        _isLoading = false;
      });
    }
  }

  Future<Null> loadNext() async {
    final int page = (objects.length / widget.pageSize).ceil();
    if (_lastPage == page) {
      _isComplete = true;
      return;
    }
    final RequestListPage<T> fetched = await widget.pageRequest(page + 1);

    if (mounted && fetched != null) {
      setState(() {
        print("loadNext entries: ${fetched.entries.length}");
        addObjects(fetched.entries);
        totObjects = fetched.totalEntries;
        _isComplete = fetched.entries.isEmpty;
        _lastPage = page;
      });
    }
  }

  void addObjects(Iterable<T> objects) {
    objects.forEach((T object) {
      if (widget.indexer == null ||
          !index.containsKey(widget.indexer(object))) {
        final int index = objects.length;
        this.objects.add(object);
        if (widget.indexer != null) this.index[widget.indexer(object)] = index;
      }
    });
  }

  void reIndex() {
    index.clear();
    if (widget.indexer != null) {
      int i = 0;
      objects.forEach((T object) {
        index[widget.indexer(object)] == i;
        i++;
      });
    }
  }
}
