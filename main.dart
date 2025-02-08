import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:timelines/timelines.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:get/get.dart';

import 'dart:async';
import 'dart:io';

import './SecondPage.dart';
import './ThirdPage.dart';
import './dataClass/memo.dart';


void main() => runApp(MyApp());


class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // '검색'에서 '작성'으로 데이터를 받아오기 위한 Get을 쓰기 위해 MaterialApp 대신 GetMaterialApp 사용
      debugShowCheckedModeBanner: false, // 플러터 디버그 배너 없애기
      title: 'Main Page',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MainHomePage(title: 'My Timelines'),
    );
  }
}// 메인 앱 MyApp


class MainHomePage extends StatefulWidget {

  const MainHomePage({Key? key, required this.title}) : super(key: key); // 페이지 간 데이터 주고받기 위한 코드
  final String title;
  @override
  _MainHomePageState createState() => _MainHomePageState();
}// 메인 화면


class _MainHomePageState extends State<MainHomePage> {
  List memoData = new List.empty(growable: true); // json 파일의 데이터를 List로 변환
  List<Memo> memoDataList = new List.empty(growable: true);// 변환된 list를 Memo 형식으로 저장할 List<Memo>

  Future<void> readJson() async {
    var response = await DefaultAssetBundle.of(context).loadString('repo/memory/myData.json');
    // 사용자의 기록 json 데이터. 원래는 이 json 데이터를 계속 수정하고 저장할 수 있도록 만들 의도였지만, 파일 경로 문제로 그냥 앱을 실행시킬 당시에만 데이터를 저장하도록 함.

     setState(() {
       memoData = jsonDecode(response);
       for(int i = 0; i < memoData.length; i++){
         memoDataList.add(Memo(title: memoData[i]['title'], //제목
             date: memoData[i]['date'], //날짜
             place: memoData[i]['place'], //장소
             who: memoData[i]['who'], //같이 간 사람
             genre: memoData[i]['genre'], //장르
             rate: double.parse(memoData[i]['rate']), //평점
             content: memoData[i]['content'], //내용
             imagePath: memoData[i]['imagePath'])); //이미지
       } // 변환된 memoData를 memoDataList에 저장
       memoDataList.sort((a, b) => a.date!.compareTo(b.date!)); // 날짜 순으로 재정렬
     });
  }

  bool value = false;
  void changeData(){
    setState(() {
      value = true;
    });
  }// 페이지 새로고침 함수

