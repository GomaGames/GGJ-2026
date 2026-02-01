extends Control

func _ready():
  await get_tree().create_timer(4.0).timeout
  get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
