// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

enum DraggableScrollableSheetState { ANCHOR_POINT, EXPANDED, COLLAPSED, HIDDEN }

/// The signature of a method that provides a [BuildContext] and
/// [ScrollController] for building a widget that may overflow the draggable
/// [Axis] of the containing [DraggableScrollSheet].
///
/// Users should apply the [scrollController] to a [ScrollView] subclass, such
/// as a [SingleChildScrollView], [ListView] or [GridView], to have the whole
/// sheet be draggable.
typedef ScrollableWidgetBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
);

/// A container for a [Scrollable] that responds to drag gestures by resizing
/// the scrollable until a limit is reached, and then scrolling.
///
/// This widget can be dragged along the vertical axis between its
/// [minChildSize], which defaults to `0.25` and [maxChildSize], which defaults
/// to `1.0`. These sizes are percentages of the height of the parent container.
///
/// The widget coordinates resizing and scrolling of the widget returned by
/// builder as the user drags along the horizontal axis.
///
/// The widget will initially be displayed at its initialChildSize which
/// defaults to `0.5`, meaning half the height of its parent. Dragging will work
/// between the range of minChildSize and maxChildSize (as percentages of the
/// parent container's height) as long as the builder creates a widget which
/// uses the provided [ScrollController]. If the widget created by the
/// [ScrollableWidgetBuilder] does not use the provided [ScrollController], the
/// sheet will remain at the initialChildSize.
///
/// By default, the widget will expand its non-occupied area to fill available
/// space in the parent. If this is not desired, e.g. because the parent wants
/// to position sheet based on the space it is taking, the [expand] property
/// may be set to false.
///
/// {@tool sample}
///
/// This is a sample widget which shows a [ListView] that has 25 [ListTile]s.
/// It starts out as taking up half the body of the [Scaffold], and can be
/// dragged up to the full height of the scaffold or down to 25% of the height
/// of the scaffold. Upon reaching full height, the list contents will be
/// scrolled up or down, until they reach the top of the list again and the user
/// drags the sheet back down.
///
/// ```dart
/// class HomePage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(
///         title: const Text('DraggableScrollableSheet'),
///       ),
///       body: SizedBox.expand(
///         child: DraggableScrollableSheet(
///           builder: (BuildContext context, ScrollController scrollController) {
///             return Container(
///               color: Colors.blue[100],
///               child: ListView.builder(
///                 controller: scrollController,
///                 itemCount: 25,
///                 itemBuilder: (BuildContext context, int index) {
///                   return ListTile(title: Text('Item $index'));
///                 },
///               ),
///             );
///           },
///         ),
///       ),
///     );
///   }
/// }
/// ```
/// {@end-tool}
class DraggableScrollableSheet extends StatefulWidget {
  /// Creates a widget that can be dragged and scrolled in a single gesture.
  ///
  /// The [builder], [initialChildSize], [minChildSize], [maxChildSize] and
  /// [expand] parameters must not be null.
  DraggableScrollableSheet({
    Key key,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.20,
    this.maxChildSize = 1.0,
    this.anchorSize = 0.60,
    this.expand = true,
    this.draggable = true,
    @required this.builder,
  })  : assert(initialChildSize != null),
        assert(minChildSize != null),
        assert(maxChildSize != null),
        assert(minChildSize >= 0.0),
        assert(maxChildSize <= 1.0),
//        assert(minChildSize <= initialChildSize),
        assert(initialChildSize <= maxChildSize),
        assert(expand != null),
        assert(builder != null),
        super(key: key);

  /// The initial fractional value of the parent container's height to use when
  /// displaying the widget.
  ///
  /// The default value is `0.5`.
  double initialChildSize;

  /// The minimum fractional value of the parent container's height to use when
  /// displaying the widget.
  ///
  /// The default value is `0.25`.
  double minChildSize;

  double anchorSize;

  /// The maximum fractional value of the parent container's height to use when
  /// displaying the widget.
  ///
  /// The default value is `1.0`.
  double maxChildSize;

