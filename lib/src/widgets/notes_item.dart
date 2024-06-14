import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotesItem extends StatefulWidget {
  final String title;
  final String id;
  final Function(String id)? onDelete;
  final String imgBase64;
  final Timestamp createdOn;
  final Timestamp updatedOn;
  final List tags;
  final String content;

  const NotesItem({
    super.key,
    required this.title,
    required this.id,
    required this.content,
    this.onDelete,
    required this.imgBase64,
    required this.createdOn,
    required this.updatedOn,
    required this.tags,
  });

  @override
  State<NotesItem> createState() => _NotesItemState();
}

Image imageFromBase64String(String base64String) {
  return Image.memory(base64Decode(base64String));
}

Uint8List dataFromBase64String(String base64String) {
  return base64Decode(base64String);
}

String base64String(Uint8List data) {
  return base64Encode(data);
}

class _NotesItemState extends State<NotesItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.greenAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Center(
          child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/editNote',
            arguments: {
              'id': widget.id,
              'title': widget.title,
              'imgBase64': widget.imgBase64,
              'createdOn': widget.createdOn,
              'updatedOn': widget.updatedOn,
              'tags': widget.tags,
              'content': widget.content
            },
          );
        },
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Stack(
                children: [
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  Positioned.fill(
                    child: Image.memory(
                      base64Decode(widget.imgBase64),
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 40, 0, 40),
                      child: Text(
                        widget.content,
                        overflow: TextOverflow.fade,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  // Expanded(child: Container(color: Colors.red,),),
                  Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -5,
                            left: 0,
                            right: 130,
                            child: Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Text(
                              //  DateFormat('dd/MM/yyyy h:mm a', 'es_ES')
                              //       .format(widget.createdOn.toDate()),
                              DateFormat.yMd().add_Hms().format(
                                    widget.updatedOn.toDate().add(
                                          const Duration(hours: 0),
                                        ),
                                  ),
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75),
                              // width: 100,
                              padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                              decoration: BoxDecoration(
                                color: Colors.cyan.shade200.withAlpha(150),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.amber.withAlpha(0),
                                ),
                              ),
                              child: Text(
                                widget.tags.toList().join(', '),
                                // style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[900]),
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: -14,
                              right: -5,
                              child: IconButton(
                                onPressed: () {
                                  widget.onDelete!(widget.id);
                                },
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                              )),
                        ],
                      ))
                ],
              ),
            )),
      )),
    );
  }
}
