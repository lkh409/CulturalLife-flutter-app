import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'package:path_provider/path_provider.dart';

import 'dart:io';

import './dataClass/memo.dart';

class WriteSpace_get extends StatefulWidget { //WriteSpace(SecondPage)와 같음. 다른 것은 initState의 초기값 설정 부분
  @override
  State<StatefulWidget> createState() => _WriteSpace_get();

  final List<Memo>? list;

  WriteSpace_get({Key? key, @required this.list}) : super(key: key);
}

class _WriteSpace_get extends State<WriteSpace_get> {

  final formKey = GlobalKey<FormState>();

  String title = '';
  String date = '';
  String genre = '';
  String place = '';
  String who = '';
  double rate = 0;
  String diary = '';
  String imagePath = '';

  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final placeController = TextEditingController();
  final whoController = TextEditingController();
  final diaryController = TextEditingController();

  int? _radioValue = 0;
  File? _storedImage;


  @override
  void initState() {
     if (Get.arguments['title'] != null){
       titleController.text = Get.arguments['title'].toString(); // HttpApp(ThirdPage)에서 제목 받아 텍스트필드에 넣기
     }
     if (Get.arguments['genre'] != null){
       _radioValue = Get.arguments['genre']; // HttpApp(ThirdPage)에서 장르 받아 텍스트필드에 넣기
     }
     if (Get.arguments['place'] != null){
       placeController.text = Get.arguments['place'].toString(); // HttpApp(ThirdPage)에서 장소 받아 텍스트필드에 넣기
     }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: AppBar(title: Text('Write Space'),
          leading:  IconButton(
              onPressed: () {
                Navigator.pop(context, 'refresh'); //뒤로가기
              },
              color: Colors.white,
              icon: Icon(Icons.arrow_back)),
        ),
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Form(
                key: this.formKey,
                child: Column(
                  children: <Widget>[
                    Container(height: 16.0),//여백

                    //============================================== 제목 ==============================================

                    Column(
                      children: [
                        Row(
                          children: [
                            Text('제목', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700,),),
                          ],
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(10)
                          ),
                          controller: titleController,
                          onSaved: (val) {
                            setState(() {
                              this.title = val as String;
                            });
                          },

                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return '제목을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        Container(height: 16.0),
                      ],
                    ),

                    //============================================== 장르 ==============================================

                    Column(
                        children: [
                          Row(
                            children: [
                              Text('장르', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700,),),
                            ],
                          ),
                          Row(
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
                          Container(height: 16.0),
                        ]
                    ),

                    //============================================== 날짜 ==============================================

                    Column(
                      children: [
                        Row(
                          children: [
                            Text('날짜', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700,),),
                          ],
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(10)
                          ),
                          controller: dateController,

                          onSaved: (val) {
                            setState(() {
                              this.date = val as String;
                            });
                          },

                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return '날짜를 입력해주세요';
                            }
                            return null;
                          },

                          onTap: () async{
                            FocusScope.of(context).requestFocus(new FocusNode());
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: new DateTime.now(), //get today's date
                                firstDate: new DateTime(2000), //DateTime.now() - not to allow to choose before today.
                                lastDate: DateTime(2201)
                            );
                            if(pickedDate != null ){
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

                    renderTextFormField(
                      label: '장소',
                      maxLines: 1,
                      controller: placeController,
                      onSaved: (val) {
                        setState(() {
                          this.place = val;
                        });
                      },
                      validator: (val) {
                        return null;
                      },
                    ),

                    //============================================== 같이 간 사람 ==============================================

                    renderTextFormField(
                      label: '같이 간 사람',
                      maxLines: 1,
                      controller: whoController,
                      onSaved: (val) {
                        setState(() {
                          this.who = val;
                        });
                      },
                      validator: (val) {
                        return null;
                      },
                    ),

                    //============================================== 평점 ==============================================

                    Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Text('평점', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700,),),
                          ],
                        ),
                        RatingBar(
                          initialRating: rate,
                          minRating: 0,
                          maxRating: 5,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 50,
                          ratingWidget: RatingWidget(
                            full: const Icon(
                              Icons.star, color: Colors.amber,),
                            half: const Icon(Icons.star_half,
                              color: Colors.amber,),
                            empty: const Icon(Icons.star_outline,
                              color: Colors.amber,),
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              this.rate = rating;
                            });
                          },
                        ),
                      ],
                    ),
                    Container(height: 16.0),

                    //============================================== 내용 ==============================================

                    renderTextFormField(
                      label: '내용',
                      maxLines: 10,
                      controller: diaryController,
                      onSaved: (val) {
                        setState(() {
                          this.diary = val;
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
                        ElevatedButton(
                            onPressed: () async {
                              var picker = ImagePicker();
                              var image = await picker.pickImage(source: ImageSource.gallery);
                              if (image != null){
                                _storedImage = File(image.path);
                                final appDir = await getApplicationDocumentsDirectory();
                                final fileName = image.path.split('/').last;
                                final savedFile = await _storedImage!.copy('${appDir.path}/$fileName');
                                setState(() {
                                  imagePath = savedFile.path;
                                  print(imagePath);
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
    required String label,
    required TextEditingController controller,
    required FormFieldSetter onSaved,
    required FormFieldValidator validator,
    required int maxLines,
    String
  }) {
    assert(onSaved != null);
    assert(validator != null);

    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        TextFormField(
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10)
          ),
          maxLines: maxLines,
          minLines: 1,
          controller: controller,
          onSaved: onSaved,
          validator: validator,
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

  getGenre(int? radioValue){
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
            this.genre = getGenre(_radioValue);
            var mydata = Memo(
                title: this.title,
                date: this.date,
                place: this.place,
                who: this.who,
                genre: this.genre,
                rate: this.rate,
                content: this.diary,
                imagePath: this.imagePath
            );
            widget.list?.add(mydata); //원본 리스트에 데이터 추가
            widget.list?.sort((a, b) => a.date!.compareTo(b.date!));//리스트 재정렬

            Navigator.pop(context, 'refresh'); //첫 페이지 새로고침과 함께 pop
          }

          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('폼 저장이 완료되었습니다!'),
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: "닫기",
                onPressed: (){},
              ),
            ),
          );
          titleController.clear();
          dateController.clear();
          placeController.clear();
          whoController.clear();
          diaryController.clear();
        }
      },
      child: Text('저장',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}