import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String title;
  String imgBase64; // de fondo
  List tags;
  Timestamp createdOn;
  Timestamp updatedOn;
  String uid;
  String content;
  Note({
    required this.title,
    required this.imgBase64,
    required this.tags,
    required this.createdOn,
    required this.updatedOn,
    required this.uid,
    required this.content,
  });

  // fucion/constructor que nos devuelve una instancia de los datos (le pasamos un json y nos da una instancia de QuickAccessButton)
  Note.fromJson(Map<String, Object?> json)
      : this(
            title: json['title']! as String,
            imgBase64: json['imgBase64']! as String,
            tags: json['tags']! as List,
            createdOn: json['createdOn']! as Timestamp,
            updatedOn: json['updatedOn']! as Timestamp,
            uid: json['uid']! as String,
            content: json['content']! as String);

  // coge la instacia y nos devuelve una copia con los cambios que le hayamos hecho
  Note copyWith(
      {String? title,
      String? imgBase64,
      String? id,
      List? tags,
      Timestamp? createdOn,
      Timestamp? updatedOn,
      String? uid,
      String? content}) {
    return Note(
      title: title ?? this.title,
      imgBase64: imgBase64 ?? this.imgBase64,
      tags: tags ?? this.tags,
      createdOn: createdOn ?? this.createdOn,
      updatedOn: updatedOn ?? this.updatedOn,
      uid: uid ?? this.uid,
      content: content ?? this.content,
    );
  }

  // nos devuelve un json con los datos de la instacia
  Map<String, Object?> toJson() {
    return {
      'title': title,
      'imgBase64': imgBase64, // de fondo
      'tags': tags,
      'createdOn': createdOn,
      'updatedOn': updatedOn,
      'uid': uid,
      'content': content,
    };
  }
}
