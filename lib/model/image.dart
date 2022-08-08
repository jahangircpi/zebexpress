class UserIcon {
  String link;

  UserIcon({this.link});
  factory UserIcon.fromJson(Map<String, dynamic> json) {
    return UserIcon(
      link: json['link'],
    );
  }
}
