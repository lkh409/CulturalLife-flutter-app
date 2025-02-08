import 'package:flutter/material.dart';

import 'simple_speed_dial_child.dart';


class SpeedDial extends StatefulWidget { // SpeedDial의 전체적인 제어를 맡는 class SpeedDial
  const SpeedDial({
    Key? key,
    required this.child,
    required this.speedDialChildren,
    this.labelsStyle,
    this.labelsBackgroundColor,
    this.controller,
    this.closedForegroundColor,
    this.openForegroundColor,
    this.closedBackgroundColor,
    this.openBackgroundColor,
  }) : super(key: key);

  final Widget child;

  final List<SpeedDialChild> speedDialChildren;
  // SpeedDial이 열려 있을 때 표시할 [SpeedDialChild]의 목록

  final TextStyle? labelsStyle;
  // [SpeedDialChild] label(옆에 떠있는 네모 창) 텍스트 스타일 지정

  final Color? labelsBackgroundColor;
  // label 배경 색

  final AnimationController? controller;
  // [SpeedDial] 위젯의 애니메이션 컨트롤러
  // 애니메이션을 제어하기 위해 [SpeedDial] 밖에서 [AnimationController] 사용

  final Color? closedForegroundColor;
  // 닫혔을 때 앞부분에 표시되는 [SpeedDial] 버튼 아이콘의 색상

  final Color? openForegroundColor;
  // 열었을 때 앞부분에 표시되는 [SpeedDial] 버튼 아이콘의 색상
  
  final Color? closedBackgroundColor;
  // 닫혔을 때 앞부분에 표시되는 [SpeedDial] 버튼 배경의 색상
  
  final Color? openBackgroundColor;
  // 열었을 때 앞부분에 표시되는 [SpeedDial] 버튼 배경의 색상

  @override
  State<StatefulWidget> createState() {
    return _SpeedDialState();
  }
}

class _SpeedDialState extends State<SpeedDial> //Speed
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<Color?> _foregroundColorAnimation;
  final List<Animation<double>> _speedDialChildAnimations =
  <Animation<double>>[];

  @override
  void initState() {
    _animationController = widget.controller ??
        AnimationController(
            vsync: this, duration: const Duration(milliseconds: 450)); // AnimationController 정의(450 밀리초동안 애니메이션 구현)
    _animationController.addListener(() { // addListener로 콜백 함수 실행
      if (mounted) {
        setState(() {});
      }
    });

    _backgroundColorAnimation = ColorTween(
      begin: widget.closedBackgroundColor,
      end: widget.openBackgroundColor,
    ).animate(_animationController); // 배경 색 전환 (열고, 닫을 때)

    _foregroundColorAnimation = ColorTween(
      begin: widget.closedForegroundColor,
      end: widget.openForegroundColor,
    ).animate(_animationController); // 아이콘 색 전환 (열고, 닫을 때)

    final double fractionOfOneSpeedDialChild =
        1.0 / widget.speedDialChildren.length;
    for (int speedDialChildIndex = 0;
    speedDialChildIndex < widget.speedDialChildren.length;
    ++speedDialChildIndex) {
      final List<TweenSequenceItem<double>> tweenSequenceItems =
      <TweenSequenceItem<double>>[];

      final double firstWeight =
          fractionOfOneSpeedDialChild * speedDialChildIndex;
      if (firstWeight > 0.0) {
        tweenSequenceItems.add(TweenSequenceItem<double>(
          tween: ConstantTween<double>(0.0),
          weight: firstWeight,
        ));
      }

      tweenSequenceItems.add(TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: fractionOfOneSpeedDialChild,
      ));

      final double lastWeight = fractionOfOneSpeedDialChild *
          (widget.speedDialChildren.length - 1 - speedDialChildIndex);
      if (lastWeight > 0.0) {
        tweenSequenceItems.add(TweenSequenceItem<double>(
            tween: ConstantTween<double>(1.0), weight: lastWeight));
      }

      _speedDialChildAnimations.insert(
          0,
          TweenSequence<double>(tweenSequenceItems)
              .animate(_animationController));
    }

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int speedDialChildAnimationIndex = 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (!_animationController.isDismissed)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.speedDialChildren
                  .map<Widget>((SpeedDialChild speedDialChild) {
                final Widget speedDialChildWidget = Opacity(
                  opacity:
                  _speedDialChildAnimations[speedDialChildAnimationIndex]
                      .value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      if (speedDialChild.label != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0 - 4.0),
                          child: Card(
                            elevation: 6.0,
                            color: widget.labelsBackgroundColor ?? Colors.white,
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: InkWell(
                              onTap: () => _onTap(speedDialChild),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Text(
                                  speedDialChild.label!,
                                  style: widget.labelsStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ScaleTransition(
                        scale: _speedDialChildAnimations[
                        speedDialChildAnimationIndex],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: FloatingActionButton(
                            heroTag: speedDialChildAnimationIndex,
                            mini: true,
                            child: speedDialChild.child,
                            foregroundColor: speedDialChild.foregroundColor,
                            backgroundColor: speedDialChild.backgroundColor,
                            onPressed: () => _onTap(speedDialChild),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                speedDialChildAnimationIndex++;
                return speedDialChildWidget;
              }).toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: FloatingActionButton(
            child: widget.child,
            foregroundColor: _foregroundColorAnimation.value,
            backgroundColor: _backgroundColorAnimation.value,
            onPressed: () {
              if (_animationController.isDismissed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
          ),
        )
      ],
    );
  }

  void _onTap(SpeedDialChild speedDialChild) {
    if (speedDialChild.closeSpeedDialOnPressed) {
      _animationController.reverse();
    }
    speedDialChild.onPressed.call();
  }
}