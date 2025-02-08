import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import 'package:path_provider/path_provider.dart';

import 'dart:io';

import './dataClass/memo.dart';

class WriteSpace extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WriteSpace();

  final List<Memo>? list; // 다른 페이지로부터 데이터를 받기 위한 리스트 list

  WriteSpace({Key? key, @required this.list}) : super(key: key); // 페이지 간 데이터 주고받기 위한 코드
}

class _WriteSpace extends State<WriteSpace> {

  final formKey = GlobalKey<FormState>(); // TextForm 키를 다른 클래스에도 접근할 수 있도록 함

  String title = ''; // 작성한 제목 저장
  String date = ''; // 작성한 날짜 저장
  String genre = ''; // 작성한 장르(영화, 뮤지컬, 축제, 기타) 저장
  String place = ''; // 작성한 장소 저장
  String who = ''; // 작성한 같이 간 사람 저장
  double rate = 0; // 작성한 평점 저장
  String diary = ''; // 작성한 내용 저장
  String imagePath = ''; // 갤러리에서 불러온 이미지 저장

  final titleController = TextEditingController(); // 제목 TextFormField를 위한 TextEditingController
  final dateController = TextEditingController(); // 제목 TextFormField를 위한 TextEditingController
  final placeController = TextEditingController(); // 제목 TextFormField를 위한 TextEditingController
  final whoController = TextEditingController(); // 제목 TextFormField를 위한 TextEditingController
  final diaryController = TextEditingController(); // 제목 TextFormField를 위한 TextEditingController

  int? _radioValue = 0; // 장르 선택 Radio 초기 value
  File? _storedImage; // 이미지 경로 받기 위한 File 변수


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false, // 키보드 뜰 때, 화면이 줄어들어서 overflow가 생기지 않도록 함

