import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:odin/src/utils/quick_actions_manager.dart';
import 'package:odin/src/widgets/qab_edit_popup.dart';

class OverviewItem extends StatefulWidget {
// variables del item
  final double radius;
  final double elevation;
  final String id;
  final int action;
  final String imageBase64;
  final int position;
  const OverviewItem({
    super.key,
    required this.radius,
    required this.elevation,
    required this.id,
    required this.action,
    required this.imageBase64,
    required this.position,
  });

  @override
  State<OverviewItem> createState() => _OverviewItemState();
}

class _OverviewItemState extends State<OverviewItem> {
  @override
  Widget build(BuildContext context) {
    //creamos el widget
    return Container(
      margin: const EdgeInsets.all(10),
      child: Center(
        // hacemos un boton que concetendra la imagen (fadeinimage)
        child: ElevatedButton(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    content: QAButtonsEditPopup(
                  id: widget.id,
                  position: widget.position,
                ));
              },
            );
          },

          //cambiamos el stilo para que no tenga tanto padding
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(3),
            elevation: widget.elevation,
          ),
          // funcion a relizar cuando pulsemos el boton
          onPressed: QuickAcctionsManager.getAccionById(
              context, widget.action, widget.id, widget.position),

          // widget para mosatrar elemento como si fuera un avatar
          child: AnimatedSize(
            clipBehavior: Clip.antiAlias,
            curve: Curves.bounceInOut,
            duration: const Duration(milliseconds: 500),
            child: Container(
              clipBehavior: Clip.antiAlias,
              width: widget.radius - 40,
              height: widget.radius - 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).secondaryHeaderColor),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Image.memory(
                  base64Decode(widget.imageBase64),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
