import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/services/base_service.dart';

class LoadingPageView<T> extends StatefulWidget {
  final PageRequest<T> pageRequest;
  final int pageSize;
  final int pageThreshold;
  final WidgetAdapter<T> widgetAdapter;
  final bool reverse;
  final Indexer<T> indexer;
  final List<T> initialItems;

  /// New elements will appear at the start
  final Stream<T> topStream;

  LoadingPageView(
    this.pageRequest, {
    this.pageSize: 30,
    this.pageThreshold: 25,
    @required this.widgetAdapter,
    this.reverse: false,
    this.initialItems,
    this.indexer,
    this.topStream,
  });

  @override
  State<StatefulWidget> createState() {
    return new _LoadingPageViewState<T>();
  }
}

class _LoadingPageViewState<T> extends State<LoadingPageView<T>> {
  List<T> objects = <T>[];
  Map<int, int> index = <int, int>{};
  Future<Null> request;
  int totObjects;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        itemBuilder: itemBuilder,
        itemCount: objects.length,
        reverse: widget.reverse);
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialItems != null)
      objects.addAll(widget.initialItems);
    else
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
    if (index + widget.pageThreshold > objects.length) {
      notifyThreshold();
    }

    return widget.widgetAdapter != null
        ? widget.widgetAdapter(objects, index)
        : new Container();
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

  Future<bool> onRefresh() async {
    request?.timeout(const Duration());
    final RequestListPage<T> fetched = await widget.pageRequest(0);
    setState(() {
      objects.clear();
      index.clear();
      addObjects(fetched.entries);
    });

    return true;
  }

  void lockedLoadNext() {
    if (request == null) {
      request = loadNext().then((Null x) {
        request = null;
      });
    }
  }

  Future<Null> loadNext() async {
    final int page = (objects.length / widget.pageSize).ceil();
    final RequestListPage<T> fetched = await widget.pageRequest(page);

    if (mounted && fetched != null) {
      setState(() {
        addObjects(fetched.entries);
      });
    }
  }

  void addObjects(Iterable<T> objects) {
    objects.forEach((T object) {
      if (widget.indexer == null ||
          !index.containsKey(widget.indexer(object))) {
        final int index = this.objects.length;
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
