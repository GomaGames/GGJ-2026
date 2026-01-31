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
	
	# Setup interaction logic
	var interaction_area = $"Script Desk/InteractionArea"
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	# Connect to players
	# Note: In the scene they are named "Actor 1" and "Actor 2"
	var actor1 = $"Actor 1"
	var actor2 = $"Actor 2"
	
	if actor1:
		actor1.interact_pressed.connect(func(): _on_player_interact(actor1))
	if actor2:
		actor2.interact_pressed.connect(func(): _on_player_interact(actor2))

func _on_interaction_area_body_entered(body):
	if body is CharacterBody2D and "player_id" in body: # Simple check for Player
		if not body in players_in_zone:
			players_in_zone.append(body)

func _on_interaction_area_body_exited(body):
	if body in players_in_zone:
		players_in_zone.erase(body)

func _on_player_interact(player):
	# Case 1: Player is the active one (dismiss)
	if active_player == player:
		active_player.can_move = true
		active_player = null
		# Find PlayScript node (it's the CanvasLayer)
		var ps = get_node("PlayScript")
		if ps: ps.visible = false
		return
		
	# Case 2: No active player, but this player is in zone (activate)
	if active_player == null and player in players_in_zone:
		active_player = player
		player.can_move = false
		var ps = get_node("PlayScript")
		if ps: ps.visible = true

func render_act(act_data):
	var scenes = act_data.get("scene", [])
	for scene_item in scenes:
		var mask_id = scene_item.get("mask", 1)
		var actions = scene_item.get("actions", [])
		
		# Create a new PlayScriptAction row
		var action_row = preload("res://scenes/PlayScriptAction.tscn").instantiate()
		action_list.add_child(action_row)
		action_row.setup(mask_id, actions)