  /// Whether the widget should expand to fill the available space in its parent
  /// or not.
  ///
  /// In most cases, this should be true. However, in the case of a parent
  /// widget that will position this one based on its desired size (such as a
  /// [Center]), this should be set to false.
  ///
  /// The default value is true.
  bool expand;

  bool draggable;

  /// The builder that creates a child to display in this widget, which will
  /// use the provided [ScrollController] to enable dragging and scrolling
  /// of the contents.
  final ScrollableWidgetBuilder builder;

  @override
  _DraggableScrollableSheetState createState() => _DraggableScrollableSheetState();
}

/// A [Notification] related to the extent, which is the size, and scroll
/// offset, which is the position of the child list, of the
/// [DraggableScrollableSheet].
///
/// [DraggableScrollableSheet] widgets notify their ancestors when the size of
/// the sheet changes. When the extent of the sheet changes via a drag,
/// this notification bubbles up through the tree, which means a given
/// [NotificationListener] will receive notifications for all descendant
/// [DraggableScrollableSheet] widgets. To focus on notifications from the
/// nearest [DraggableScorllableSheet] descendant, check that the [depth]
/// property of the notification is zero.
///
/// When an extent notification is received by a [NotificationListener], the
/// listener will already have completed build and layout, and it is therefore
/// too late for that widget to call [State.setState]. Any attempt to adjust the
/// build or layout based on an extent notification would result in a layout
/// that lagged one frame behind, which is a poor user experience. Extent
/// notifications are used primarily to drive animations. The [Scaffold] widget
/// listens for extent notifications and responds by driving animations for the
/// [FloatingActionButton] as the bottom sheet scrolls up.
class DraggableScrollableNotification extends Notification with ViewportNotificationMixin {
  /// Creates a notification that the extent of a [DraggableScrollableSheet] has
  /// changed.
  ///
  /// All parameters are required. The [minExtent] must be >= 0.  The [maxExtent]
  /// must be <= 1.0.  The [extent] must be between [minExtent] and [maxExtent].
  DraggableScrollableNotification({
    @required this.extent,
    @required this.minExtent,
    this.anchorExtent,
    @required this.maxExtent,
    @required this.initialExtent,
    @required this.context,
  })  : assert(extent != null),
        assert(initialExtent != null),
        assert(minExtent != null),
        assert(maxExtent != null),
        assert(0.0 <= minExtent),
        assert(maxExtent <= 1.0),
//        assert(minExtent <= extent),
//        assert(minExtent <= initialExtent),
        assert(extent <= maxExtent),
        assert(initialExtent <= maxExtent),
        assert(context != null);

  /// The current value of the extent, between [minExtent] and [maxExtent].
  final double extent;

  /// The minimum value of [extent], which is >= 0.
  final double minExtent;

  final double anchorExtent;

  /// The maximum value of [extent].
  final double maxExtent;

  /// The initially requested value for [extent].
  final double initialExtent;

  /// The build context of the widget that fired this notification.
  ///
  /// This can be used to find the sheet's render objects to determine the size
  /// of the viewport, for instance. A listener can only assume this context
  /// is live when it first gets the notification.
  final BuildContext context;

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add(
        'minExtent: $minExtent, extent: $extent, maxExtent: $maxExtent, anchorExtent: $anchorExtent, initialExtent: $initialExtent');
  }
}

/// Manages state between [_DraggableScrollableSheetState],
/// [_DraggableScrollableSheetScrollController], and
/// [_DraggableScrollableSheetScrollPosition].
///
/// The State knows the pixels available along the axis the widget wants to
/// scroll, but expects to get a fraction of those pixels to render the sheet.
///
/// The ScrollPosition knows the number of pixels a user wants to move the sheet.
///
/// The [currentExtent] will never be null.
/// The [availablePixels] will never be null, but may be `double.infinity`.
class _DraggableSheetExtent {
  _DraggableSheetExtent({
    @required this.minExtent,
    @required this.maxExtent,
    @required this.initialExtent,
    this.anchorExtent,
    @required VoidCallback listener,
    this.context,
    this.draggable,
  })  : assert(minExtent != null),
        assert(maxExtent != null),
        assert(initialExtent != null),
        assert(minExtent >= 0),
        assert(maxExtent <= 1),
//        assert(minExtent <= initialExtent),
        assert(initialExtent <= maxExtent),
        _currentExtent = ValueNotifier<double>(initialExtent)..addListener(listener),
        availablePixels = double.infinity;