      appBar: AppBar(title: Text('Write Space'),
        leading:  IconButton( // appBar 왼쪽의 뒤로 가기 버튼
            onPressed: () {
              Navigator.pop(context, 'refresh'); // 첫 화면으로 pop
            },
            color: Colors.white,
            icon: Icon(Icons.arrow_back)),
      ),

      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus(); // TextFormField 밖을 눌렀을 때, 키보드를 집어넣음
        },
        child: SingleChildScrollView( // 화면 overflow가 생기지 않도록 세로로 스크롤 가능하도록 함
          child: Container( // 앱 화면
            margin: const EdgeInsets.fromLTRB(15, 0, 15, 0), // 화면 전체에 좌우 여백을 줌
            child: Form( // Form(여러 값을 한꺼번에 받을 수 있도록 함)
              key: this.formKey, // 위에 GlobalKey로 설정해뒀던 formKey
              child: Column(
                children: <Widget>[
                  Container(height: 16.0),// 위 여백

                  //============================================== 제목 ==============================================

                  Column(
                    children: [
                      Row( // Row 자체는 Column 안에서 가운데 정렬 됨. Text는 Row 안에서 좌측 정렬
                        children: [Text('제목', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700,),),],
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(10)
                        ), // TextFormField 스타일 설정. 테두리 추가, 안쪽 여백 10
                        controller: titleController, // TextEditingController
                        onSaved: (val) { // save 함수 호출 시
                          setState(() {
                            this.title = val as String; //title에 텍스트필드에 있는 값(val) 저장
                          });
                        },
                        validator: (val) { // 값을 입력하지 않았을 때 경고문구
                          if (val == null || val.isEmpty) {return '제목을 입력해주세요';}
                          return null;
                        },
                      ),
                      Container(height: 16.0), // 아래 여백
                    ],
                  ),

                  //============================================== 장르 ==============================================

                  Column(
                      children: [ // Row 자체는 Column 안에서 가운데 정렬 됨. Text는 Row 안에서 좌측 정렬
                        Row(children: [Text('장르', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700,),),],),
                        Row( // 장르 선택. _radioValue 함수(아래에 있음)로 그룹 값 지정. _radioChange 함수(아래에 있음)로 값 변화
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Radio(value: 0, groupValue: _radioValue, onChanged: _radioChange,),
                            Text('영화'),
                            SizedBox(width: 10.0,),
                            Radio(value: 1, groupValue: _radioValue, onChanged: _radioChange,),
                            Text('뮤지컬'),
                            SizedBox(width: 10.0,),
                            Radio(value: 2, groupValue: _radioValue, onChanged: _radioChange,),
                            Text('축제'),
                            SizedBox(width: 10.0,),
                            Radio(value: 3, groupValue: _radioValue, onChanged: _radioChange,),
                            Text('기타'),
                            SizedBox(width: 10.0,),
                          ],
                        ),
                        Container(height: 16.0), // 여백
                      ]
                  ),
                  
                  //============================================== 날짜 ==============================================

                  Column(
                    children: [ // Row 자체는 Column 안에서 가운데 정렬 됨. Text는 Row 안에서 좌측 정렬
                      Row(children: [Text('날짜', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700,),),],),
                      TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(10)
                        ), // TextFormField 스타일 설정. 테두리 추가, 안쪽 여백 10
                        controller: dateController, // TextEditingController
                        onSaved: (val) { // save 함수 호출 시
                          setState(() {
                            this.date = val as String; // date에 텍스트필드에 있는 값(val) 저장
                          });
                        },
                        validator: (val) { // 값을 입력하지 않았을 때 경고문구
                          if (val == null || val.isEmpty) {return '날짜를 입력해주세요';}
                          return null;
                        },
                        onTap: () async{ // 누르면 날짜 선택하도록 DatePicker 나옴
                          FocusScope.of(context).requestFocus(new FocusNode());
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: new DateTime.now(), // 오늘 날짜를 초기값으로 잡음
                              firstDate: new DateTime(2000), // 달력 시작 년도
                              lastDate: DateTime(2201) // 달력 끝 년도
                          );
                          if(pickedDate != null ){ // 텍스트필드에 선택한 날짜 표시
                            setState(() {
                              dateController.text = DateFormat('yyyy/MM/dd').format(pickedDate);
                            });
                          }else{
                            print("날짜가 선택되지 않았습니다.");
                          };
                        },
                      ),
                      Container(height: 16.0),
                    ],
                  ),

                  //============================================== 장소 ==============================================

                  renderTextFormField( // renderTextFormField 함수로 장소 입력칸 만들기
                    label: '장소', // TextFormField 위의 텍스트
                    maxLines: 1, // 최대 텍스트필드 줄 수
                    controller: placeController,
                    onSaved: (val) { //save 함수 호출 시
                      setState(() {
                        this.place = val; // place에 텍스트필드에 있는 값(val) 저장
                      });
                    },
                    validator: (val) {
                      return null;
                    },
                  ),

                  //============================================== 같이 간 사람 ==============================================

                  renderTextFormField( // renderTextFormField 함수로 같이 간 사람 입력칸 만들기
                    label: '같이 간 사람', // TextFormField 위의 텍스트
                    maxLines: 1, // 최대 텍스트필드 줄 수
                    controller: whoController,
                    onSaved: (val) { // save 함수 호출 시
                      setState(() {
                        this.who = val; // who에 텍스트필드에 있는 값(val) 저장
                      });
                    },
                    validator: (val) {
                      return null;
                    },
                  ),

                  //============================================== 평점 ==============================================

                  Column( // Row 자체는 Column 안에서 가운데 정렬 됨. Text는 Row 안에서 좌측 정렬
                    children: <Widget>[Row(children: [Text('평점', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700,),),],),
                      RatingBar( // 평점 입력칸
                        initialRating: rate,
                        minRating: 0, // 최소 평점
                        maxRating: 5, // 최대 평점
                        direction: Axis.horizontal, // 값이 가로로 채워짐
                        allowHalfRating: true,
                        itemCount: 5, // 평점 칸 개수
                        itemSize: 50, // 크기
                        ratingWidget: RatingWidget( // 평점 아이콘 설정
                          full: const Icon(Icons.star, color: Colors.amber,),
                          half: const Icon(Icons.star_half, color: Colors.amber,),
                          empty: const Icon(Icons.star_outline, color: Colors.amber,),
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            this.rate = rating; //rating 값 rate에 저장
                          });
                        },
                      ),
                    ],
                  ),
                  Container(height: 16.0),

                  //============================================== 내용 ==============================================

                  renderTextFormField( // renderTextFormField 함수로 내용 입력칸 만들기
                    label: '내용', // TextFormField 위의 텍스트
                    maxLines: 10, // 최대 텍스트필드 줄 수
                    controller: diaryController,
                    onSaved: (val) { //save 함수 호출 시
                      setState(() {
                        this.diary = val; // diary에 텍스트필드에 있는 값(val) 저장
                      });
                    },
                    validator: (val) {
                      return null;
                    },
                  ),

                  //============================================== 사진 추가 ==============================================

                  Column(
                    children: [
                      Row(children: [Text('사진 추가', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700,),),],),
                      ElevatedButton( // 버튼 누르면
                          onPressed: () async {
                            var picker = ImagePicker();
                            var image = await picker.pickImage(source: ImageSource.gallery); // ImagePicker가 갤러리에서 사진 가져온 후, 경로 저장
                            if (image != null){
                               _storedImage = File(image.path); // 이미지 파일
                               final appDir = await getApplicationDocumentsDirectory(); // 앱 경로
                               final fileName = image.path.split('/').last; // 사진 이름
                              final savedFile = await _storedImage!.copy('${appDir.path}/$fileName'); // 앱에 사진 저장
                              setState(() {
                                imagePath = savedFile.path; // 앱에 저장된 사진 경로 저장
                              });
                            }
                          },
                          child: Text('갤러리에서 사진 가져오기')),
                      Container(height: 16.0),
                    ],
                  ),
                  renderButton(),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  //============================================== TextForm 생성 함수 ==============================================
  
  renderTextFormField({
    required String label, // TextFormField 위에 보여지는 텍스트
    required TextEditingController controller, // TextEditingController
    required FormFieldSetter onSaved, // Form 값 저장
    required FormFieldValidator validator, // 경고 문구
    required int maxLines, // 최대 줄 수
    String
  }) {
    assert(onSaved != null);
    assert(validator != null);

    return Column(
      children: [
        Row(
          children: [
            Text( // TextFormField 위에 보여지는 텍스트
              label,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        TextFormField(
          decoration: InputDecoration( // TextFormField 스타일
              border: OutlineInputBorder(), // 테두리
              contentPadding: EdgeInsets.all(10) // 여백
          ),
          maxLines: maxLines, // 최대 줄 수
          minLines: 1, // 최소 줄 수
          controller: controller, // TextEditingController
          onSaved: onSaved, // Form 값 저장
          validator: validator, // 경고 문구
        ),
        Container(height: 16.0),
      ],
    );
  }

  //============================================== radio 초기값 바꾸기 함수 ==============================================

  _radioChange(int? value){
    setState(() {
      _radioValue = value;
    });
  }

  //============================================== radio의 genre값을 string으로 변환하는 함수 ==============================================

  getGenre(int? radioValue){ // radio 값을 보고 genre값을 string으로 변환
    switch (radioValue) {
      case 0:
        return "movie";
      case 1:
        return "musical";
      case 2:
        return "festival";
      case 3:
        return "else";
    }
  }

  //============================================== 저장 함수 ==============================================

  renderButton() {
    return ElevatedButton(
      onPressed: () async {

        if(this.formKey.currentState!.validate()){
          this.formKey.currentState!.save(); //formKey에 저장

          setState(() {
            this.genre = getGenre(_radioValue); // 장르값(String) 받기
            var mydata = Memo( // Memo 형식의 mydata 리스트에 값 저
                title: this.title,
                date: this.date,
                place: this.place,
                who: this.who,
                genre: this.genre,
                rate: this.rate,
                content: this.diary,
                imagePath: this.imagePath
            );
            widget.list?.add(mydata); // mydata를 공유된 원본 list에 추가
            widget.list?.sort((a, b) => a.date!.compareTo(b.date!)); // 원본 리스트 날짜별로 재정렬

            Navigator.pop(context, 'refresh'); //첫 페이지 새로고침과 함께 pop
          }
          );

          ScaffoldMessenger.of(context).showSnackBar( // 스낵바 띄우기
            SnackBar(
              content: Text('폼 저장이 완료되었습니다!'),
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: "닫기",
                onPressed: (){},
              ),
            ),
          );
          titleController.clear(); // 텍스트필드 초기화
          dateController.clear(); // 텍스트필드 초기화
          placeController.clear(); // 텍스트필드 초기화
          whoController.clear(); // 텍스트필드 초기화
          diaryController.clear(); // 텍스트필드 초기화
        }
      },
      child: Text('저장', // 버튼 텍스트
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}