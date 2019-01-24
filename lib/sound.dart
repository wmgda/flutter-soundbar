class Sound {
  final String file;
  final String label;
  final bool isVisible;

  Sound(this.file, this.label, this.isVisible);

  Sound.fromJson(Map<String, dynamic> json)
      : file = json['file'],
        label = json['label'],
        isVisible = json['isVisible'];
}