  double minExtent;
  double anchorExtent;
  double maxExtent;
  double initialExtent;
  bool draggable;

  final ValueNotifier<double> _currentExtent;
  double availablePixels;
  final BuildContext context;

  bool get isAtMin => minExtent >= _currentExtent.value;

  bool get isAtMax => maxExtent <= _currentExtent.value;

  bool get isInMaxArea {
    return currentExtent >= anchorExtent + (maxExtent - anchorExtent) / 2;
  }

  bool get isInAnchorArea {
    return currentExtent >= minExtent + (anchorExtent - minExtent) / 2 &&
        currentExtent < anchorExtent + (maxExtent - anchorExtent) / 2;
  }

  bool get isInMinArea {
    return currentExtent < minExtent + (anchorExtent - minExtent) / 2;
  }

  set currentExtent(double value) {
    assert(value != null);
    _currentExtent.value = value.clamp(/*minExtent*/ 0.0, maxExtent);

    DraggableScrollableNotification(
      minExtent: minExtent,
      maxExtent: maxExtent,
      anchorExtent: anchorExtent,
      extent: _currentExtent.value,
      initialExtent: initialExtent,
      context: context,
    ).dispatch(context);
  }

  double get currentExtent => _currentExtent.value;

  double get additionalMinExtent => isAtMin ? 0.0 : 1.0;

  double get additionalMaxExtent => isAtMax ? 0.0 : 1.0;

  /// The scroll position gets inputs in terms of pixels, but the extent is
  /// expected to be expressed as a number between 0..1.
  void addPixelDelta(double delta, BuildContext context) {
    if (availablePixels == 0) {
      return;
    }
    currentExtent += delta / availablePixels * maxExtent;
//    DraggableScrollableNotification(
//      minExtent: minExtent,
//      maxExtent: maxExtent,
//      anchorExtent: anchorExtent,
//      extent: currentExtent,
//      initialExtent: initialExtent,
//      context: context,
//    ).dispatch(context);
  }
}

class _DraggableScrollableSheetState extends State<DraggableScrollableSheet> with SingleTickerProviderStateMixin {
  _DraggableScrollableSheetScrollController _scrollController;
  _DraggableSheetExtent _extent;

  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    _extent = _DraggableSheetExtent(
      minExtent: widget.minChildSize,
      maxExtent: widget.maxChildSize,
      anchorExtent: widget.anchorSize,
      initialExtent: widget.initialChildSize,
      listener: _setExtent,
      context: context,
      draggable: widget.draggable,
    );
    _scrollController = _DraggableScrollableSheetScrollController(extent: _extent);

    animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..addListener(() {
        _extent.currentExtent = animationController.value;
      });

