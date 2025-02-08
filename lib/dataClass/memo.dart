import 'dart:convert';
import 'package:flutter/material.dart';

class Memo {
  String? title;
  String? date;
  String? place;
  String? who;
  String? genre;
  double? rate;
  String? content;
  String? imagePath;

  Memo({
    required this.title,
    required this.date,
    required this.place,
    required this.who,
    required this.genre,
    required this.rate,
    required this.content,
    required this.imagePath
});

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
        title: json["title"],
        date: json["date"],
        place: json["place"],
        who: json["who"],
        genre: json["genre"],
        rate: json["rate"],
        content: json["content"],
        imagePath: json["imagePath"]
    );
  }
  Map toJson(){
    return {
      'title': this.title,
      'date': this.date,
      'place': this.place,
      'who': this.who,
      'genre': this.genre,
      'rate': this.rate,
      'content': this.content,
      'imagePath': this.imagePath
    };
  }
  @override
  String toString(){
    return '{title: $title, date: $date, place: $place, who: $who, genre: $genre, rate: $rate, content: $content, imagePath: $imagePath}';
  }
}