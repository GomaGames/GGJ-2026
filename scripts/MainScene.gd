extends Node2D

@onready var action_list = %ActionList
@onready var playscript_layer = %PlayScript # Assuming unique_id PlayScript is not accessible directly or using explicit node path

var active_player = null
var players_in_zone = []

func _ready():
	# Load the playscript
	var data = PlayScriptLoader.load_playscript("res://assets/playscript.yml")
	
	# Find Act 1
	var act1 = null
	for act in data:
		if act.get("act") == 1:
			act1 = act
			break
	
	if act1:
		render_act(act1)

func render_act(act_data):
	var scenes = act_data.get("scene", [])
	for scene_item in scenes:
		var mask_id = scene_item.get("mask", 1)
		var actions = scene_item.get("actions", [])
		
		# Create a new PlayScriptAction row
		var action_row = preload("res://scenes/PlayScriptAction.tscn").instantiate()
		action_list.add_child(action_row)
		action_row.setup(mask_id, actions)
