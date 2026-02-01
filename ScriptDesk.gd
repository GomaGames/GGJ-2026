extends "res://scripts/InteractionArea.gd"

@export var sliding_window: PanelContainer #= get_node("/root/Game/PlayScript/SlidingScript")

func _on_interact():
  super()  # Emit the base signal
  sliding_window.toggle()
  print("Desk interacted - toggling window")

# Optional: Add desk-specific behavior
func _on_player_entered():
  print("Player near desk")

func _on_player_exited():
  print("Player left desk")
