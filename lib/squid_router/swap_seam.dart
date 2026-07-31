import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Two stacked cards with a control centred on the SEAM between them.
///
/// The seam is a computed position, not an assumption: it is the first child's
/// laid-out height plus half of [gap]. The obvious alternative - a
/// `Stack(alignment: Alignment.center)` wrapping a `Column` of both cards - is
/// centred on the BOUNDING BOX of the pair, which is a different point as soon
/// as the two cards differ in height. The Stack's centre is
/// `(payH + gap + receiveH) / 2` and the seam is `payH + gap / 2`, so the
/// control drifts by `(receiveH - payH) / 2`, exactly half the difference. That
/// was the swap screen's bug: selecting a pay token grows the pay card and the
/// control slid upward off the seam.
///
/// This widget knows nothing about swapping. It takes three opaque children, so
/// its geometry can be driven by plain sized boxes in a test.
///
/// It is a hand-written [RenderBox] rather than a `CustomMultiChildLayout`
/// because that widget cannot size itself from its children:
/// `RenderCustomMultiChildLayoutBox.performLayout` calls
/// `delegate.getSize(constraints)` BEFORE laying any child out, and the default
/// is `constraints.biggest`. This layout lives inside a `SingleChildScrollView`
/// where the incoming height constraint is infinite, so `getSize` would have to
/// return a hardcoded height - the exact magic number this widget exists to
/// avoid. `Flow` has the same limitation.
class SwapSeam extends MultiChildRenderObjectWidget {
  SwapSeam({
    super.key,
    required this.gap,
    required Widget payCard,
    required Widget receiveCard,
    required Widget control,
  }) : super(children: [payCard, receiveCard, control]);

  /// The vertical space between the two cards. The control's centre lands at
  /// half of it, measured from the first card's bottom edge.
  final double gap;

  @override
  RenderSwapSeam createRenderObject(BuildContext context) =>
      RenderSwapSeam(gap: gap);

  @override
  void updateRenderObject(BuildContext context, RenderSwapSeam renderObject) {
    renderObject.gap = gap;
  }
}

class _SeamParentData extends ContainerBoxParentData<RenderBox> {}

/// The layout behind [SwapSeam]. Exactly three children, in order: the first
/// card, the second card, the control.
class RenderSwapSeam extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _SeamParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _SeamParentData> {
  RenderSwapSeam({required double gap}) : _gap = gap;

  double get gap => _gap;
  double _gap;
  set gap(double value) {
    if (_gap == value) {
      return;
    }
    _gap = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SeamParentData) {
      child.parentData = _SeamParentData();
    }
  }

  // ponytail: no dry layout. Ceiling: this box must not be placed under a
  // parent that asks for one - `IntrinsicHeight` and friends will throw rather
  // than mis-measure, which is the failure mode worth having. Upgrade path: lay
  // the two cards out with `ChildLayoutHelper.dryLayoutChild` and return the
  // same `payH + gap + receiveH` sum.
  @override
  void performLayout() {
    assert(
      childCount == 3,
      'SwapSeam takes exactly three children: two cards and a control.',
    );
    assert(
      constraints.hasBoundedWidth,
      'SwapSeam sizes its cards to the incoming width, which must be bounded.',
    );

    final double width = constraints.maxWidth;
    final BoxConstraints cardConstraints = BoxConstraints.tightFor(
      width: width,
    );

    final RenderBox payCard = firstChild!;
    final RenderBox receiveCard = childAfter(payCard)!;
    final RenderBox control = childAfter(receiveCard)!;

    payCard.layout(cardConstraints, parentUsesSize: true);
    receiveCard.layout(cardConstraints, parentUsesSize: true);
    // Unconstrained on purpose: the control chooses its own size (44x44 today)
    // and nothing here may hand it one.
    control.layout(const BoxConstraints(), parentUsesSize: true);

    final double payHeight = payCard.size.height;
    _dataOf(payCard).offset = Offset.zero;
    _dataOf(receiveCard).offset = Offset(0, payHeight + gap);

    final double seam = payHeight + gap / 2;
    _dataOf(control).offset = Offset(
      (width - control.size.width) / 2,
      seam - control.size.height / 2,
    );

    size = constraints.constrain(
      Size(width, payHeight + gap + receiveCard.size.height),
    );
  }

  _SeamParentData _dataOf(RenderBox child) =>
      child.parentData! as _SeamParentData;

  // Both overrides below are load-bearing, and both restore a property the
  // `Stack` this replaced gave for free.
  //
  // `defaultPaint` draws first child to last, so the control - the LAST child -
  // lands on top of both cards. Without it the control would be painted under
  // the cards it overlaps by 14px on each side and its border would be clipped
  // out of existence.
  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  // `defaultHitTestChildren` walks from `lastChild` backwards, so the control
  // is offered the tap BEFORE either card. Without it the pay card's TextField
  // would swallow taps in the top half of the control, which is a 44px target
  // reduced to about 22 with nothing on screen to say so.
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
