import 'package:letsdeal_soundboard/sound.dart';

class Config {
  final List<Sound> sounds;

  Config(this.sounds);

  Config.fromJson(Map<String, dynamic> json)
      : sounds = (json['sounds'] as List).map((sound) => Sound.fromJson(sound)).toList();
}