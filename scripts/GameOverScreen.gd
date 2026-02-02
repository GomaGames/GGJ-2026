extends Node2D

@onready var completion_label = %CompletionStatus

func _ready():
  if completion_label:
    var pct = GameManager.completion_percentage
    completion_label.text = "You completed %d%% of the play." % pct
    
  var audio_player = AudioStreamPlayer.new()
  add_child(audio_player)
  var stream = load("res://sfx/Booing.wav")
  if stream:
    audio_player.stream = stream
    audio_player.play()
    
func _input(event):
  # Allow restarting on any key/button press
  if event is InputEventKey or event is InputEventJoypadButton:
    if event.pressed:
      get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
