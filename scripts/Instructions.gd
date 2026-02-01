extends Control

func _input(event):
  if event is InputEventKey or event is InputEventJoypadButton:
    if event.pressed:
      get_tree().change_scene_to_file("res://scenes/MainScene.tscn")
