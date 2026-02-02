extends Control

func _ready():
  var audio_player = AudioStreamPlayer.new()
  add_child(audio_player)
  var stream = load("res://sfx/Applause.wav")
  if stream:
    audio_player.stream = stream
    audio_player.play()
    
  await get_tree().create_timer(4.0).timeout
  get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