  String _text = ''; // SpeedDial 라벨 텍스트

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text(widget.title),),
        ),
        floatingActionButton: SpeedDial( // floatingActionButton을 누르면 세로로 아이콘들이 뜨고, 그 옆에 라벨이 달림
          child: Image.asset('repo/images/고양이.png'), //고양이 이미지의 플로팅 액션 버튼
          speedDialChildren: <SpeedDialChild>[
            SpeedDialChild( // floatingActionButton을 눌렀을 때 띄워지는 버튼 '새로작성'
              child: const Icon(Icons.add), // 아이콘
              foregroundColor: Colors.white, // 아이콘 색
              backgroundColor: Colors.red, // 배경 색
              label: '새로작성', // 버튼 옆에 뜨는 라벨 텍스트
              onPressed: () async {
                String refresh = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WriteSpace(list: memoDataList)
                    )); // 누르면 WriteSpace(SecondPage)로 페이지 전환과 함께 memoDataList 리스트 전달
                if(refresh == 'refresh'){
                  changeData();
                } // 만약 자신 위로 pop한 페이지가 'refresh'를 전달하면 페이지 새로고침
                setState(() {
                  _text = 'click " 하면\ 새로작성"';
                }); // _text 바꿔서 이동한 페이지가 어떤 것인지 저장
              },
            ),
            SpeedDialChild( // floatingActionButton을 눌렀을 때 띄워지는 버튼 '검색'
              child: const Icon(Icons.search), // 아이콘
              foregroundColor: Colors.black, // 아이콘 색
              backgroundColor: Colors.yellow, // 배경 색
              label: '검색', // 버튼 옆에 뜨는 라벨 텍스트
              onPressed: () async{
                String refresh = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HttpApp(list: memoDataList)//리스트 전달
                    )); // 누르면 HttpApp(ThirdPage)로 페이지 전환과 함께 memoDataList 리스트 전달
                if(refresh == 'refresh'){
                  changeData();
                } // 만약 자신 위로 pop한 페이지가 'refresh'를 전달하면 페이지 새로고침
                setState(() {
                  _text = 'click " 하면\ 검색"';
                }); // _text 바꿔서 이동한 페이지가 어떤 것인지 저장
              },
            ),
          ],
        ),
        body: SingleChildScrollView( // 페이지 세로로 스크롤할 수 있도록 SingleChildScrollView
            child: FixedTimeline.tileBuilder( // 타임라인 생성
              builder: TimelineTileBuilder.connectedFromStyle(
                contentsAlign: ContentsAlign.alternating, // 교차로 타임라인 항목 띄움

                oppositeContentsBuilder: (context, index) =>
                    Padding( // 항목 들어가는 Padding
                      padding: const EdgeInsets.all(15.0), //내부에 15 여백
                      child: Column(
                          children: <Widget>[
                            InkWell( // 각 타임라인 항목을 누를 수 있도록 함
                              onTap: () {
                                AlertDialog dialog = AlertDialog( // 누를 때 상세 내용을 볼 수 있도록 팝업 띄움
                                  content: SingleChildScrollView( // 팝업 스크롤 가능하도록 함
                                  child : Column(
                                    mainAxisSize: MainAxisSize.min, // 크기를 Column의 하위 자식들의 모든 사이즈만 더한 값으로 함 (내용이 길어지면 늘어남)
                                    children: <Widget>[
                                      Text(memoDataList[index].date!, // 날짜
                                        style: TextStyle(fontSize: 13),),
                                      SizedBox(height: 5.0,), // sizedbox로 간격 주기

                                      Text(memoDataList[index].title!, // 제목
                                          style: TextStyle(fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2),textAlign: TextAlign.center), //폰트 두껍게, 자간 2
                                      SizedBox(height: 20.0,),//sizedbox로 제목 텍스트와 이미지 사이 세로 여백을 만들어줌

                                      Column(
                                        children: <Widget>[ // 이미지. 내부 repo 폴더에 있는 것, 갤러리에서 가져온 것으로 구분 / 이미지가 없으면 repo의 noPhotos.png 불러움
                                          if(memoDataList[index].imagePath!.contains("repo/images") == true) Image.asset(memoDataList[index].imagePath!)
                                          else if(memoDataList[index].imagePath!.contains("/data") == true) Image.file(File(memoDataList[index].imagePath!,))
                                          else Image.asset('repo/images/noPhotos.png'),
                                          SizedBox(height: 5.0,), // sizedbox로 간격 주기

                                          RatingBar( // 평점 바
                                            ignoreGestures: true, // 여기서는 표시만 하는 것이므로 사용자가 조작할 수 없게 함
                                            initialRating: memoDataList[index].rate!, // 평점
                                            direction: Axis.horizontal, // 가로로 늘어남
                                            allowHalfRating: true, // 0.5점 가능
                                            itemCount: 5, // 평점 바 아이콘 개수
                                            ratingWidget: RatingWidget( // 평점 바 아이콘 설정 (다 찼을 때, 반만 찼을 때, 비었을 때)
                                              full: const Icon( // 다 찼을 때
                                                Icons.star, color: Colors.amber,),
                                              half: const Icon(Icons.star_half, // 반만 찼을 때
                                                color: Colors.amber,),
                                              empty: const Icon(Icons.star_outline, // 비었을 때
                                                color: Colors.amber,),
                                            ),
                                            onRatingUpdate: (rating) { // 평점 표시
                                              print(rating);
                                            },
                                          ),
                                          SizedBox(height: 5.0,), // sizedbox로 간격 주기

                                          Row( // 장소
                                            mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                                            children: <Widget>[
                                              Image.asset('repo/images/placeholder.png',width: 14, height: 14,), // 장소 아이콘 이미지
                                              Text(' 장소 : ',
                                                  style: TextStyle(fontSize: 14)),
                                              Text(memoDataList[index].place!!,
                                                  style: TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                          SizedBox(height: 5.0,), // sizedbox로 간격 주기

                                          Row( // 같이 간 사람
                                            mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                                            children: <Widget>[
                                              Image.asset('repo/images/people.png', width: 14, height: 14,), // 사람 아이콘 이미지
                                              Text(' 같이 간 사람 : ',
                                                  style: TextStyle(fontSize: 14)),
                                              Text(memoDataList[index].who!,
                                                  style: TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                          SizedBox(height: 5.0,), // sizedbox로 간격 주기
                                          
                                          Text(memoDataList[index].content!, // 내용
                                            style: TextStyle(fontSize: 14),),

                                          IconButton( // 삭제 버튼
                                            icon: Icon(Icons.delete_rounded, color: Colors.grey,),
                                            onPressed: () {
                                              setState((){
                                                memoDataList.removeAt(index); // 누르면  데이터 삭제
                                              });
                                              Navigator.pop(context); // 팝업 닫기
                                            },
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  )
                                );
                                showDialog(context: context, builder: (BuildContext context) => dialog); // 팝업 띄우기
                              },
                              //====================================== 여기까지 팝업 / 아래는 타임라인 항목 ==========================================//
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                                    children: <Widget>[ // 각 항목 옆에 뜨는 아이콘 (영화, 뮤지컬, 축제, 기타)
                                      if(memoDataList[index].genre! == 'movie') Image.asset('repo/images/movie.png', width: 22, height: 22,)
                                      else if(memoDataList[index].genre! == 'musical') Image.asset('repo/images/musical.png', width: 22, height: 22,)
                                      else if(memoDataList[index].genre! == 'festival') Image.asset('repo/images/festival.png', width: 22, height: 22,)
                                      else Image.asset('repo/images/heart.png', width: 20, height: 20,),
                                      Container(width: 10,), // Container로 간격 주기

                                      Column(
                                        children: <Widget>[
                                          Text(memoDataList[index].date!, style: TextStyle(fontSize: 15),), // 날짜
                                          Container( // 제목
                                            constraints: BoxConstraints( // 제목이 일정 크기를 넘어가지 않도록 크기 지정
                                              maxWidth: 100,
                                              maxHeight: 300,
                                            ),
                                            child: Text(memoDataList[index].title!, // 제목
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              textAlign: TextAlign.center,),
                                          ),
                                          RatingBar( // 평점
                                            ignoreGestures: true,
                                            initialRating: memoDataList[index].rate!,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 20, // 평점 바 크기 지정
                                            itemPadding: EdgeInsets.symmetric(horizontal: 0.0), // 세로 크기 설정
                                            ratingWidget: RatingWidget(
                                              full: const Icon(
                                                Icons.star, color: Colors.amber,),
                                              half: const Icon(Icons.star_half,
                                                color: Colors.amber,),
                                              empty: const Icon(Icons.star_outline,
                                                color: Colors.amber,),
                                            ),
                                            onRatingUpdate: (rating) {
                                              print(rating);
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                              //Text('opposite\ncontents'),
                            ),
                          ]
                      ),
                    ),

                connectorStyleBuilder: (context, index) => ConnectorStyle.solidLine, // 타임라인 잇는 줄 스타일 지정
                indicatorStyleBuilder: (context, index) => IndicatorStyle.dot, // 타임라인 항목 점 스타일 지정
                itemCount: memoDataList.length, // 타임라인 길이
              ),
            )
        ),
    );
  }

  @override
  void initState() { //초기화
    super.initState();
    readJson(); // 처음에 /repo/memory/myData.json 읽음
  }
}