    //dispatch init position
    _extent.currentExtent = widget.initialChildSize;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_extent.initialExtent != widget.initialChildSize) {
      _extent.initialExtent = widget.initialChildSize;
    }
    if (_extent.minExtent != widget.minChildSize) {
      _extent.minExtent = widget.minChildSize;
    }
    if (_extent.maxExtent != widget.maxChildSize) {
      _extent.maxExtent = widget.maxChildSize;
    }
    if (_extent.anchorExtent != widget.anchorSize) {
      _extent.anchorExtent = widget.anchorSize;
    }
    if (_extent.draggable != widget.draggable) {
      _extent.draggable = widget.draggable;
    }

    if (_InheritedUpdatePositionStateNotifier.shouldReset(context)) {
      // jumpTo can result in trying to replace semantics during build.
      // Just animate really fast.
      // Avoid doing it at all if the offset is already 0.0.
      _contentScrollToZero(1);
      _animateSheetTo(_extent.initialExtent);
    } else if (_InheritedUpdatePositionStateNotifier.shouldSetMax(context)) {
      _animateSheetTo(_extent.maxExtent);
    } else if (_InheritedUpdatePositionStateNotifier.shouldSetAnchor(context)) {
      _contentScrollToZero(1);
      _animateSheetTo(_extent.anchorExtent);
    } else if (_InheritedUpdatePositionStateNotifier.shouldSetMin(context)) {
      _contentScrollToZero(1);
      _animateSheetTo(_extent.minExtent);
    } else if (_InheritedUpdatePositionStateNotifier.shouldHide(context)) {
      _extent._currentExtent.value = 0;
    }
  }

  void _animateSheetTo(double target) {
    animationController.value = _extent._currentExtent.value;
    animationController.animateTo(target, curve: Curves.linearToEaseOut);
  }

  void _contentScrollToZero([int milliseconds = 1]) {
    if (_scrollController.offset != 0.0) {
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: milliseconds),
        curve: Curves.linearToEaseOut,
      );
    }
  }

  void _setExtent() {
    setState(() {
      // _extent has been updated when this is called.
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _extent.availablePixels = widget.maxChildSize * constraints.biggest.height;
        final Widget sheet = FractionallySizedBox(
          heightFactor: _extent.currentExtent,
          child: NotificationListener<ScrollEndNotification>(
              onNotification: (scrollEndNotification) {
//                WidgetsBinding.instance.addPostFrameCallback((_) => adjustPosition());
                adjustPosition(scrollEndNotification.dragDetails?.velocity);
                return false;
              },
              child: widget.builder(context, _scrollController)),
          alignment: Alignment.bottomCenter,
        );
        return widget.expand ? SizedBox.expand(child: sheet) : sheet;
      },
    );
  }

  void adjustPosition(Velocity velocity) {
    //when no velocity dy
    if(velocity?.pixelsPerSecond?.dy == null || velocity?.pixelsPerSecond?.dy == 0.0) {
      if (_extent.isInMaxArea) {
        DraggableScrollableActuator.setMax(context);
      } else if (_extent.isInAnchorArea) {
        DraggableScrollableActuator.setAnchor(context);
      } else if (_extent.isInMinArea) {
        DraggableScrollableActuator.setMin(context);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

/// A [ScrollController] suitable for use in a [ScrollableWidgetBuilder] created
/// by a [DraggableScrollableSheet].
///
/// If a [DraggableScrollableSheet] contains content that is exceeds the height
/// of its container, this controller will allow the sheet to both be dragged to
/// fill the container and then scroll the child content.
///
/// See also:
///
///  * [_DraggableScrollableSheetScrollPosition], which manages the positioning logic for
///    this controller.
///  * [PrimaryScrollController], which can be used to establish a
///    [_DraggableScrollableSheetScrollController] as the primary controller for
///    descendants.
class _DraggableScrollableSheetScrollController extends ScrollController {
  _DraggableScrollableSheetScrollController({
    double initialScrollOffset = 0.0,
    String debugLabel,
    @required this.extent,
  })  : assert(extent != null),
        super(
          debugLabel: debugLabel,
          initialScrollOffset: initialScrollOffset,
        );

  final _DraggableSheetExtent extent;

  @override
  _DraggableScrollableSheetScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition oldPosition,
  ) {
    return _DraggableScrollableSheetScrollPosition(
      physics: physics,
      context: context,
      oldPosition: oldPosition,
      extent: extent,
    );
  }

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('extent: $extent');
  }
}

/// A scroll position that manages scroll activities for
/// [_DraggableScrollableSheetScrollController].
///
/// This class is a concrete subclass of [ScrollPosition] logic that handles a
/// single [ScrollContext], such as a [Scrollable]. An instance of this class
/// manages [ScrollActivity] instances, which changes the
/// [_DraggableSheetExtent.currentExtent] or visible content offset in the
/// [Scrollable]'s [Viewport]
///
/// See also:
///
///  * [_DraggableScrollableSheetScrollController], which uses this as its [ScrollPosition].
class _DraggableScrollableSheetScrollPosition extends ScrollPositionWithSingleContext {
  _DraggableScrollableSheetScrollPosition({
    @required ScrollPhysics physics,
    @required ScrollContext context,
    double initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition oldPosition,
    String debugLabel,
    @required this.extent,
  })  : assert(extent != null),
        super(
          physics: physics,
          context: context,
          initialPixels: initialPixels,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        );

  VoidCallback _dragCancelCallback;
  final _DraggableSheetExtent extent;

  bool get listShouldScroll => pixels > 0.0;

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    // We need to provide some extra extent if we haven't yet reached the max or
    // min extents. Otherwise, a list with fewer children than the extent of
    // the available space will get stuck.
    return super.applyContentDimensions(
      minScrollExtent - extent.additionalMinExtent,
      maxScrollExtent + extent.additionalMaxExtent,
    );
  }

  @override
  void applyUserOffset(double delta) {
    if (extent.draggable == true &&
        !listShouldScroll &&
        (!(/*extent.isAtMin ||*/ extent.isAtMax) || (extent.isAtMin && delta < 0) || (extent.isAtMax && delta > 0))) {
      extent.addPixelDelta(-delta, context.notificationContext);
    } else {
      super.applyUserOffset(delta);
    }
  }

  @override
  void goBallistic(double velocity) {
    if (extent.draggable != true ||
        velocity == 0.0 ||
        (velocity < 0.0 && listShouldScroll) ||
        (velocity > 0.0 && extent.isAtMax)) {
      super.goBallistic(velocity);
      return;
    }
    // Scrollable expects that we will dispose of its current _dragCancelCallback
    _dragCancelCallback?.call();
    _dragCancelCallback = null;


    if (velocity > 0) {
      //up
      if (extent.currentExtent > extent.anchorExtent) {
        DraggableScrollableActuator.setMax(context.notificationContext);
      } else if (extent.currentExtent > extent.minExtent) {
        DraggableScrollableActuator.setAnchor(context.notificationContext);
      } else {
        DraggableScrollableActuator.setMin(context.notificationContext);
      }
    } else if (velocity < 0) {
      //down
      if (extent.currentExtent > extent.anchorExtent) {
        DraggableScrollableActuator.setAnchor(context.notificationContext);
      } else
      /*if (extent.currentExtent > extent.minExtent)*/ {
        DraggableScrollableActuator.setMin(context.notificationContext);
      }
    }

//    // The iOS bouncing simulation just isn't right here - once we delegate
//    // the ballistic back to the ScrollView, it will use the right simulation.
//    final Simulation simulation = ClampingScrollSimulation(
//      position: extent.currentExtent,
//      velocity: velocity,
//      tolerance: physics.tolerance,
//    );
//
//    final AnimationController ballisticController = AnimationController.unbounded(
//      debugLabel: '$runtimeType',
//      vsync: context.vsync,
//    );
//    double lastDelta = 0;
//    void _tick() {
//      final double delta = ballisticController.value - lastDelta;
//      lastDelta = ballisticController.value;
//      extent.addPixelDelta(delta, context.notificationContext);
//      if ((velocity > 0 && extent.isAtMax) || (velocity < 0 && extent.isAtMin)) {
//        // Make sure we pass along enough velocity to keep scrolling - otherwise
//        // we just "bounce" off the top making it look like the list doesn't
//        // have more to scroll.
//        velocity = ballisticController.velocity + (physics.tolerance.velocity * ballisticController.velocity.sign);
//        super.goBallistic(velocity);
//        ballisticController.stop();
//      }
//    }
//
//    ballisticController
//      ..addListener(_tick)
//      ..animateWith(simulation).whenCompleteOrCancel(
//        ballisticController.dispose,
//      );
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    // Save this so we can call it later if we have to [goBallistic] on our own.
    _dragCancelCallback = dragCancelCallback;
    return super.drag(details, dragCancelCallback);
  }
}

