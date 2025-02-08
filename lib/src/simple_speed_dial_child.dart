import 'package:flutter/widgets.dart';

class SpeedDialChild { // SpeedDial에 띄워지는 버튼들에 대한 class
  const SpeedDialChild({
    required this.child,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor,
    this.label,
    this.closeSpeedDialOnPressed = true,
  });
  
  final Widget child;
  // [SpeedDialchild]로 배치할 위젯

  final Function onPressed;
  // [SpeedDialChild]을 누를 때 실행할 콜백
  
  final Color? foregroundColor;
  // [SpeedDialChild] 버튼 맨 앞 아이콘 색
  
  final Color? backgroundColor;
  // [SpeedDialChild] 버튼 배경색

  final String? label;
  // 플로팅 액션 버튼을 눌렀을 때, 각 버튼 옆에 표시되는 텍스트

  final bool closeSpeedDialOnPressed;
  // [onPressed] 콜백 후 [SpeedDial]을 닫을 것인지
  // [SpeedDialChild]가 호출됨
  // 기본값 [true]
}