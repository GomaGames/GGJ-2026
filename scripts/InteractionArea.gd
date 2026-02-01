extends StaticBody2D
class_name InteractiveObject

signal interaction_triggered(object)

@export var interaction_key: String = "ui_accept"

@onready var interaction_zone: Area2D = $InteractionArea

var player_in_range: bool = false

func _ready():
  # Connect child Area2D signals
  if interaction_zone:
    interaction_zone.body_entered.connect(_on_interaction_zone_body_entered)
    interaction_zone.body_exited.connect(_on_interaction_zone_body_exited)
  
func _input(event):
  if player_in_range and event.is_action_pressed(interaction_key):
    _on_interact()
    get_viewport().set_input_as_handled()

func _on_interaction_zone_body_entered(body):
  if body.is_in_group("Player"):
    player_in_range = true
    _on_player_entered()
    
func _on_interaction_zone_body_exited(body):
  if body.is_in_group("Player"):
    player_in_range = false
    _on_player_exited()
    
# Virtual methods to override in child classes
func _on_interact():
  emit_signal("interaction_triggered", self)

func _on_player_entered():
  pass

func _on_player_exited():
  pass

func can_interact() -> bool:
  return player_in_range