/// A widget that can notify a descendent [DraggableScrollableSheet] that it
/// should reset its position to the initial state.
///
/// The [Scaffold] uses this widget to notify a persistentent bottom sheet that
/// the user has tapped back if the sheet has started to cover more of the body
/// than when at its initial position. This is important for users of assistive
/// technology, where dragging may be difficult to communicate.
class DraggableScrollableActuator extends StatelessWidget {
  /// Creates a widget that can notify descendent [DraggableScrollableSheet]s
  /// to reset to their initial position.
  ///
  /// The [child] parameter is required.
  DraggableScrollableActuator({Key key, @required this.child}) : super(key: key);

  /// This child's [DraggableScrollableSheet] descendant will be reset when the
  /// [reset] method is applied to a context that includes it.
  ///
  /// Must not be null.
  final Widget child;

  final _UpdatePositionStateNotifier _notifier = _UpdatePositionStateNotifier();

  /// Notifies any descendant [DraggableScrollableSheet] that it should reset
  /// to its initial position.
  ///
  /// Returns `true` if a [DraggableScrollableActuator] is available and
  /// some [DraggableScrollableSheet] is listening for updates, `false`
  /// otherwise.
  static bool reset(BuildContext context) {
    final _InheritedUpdatePositionStateNotifier notifier =
        context.dependOnInheritedWidgetOfExactType<_InheritedUpdatePositionStateNotifier>();
    if (notifier == null) {
      return false;
    }
    return notifier._sendReset();
  }

