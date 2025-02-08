import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml2json/xml2json.dart';
import 'package:xml/xml.dart';

import 'package:get/get.dart';

import './dataClass/memo.dart';
import './SecondPage_get.dart';

class HttpApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState()=> _HttpApp();

  final List<Memo>? list; // 공유된 리스트 받을 list

  HttpApp({Key? key, @required this.list}) : super(key: key); // 페이지 간 데이터 주고받기 위한 코드
}

class _HttpApp extends State<HttpApp> {
  String result = ''; // 검색어 저장
  List? data1; // 영화 데이터 리스트로 저장
  List? data2; // 축제 데이터 리스트로 저장
  List? data3; // 뮤지컬 데이터 리스트로 저장
  TextEditingController? _editingController;
  int page1 = 1; // 영화 페이지
  int page2 = 1; // 축제 페이지
  int page3 = 1; // 뮤지컬 페이지
  ScrollController? _scrollController1; // 영화 스크롤 컨트롤러
  ScrollController? _scrollController2; // 축제 스크롤 컨트롤러
  ScrollController? _scrollController3; // 뮤지컬 스크롤 컨트롤러

  int sendGenre = 0; // WriteSpace_get에 보낼 장르 데이터
  String sendTitle = ''; // WriteSpace_get에 보낼 제목 데이터
  String sendPlace = ''; // WriteSpace_get에 보낼 장소 데이터

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: AppBar(
            backgroundColor: Colors.indigo, // 테마 색깔
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 검색창이랑 검색버튼 사이 간격 주는 설정
              children: [
                Container(
                  child: TextField(
                    controller: _editingController,
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(  // 검색창 꾸미는 위젯
                        enabledBorder: OutlineInputBorder( // 검색창 테두리 설정
                            borderRadius: BorderRadius.all(Radius.circular(5)), // 검색창 모서리 곡률 설정
                            borderSide: BorderSide(
                                color: Colors.blueGrey // 검색창 테두리 색깔 설정
                            )
                        ),
                        filled: true,
                        fillColor: Colors.white70, // 검색창 배경색
                        hintText: '문화 정보 검색하기'),
                  ),
                  width: 250,
                  height: 45,
                ),
                SizedBox( // 검색 버튼 사이즈 설정
                    width: 45,
                    height: 45,
                    child: FloatingActionButton( // 검색 버튼
                        backgroundColor: Colors.indigoAccent, // 검색 버튼 색깔
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3)), // 검색 버튼 모서리 곡률
                        ),
                        onPressed: () {
                          page1 =1; // 영화 페이지
                          page2 =1; // 축제 페이지
                          page3 =1; // 뮤지컬 페이지
                          data1!.clear(); // 기존 영화 내용 지움
                          data2!.clear(); // 기존 축제 내용 지움
                          data3!.clear(); // 기존 뮤지컬 내용 지움
                          getJSONData1(); // 영화 데이터 불러오기
                          getJSONData2(); // 축제 데이터 불러오기
                          getJSONData3(); // 뮤지컬 데이터 불러오기
                        },
                        child: Icon(Icons.search) // 검색 버튼 안 아이콘 그림
                    )
                )
              ],
            ),
          leading:  IconButton(
              onPressed: () {
                Navigator.pop(context, 'refresh'); // appBar의 뒤로가기 버튼 누르면 이전 페이지로 pop
              },
              color: Colors.white,
              icon: Icon(Icons.arrow_back)),
        ),

        //---------- 영화 리스트 --------------------

        body: SingleChildScrollView( // 검색창 눌렀을 때 화면이 밀려서 overflow 오류 뜨지 않도록 하는 용도
          child: Column(
                children: <Widget>[
                  Container( // 영화 텍스트 부분 공간
                    child: Text('영화', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.all(10.0), // 텍스트랑 카드 간에 간격 살짝 띄워줌
                    width: 370, // 텍스트 왼쪽 정렬 하고싶어서 컨테이너 넓이를 넓힘
                  ),
                  Container(  // 영화 정보 리스트 공간
                    height: 130,
                    child: Center(
                      child: data1!.length == 0
                          ? Text('영화 정보가 존재하지 않습니다.', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)
                          : ListView.builder(
                        scrollDirection: Axis.horizontal, // 가로로 스크롤 되도록 설정
                        itemBuilder: (context, index) {
                          return ElevatedButton(
                            onPressed: (){
                              showDialog(
                                  context: context,
                                  barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: SingleChildScrollView(
                                      child: Container(
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Image.network( // 포스터
                                                    'https://image.tmdb.org/t/p/original'
                                                        '${data1![index]['poster_path']}',
                                                    height: 200,
                                                    width: 200,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        child: Icon(Icons.image_not_supported_outlined, color: Colors.blueGrey,size: 50,),
                                                      );
                                                    }
                                                ),
                                                
                                                Column(
                                                  children: <Widget>[
                                                    Container( // 제목
                                                      width: MediaQuery.of(context).size.width - 250,
                                                      child: Text(
                                                        data1![index]['title'].toString(),
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontSize: 25),
                                                      ),
                                                    ),
                                                    
                                                    Text('개봉일 : ${data1![index]['release_date'].toString()}', textAlign: TextAlign.start,), // 개봉일
                                                    Text('평점 : ${data1![index]['vote_average'].toString()}', textAlign: TextAlign.start), // 평점
                                              ],
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                            ),
                                              ],
                                              mainAxisAlignment: MainAxisAlignment.start,
                                            ),
                                            Container(
                                              height: 20,
                                            ),
                                            Container(
                                              width: 320,
                                              height: 400,
                                              child: Text('${data1![index]['overview'].toString()}'), // 개요
                                            )
                                          ],
                                          mainAxisAlignment: MainAxisAlignment.start,
                                        ),
                                      )),
                                      insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                                      actions: <Widget>[
                                        TextButton( // 팝업창 정보 WriteSpace_get으로 넘김
                                            child: const Text('선택'),
                                            onPressed: () async {
                                              sendGenre = 0; // 장르값 0(영화)
                                              sendTitle = data1![index]['title'].toString(); // 영화 제목
                                              Navigator.of(context).pop();//창닫기
                                              Get.to(() => WriteSpace_get(list: widget.list), arguments : {'genre' : sendGenre ,'title' : sendTitle}); // 행사 종류, 영화제목 보냄
                                            },),
                                        TextButton( // 팝업창 닫기
                                            child: const Text('확인'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },),
                                      ],
                                    );
                                  }
                              );
                            },
                            child: Card(
                              child: Container(
                                child: Row(
                                  children: <Widget>[
                                    Image.network( // 포스터
                                      'https://image.tmdb.org/t/p/original'
                                        '${data1![index]['poster_path']}',
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            child: Icon(Icons.image_not_supported_outlined, color: Colors.blueGrey,size: 50,),
                                          );
                                        }
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Container( // 영화 제목
                                          width: MediaQuery.of(context).size.width - 250,
                                          child: Text(
                                            data1![index]['title'].toString(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Text('개봉일 : ${data1![index]['release_date'].toString()}'), // 개봉일
                                        Text('평점 : ${data1![index]['vote_average'].toString()}') // 평점
                                      ],
                                      mainAxisAlignment: MainAxisAlignment.center,
                                    )
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                              ),
                            ),
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)), // 버튼 색 지정
                          );
                        },
                        itemCount: data1!.length, //데이터 개수만큼 영화 리스트 띄움
                        controller: _scrollController1,
                      ),
                    ),
                  ),



                  //------------------축제 리스트----------------------------------

                  Container( // 축제 텍스트 부분 공간
                    child: Text('축제', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.all(10.0), // 텍스트랑 카드 간에 간격 살짝 띄워줌
                    width: 370, // 텍스트 왼쪽 정렬 하고싶어서 컨테이너 넓이를 넓힘
                  ),
                  Container(  // 축제 정보 리스트 공간
                    height: 130,
                    child: Center(
                      child: data2!.length == 0
                          ? Text('축제 정보가 존재하지 않습니다.', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)
                          : ListView.builder(
                        scrollDirection: Axis.horizontal, // 가로로 스크롤 되도록 설정
                        itemBuilder: (context, index) {
                          return ElevatedButton( // 카드를 눌렀을 때 상세정보 뜨는 곳
                            onPressed: (){
                              showDialog(
                                  context: context,
                                  barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: SingleChildScrollView(
                                          child: Container(
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Image.network( // 포스터
                                                        data2![index]['poster']['\$t'],
                                                        height: 200,
                                                        width: 180,
                                                        fit: BoxFit.contain,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Container(
                                                            child: Icon(Icons.image_not_supported_outlined, color: Colors.blueGrey,size: 50,),
                                                          );
                                                        }
                                                    ),
                                                    Column(
                                                      children: <Widget>[
                                                        Container(
                                                          width: MediaQuery.of(context).size.width - 240,
                                                          child: Column(
                                                            children: <Widget>[
                                                              Text( // 제목
                                                                data2![index]['prfnm']['\$t'].toString(),
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(fontSize: 25),
                                                              ),
                                                              Text('개봉일 : ${data2![index]['prfpdfrom']['\$t'].toString()}'), // 개봉일
                                                              Text('장소 : ${data2![index]['fcltynm']['\$t'].toString()}') // 장소
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                    ),
                                                  ],
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                ),
                                              ],
                                              mainAxisAlignment: MainAxisAlignment.start,
                                            ),
                                          )),
                                      insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                                      actions: [
                                        TextButton( // 팝업창 정보 WriteSpace_get으로 넘김
                                          child: const Text('선택'),
                                          onPressed: () async {
                                            sendGenre = 2; // 장르값 2(축제)
                                            sendTitle = data2![index]['prfnm']['\$t'].toString(); // 축제 제목
                                            sendPlace = data2![index]['fcltynm']['\$t'].toString(); // 축제 장소
                                            Navigator.of(context).pop();//창닫기
                                            Get.to(() => WriteSpace_get(list: widget.list), arguments : {'genre' : sendGenre ,'title' : sendTitle, 'place' : sendPlace}); // 행사 종류, 축제 제목, 축제 장소 보냄
                                          },),
                                        TextButton( // 팝업창 닫기
                                          child: const Text('확인'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  }
                              );
                            },
                            child: Card(
                              child: Container(
                                child: Row(
                                  children: <Widget>[
                                    Image.network( // 포스터
                                        data2![index]['poster']['\$t'],
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            child: Icon(Icons.image_not_supported_outlined, color: Colors.blueGrey,size: 50,),
                                          );
                                        }
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context).size.width - 250,
                                          child: Text( // 축제 제목
                                            data2![index]['prfnm']['\$t'].toString(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Text('개봉일 : ${data2![index]['prfpdfrom']['\$t'].toString()}'), // 개봉일
                                        Text('장소 : ${data2![index]['fcltynm']['\$t'].toString()}') // 평점
                                      ],
                                      mainAxisAlignment: MainAxisAlignment.center,
                                    )
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                              ),
                            ),
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                          );
                        },
                        itemCount: data2!.length, //데이터 개수만큼 축제 리스트 띄움
                        controller: _scrollController2,
                      ),
                    ),
                  ),



                  //--------------------뮤지컬--------------------------------

                  Container( // 뮤지컬 텍스트 부분 공간
                    child: Text('뮤지컬', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.all(10.0), // 텍스트랑 카드 간에 간격 살짝 띄워줌
                    width: 370, // 텍스트 왼쪽 정렬 하고싶어서 컨테이너 넓이를 넓힘
                  ),
                  Container(  // 뮤지컬 정보 리스트 공간
                    height: 130,
                    child: Center(
                      child: data3!.length == 0
                          ? Text('뮤지컬 정보가 존재하지 않습니다.', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)
                          : ListView.builder(
                        scrollDirection: Axis.horizontal, // 가로로 스크롤 되도록 설정
                        itemBuilder: (context, index) {
                          return ElevatedButton(
                            onPressed: (){
                              showDialog(
                                  context: context,
                                  barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: SingleChildScrollView(
                                          child: Container(
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Image.network( // 포스터
                                                        data3![index]['poster']['\$t'],
                                                        height: 200,
                                                        width: 180,
                                                        fit: BoxFit.contain,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Container(
                                                            child: Icon(Icons.image_not_supported_outlined, color: Colors.blueGrey,size: 50,),
                                                          );
                                                        }
                                                    ),
                                                    Column(
                                                      children: <Widget>[
                                                        Container(
                                                          width: MediaQuery.of(context).size.width - 240,
                                                          child: Column(
                                                            children: <Widget>[
                                                              Text( // 제목
                                                                data3![index]['prfnm']["\$t"].toString(),
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(fontSize: 25),
                                                              ),
                                                              Text('개봉일 : ${data3![index]['prfpdfrom']["\$t"].toString()}'), // 개봉일
                                                              Text('장소 : ${data3![index]['fcltynm']['\$t'].toString()}') // 평점
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                    ),
                                                  ],
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                ),
                                              ],
                                              mainAxisAlignment: MainAxisAlignment.start,
                                            ),
                                          )),
                                      insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                                      actions: [
                                        TextButton( // 팝업창 정보 WriteSpace_get으로 넘김
                                          child: const Text('선택'),
                                          onPressed: () async {
                                            sendGenre = 1; // 장르값 1(뮤지컬)
                                            sendTitle = data3![index]['prfnm']['\$t'].toString(); // 뮤지컬 제목
                                            sendPlace = data3![index]['fcltynm']['\$t'].toString(); // 뮤지컬 장소
                                            Navigator.of(context).pop();//창닫기
                                            Get.to(() => WriteSpace_get(list: widget.list), arguments : {'genre' : sendGenre ,'title' : sendTitle, 'place' : sendPlace}); // 행사 종류, 뮤지컬 제목, 뮤지컬 장소 보냄
                                          },),
                                        TextButton( // 팝업창 닫기
                                          child: const Text('확인'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  }
                              );
                            },
                            child: Card(
                              child: Container(
                                child: Row(
                                  children: <Widget>[
                                    Image.network( // 포스터
                                        data3![index]['poster']['\$t'],
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            child: Icon(Icons.image_not_supported_outlined, color: Colors.blueGrey,size: 50,),
                                          );
                                        }
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context).size.width - 250,
                                          child: Text( // 뮤지컬 제목
                                            data3![index]['prfnm']["\$t"].toString(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Text('개봉일 : ${data3![index]['prfpdfrom']["\$t"].toString()}'), // 뮤지컬 개봉일
                                        Text('장소 : ${data3![index]['fcltynm']['\$t'].toString()}') // 뮤지컬 장소
                                      ],
                                      mainAxisAlignment: MainAxisAlignment.center,
                                    )
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                              ),
                            ),
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)), // 버튼 색 지정
                          );
                        },
                        itemCount: data3!.length, //데이터 개수만큼 영화 리스트 띄움
                        controller: _scrollController3,
                      ),
                    ),
                  ),

                  Container(height: 20) // 밑에 간격을 주고싶었음


                ],
          )
          ),
        )
    );
  }



  //------------------------여기부터 api 연동하는 부분---------------------------------

  Future<String> getJSONData1() async { // 영화 api 연동
    var url =
        'https://api.themoviedb.org/3/search/movie?query=${_editingController!.value.text}&include_adult=false&language=ko-kr&page=$page1';
    // query는 검색 정보, include_adult는 성인등급 콘텐츠 공개 여부, language는 언어, page는 페이지 정보
    var response = await http.get(Uri.parse(url),
    headers: {"Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxMjRlMmI5MzM1NzQwMjM0MWQ3OWIxMGJhYmYxYjRiMSIsInN1YiI6IjY0NzQ2NGYyY2MyNzdjMDEzMzg5NmNlMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.eAnnywDIsgTwuthIJ0KpOMj57aE0ZcMm1jv-cD1Q8SI", "accept": "application/json"});
    //api 키
    setState(() {
      var dataConvertedToJSON = json.decode(response.body);
      List result1 = dataConvertedToJSON['results'];
      data1!.addAll(result1);
    });
    return response.body;
  }


  XmlDocument? XmlData1;
  Future<String> getJSONData2() async {
    // 축제 api 연동
    http.Response response = await http.get(
      Uri.parse(
          'http://kopis.or.kr/openApi/restful/prffest?service=bacdfad8cf4645479a65308eb5aa35ef&stdate=20000101&eddate=22001231&cpage=$page2&rows=10&shprfnm=${_editingController!.value.text}'
      ),// service는 api키, stdate와 eddate는 보여줄 시작 날짜와 마지막 날짜, cpage는 페이지 정보, rows는 한 번에 보여줄 정보의 개수, shprfnm은 검색할 제목
    );

    setState(() {
      XmlData1 = XmlDocument.parse(response.body);
      Xml2Json jsonTransform = Xml2Json();
      jsonTransform.parse(XmlData1.toString());
      var Xml2JsonData = jsonTransform.toGData();
      var dataConvertedToJSON = json.decode(Xml2JsonData.toString());
      List result2 = dataConvertedToJSON['dbs']['db'];
      data2!.addAll(result2);
    });
    return response.body;
  }


  XmlDocument? XmlData2;
  Future<String> getJSONData3() async { // 뮤지컬 api 연동
    http.Response response = await http.get(
      Uri.parse(
          'http://kopis.or.kr/openApi/restful/pblprfr?service=bacdfad8cf4645479a65308eb5aa35ef&stdate=20000101&eddate=22001231&cpage=$page3&rows=10&shprfnm=${_editingController!.value.text}'
      ), // service는 api키, stdate와 eddate는 보여줄 시작 날짜와 마지막 날짜, cpage는 페이지 정보, rows는 한 번에 보여줄 정보의 개수, shprfnm은 검색할 제목
    );

    setState(() {
      XmlData2 = XmlDocument.parse(response.body);
      Xml2Json jsonTransform1 = Xml2Json();
      jsonTransform1.parse(XmlData2.toString());
      var Xml3jsonData = jsonTransform1.toGData();
      var dataConvertedToJSON = json.decode(Xml3jsonData);
      List result3 = dataConvertedToJSON['dbs']['db'];
      data3!.addAll(result3);
    });
    return response.body;
  }

  @override
  void initState() {
    super.initState();

    data1 = new List.empty(growable: true); // 영화 데이터 받아올 리스트
    data2 = new List.empty(growable: true); // 축제 데이터 받아올 리스트
    data3 = new List.empty(growable: true); // 뮤지컬 데이터 받아올 리스트
    
    _editingController = new TextEditingController(); // 검색창 TextEditingController
    _scrollController1 = new ScrollController(); // 영화 ScrollController
    _scrollController2 = new ScrollController(); // 축제 ScrollController
    _scrollController3 = new ScrollController(); // 뮤지컬 ScrollController

    _scrollController1!.addListener(() { // 영화 리스트 스크롤 할 때마다 데이터 받아오기
      if (_scrollController1!.offset >= _scrollController1!.position.maxScrollExtent
          && !_scrollController1!.position.outOfRange) {
        print('bottom');
        page1++;
        getJSONData1();
      }
    });
    _scrollController2!.addListener(() { // 축제 리스트 스크롤 할 때마다 데이터 받아오기
      if (_scrollController2!.offset >= _scrollController2!.position.maxScrollExtent
          && !_scrollController2!.position.outOfRange) {
        print('bottom');
        page2++;
        getJSONData2();
      }
    });
    _scrollController3!.addListener(() { // 뮤지컬 리스트 스크롤 할 때마다 데이터 받아오기
      if (_scrollController3!.offset >= _scrollController3!.position.maxScrollExtent
          && !_scrollController3!.position.outOfRange) {
        print('bottom');
        page3++;
        getJSONData3();
      }
    });
  }
}