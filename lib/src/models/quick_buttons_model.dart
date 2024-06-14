class QuickAccessButton {
  String name;
  String imgBase64;
  int action;
  int position;
  String uid;

  QuickAccessButton({
    required this.name,
    required this.imgBase64,
    required this.action,
    required this.position,
    required this.uid,
  });

  // funcion que nos devuelve una instancia de los datos
  // (le pasamos un json y nos da una instancia de QuickAccessButton)
  QuickAccessButton.fromJson(Map<String, Object?> json)
      : this(
          name: json['name']! as String,
          imgBase64: json['imgBase64']! as String,
          action: json['action'] as int,
          position: json['position'] as int,
          uid: json['uid']! as String,
        );

  // coge la instacia y nos devuelve una copia 
  // con los cambios que le hayamos hecho
  QuickAccessButton copyWith(
      {String? name,
      String? imgBase64,
      int? action,
      int? position,
      String? uid}) {
    return QuickAccessButton(
        name: name ?? this.name,
        imgBase64: imgBase64 ?? this.imgBase64,
        action: action ?? this.action,
        position: position ?? this.position,
        uid: uid ?? this.uid);
  }

  // nos devuelve un json con los datos de la instacia
  Map<String, Object?> toJson() {
    return {
      'name': name,
      'imgBase64': imgBase64,
      'action': action,
      'position': position,
      'uid': uid
    };
  }
}