  static bool setMax(BuildContext context) {
    final _InheritedUpdatePositionStateNotifier notifier =
        context.dependOnInheritedWidgetOfExactType<_InheritedUpdatePositionStateNotifier>();
    if (notifier == null) {
      return false;
    }
    return notifier._sendMax();
  }

  static bool setMin(BuildContext context) {
    final _InheritedUpdatePositionStateNotifier notifier =
        context.dependOnInheritedWidgetOfExactType<_InheritedUpdatePositionStateNotifier>();
    if (notifier == null) {
      return false;
    }
    return notifier._sendMin();
  }

  static bool setAnchor(BuildContext context) {
    final _InheritedUpdatePositionStateNotifier notifier =
        context.dependOnInheritedWidgetOfExactType<_InheritedUpdatePositionStateNotifier>();
    if (notifier == null) {
      return false;
    }
    return notifier._sendAnchor();
  }

  static bool setHide(BuildContext context) {
    final _InheritedUpdatePositionStateNotifier notifier =
        context.dependOnInheritedWidgetOfExactType<_InheritedUpdatePositionStateNotifier>();
    if (notifier == null) {
      return false;
    }
    return notifier._sendHide();
  }

  static bool setStatus(BuildContext context, DraggableScrollableSheetState status) {
    switch (status) {
      case DraggableScrollableSheetState.ANCHOR_POINT:
        return setAnchor(context);
      case DraggableScrollableSheetState.EXPANDED:
        return setMax(context);
      case DraggableScrollableSheetState.COLLAPSED:
        return setMin(context);
      case DraggableScrollableSheetState.HIDDEN:
        return setHide(context);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedUpdatePositionStateNotifier(child: child, notifier: _notifier);
  }
}

/// A [ChangeNotifier] to use with [InheritedResetNotifer] to notify
/// descendants that they should update position state.
class _UpdatePositionStateNotifier extends ChangeNotifier {
  /// Whether someone called [sendReset] or not.
  ///
  /// This flag should be reset after checking it.
  bool _resetWasCalled = false;
  bool _maxWasCalled = false;
  bool _minWasCalled = false;
  bool _anchorWasCalled = false;
  bool _hideWasCalled = false;

  /// Fires a reset notification to descendants.
  ///
  /// Returns false if there are no listeners.
  bool sendReset() {
    if (!hasListeners) {
      return false;
    }
    setAllFalse();
    _resetWasCalled = true;
    notifyListeners();
    return true;
  }

  bool sendMax() {
    if (!hasListeners) {
      return false;
    }
    setAllFalse();
    _maxWasCalled = true;
    notifyListeners();
    return true;
  }

  bool sendMin() {
    if (!hasListeners) {
      return false;
    }
    setAllFalse();
    _minWasCalled = true;
    notifyListeners();
    return true;
  }

  bool sendAnchor() {
    if (!hasListeners) {
      return false;
    }
    setAllFalse();
    _anchorWasCalled = true;
    notifyListeners();
    return true;
  }

  bool sendHide() {
    if (!hasListeners) {
      return false;
    }
    setAllFalse();
    _hideWasCalled = true;
    notifyListeners();
    return true;
  }

  void setAllFalse() {
    _minWasCalled = false;
    _hideWasCalled = false;
    _anchorWasCalled = false;
    _maxWasCalled = false;
    _resetWasCalled = false;
  }
}

class _InheritedUpdatePositionStateNotifier extends InheritedNotifier<_UpdatePositionStateNotifier> {
  /// Creates an [InheritedNotifier] that the [DraggableScrollableSheet] will
  /// listen to for an indication that it should change its extent.
  ///
  /// The [child] and [notifier] properties must not be null.
  const _InheritedUpdatePositionStateNotifier({
    Key key,
    @required Widget child,
    @required _UpdatePositionStateNotifier notifier,
  }) : super(key: key, child: child, notifier: notifier);

  bool _sendReset() => notifier.sendReset();

  bool _sendMax() => notifier.sendMax();

  bool _sendMin() => notifier.sendMin();

  bool _sendAnchor() => notifier.sendAnchor();

  bool _sendHide() => notifier.sendHide();

  /// Specifies whether the [DraggableScrollableSheet] should reset to its
  /// initial position.
  ///
  /// Returns true if the notifier requested a reset, false otherwise.
  static bool shouldReset(BuildContext context) {
    final InheritedWidget widget = context.inheritFromWidgetOfExactType(_InheritedUpdatePositionStateNotifier);
    if (widget == null) {
      return false;
    }
    assert(widget is _InheritedUpdatePositionStateNotifier);
    final _InheritedUpdatePositionStateNotifier inheritedNotifier = widget;
    final bool wasCalled = inheritedNotifier.notifier._resetWasCalled;
    inheritedNotifier.notifier._resetWasCalled = false;
    return wasCalled;
  }

  static bool shouldSetMax(BuildContext context) {
    final InheritedWidget widget = context.inheritFromWidgetOfExactType(_InheritedUpdatePositionStateNotifier);
    if (widget == null) {
      return false;
    }
    assert(widget is _InheritedUpdatePositionStateNotifier);
    final _InheritedUpdatePositionStateNotifier inheritedNotifier = widget;
    final bool wasCalled = inheritedNotifier.notifier._maxWasCalled;
    inheritedNotifier.notifier._maxWasCalled = false;
    return wasCalled;
  }

  static bool shouldSetMin(BuildContext context) {
    final InheritedWidget widget = context.inheritFromWidgetOfExactType(_InheritedUpdatePositionStateNotifier);
    if (widget == null) {
      return false;
    }
    assert(widget is _InheritedUpdatePositionStateNotifier);
    final _InheritedUpdatePositionStateNotifier inheritedNotifier = widget;
    final bool wasCalled = inheritedNotifier.notifier._minWasCalled;
    inheritedNotifier.notifier._minWasCalled = false;
    return wasCalled;
  }

  static bool shouldSetAnchor(BuildContext context) {
    final InheritedWidget widget = context.inheritFromWidgetOfExactType(_InheritedUpdatePositionStateNotifier);
    if (widget == null) {
      return false;
    }
    assert(widget is _InheritedUpdatePositionStateNotifier);
    final _InheritedUpdatePositionStateNotifier inheritedNotifier = widget;
    final bool wasCalled = inheritedNotifier.notifier._anchorWasCalled;
    inheritedNotifier.notifier._anchorWasCalled = false;
    return wasCalled;
  }

  static bool shouldHide(BuildContext context) {
    final InheritedWidget widget = context.inheritFromWidgetOfExactType(_InheritedUpdatePositionStateNotifier);
    if (widget == null) {
      return false;
    }
    assert(widget is _InheritedUpdatePositionStateNotifier);
    final _InheritedUpdatePositionStateNotifier inheritedNotifier = widget;
    final bool wasCalled = inheritedNotifier.notifier._hideWasCalled;
    inheritedNotifier.notifier._hideWasCalled = false;
    return wasCalled;
  }
}
