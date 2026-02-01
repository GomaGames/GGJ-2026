extends StaticBody2D

var id = 0
var is_used = false
@onready var polygon = $Polygon2D
@onready var original_color = polygon.color

func _ready():
	# Parse ID from name (e.g., "Dress Rack 1")
	var name_parts = name.split(" ")
	if name_parts.size() > 0:
		id = name_parts[name_parts.size() - 1].to_int()
	
	# Create Interaction Area
	var area = Area2D.new()
	area.name = "InteractionArea"
	add_child(area)
	
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 80 # Interaction radius
	col.shape = shape
	area.add_child(col)
	
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Check if body is player (has interact_pressed signal)
	if body.has_signal("interact_pressed"):
		if not body.interact_pressed.is_connected(_on_interact):
			body.interact_pressed.connect(_on_interact.bind(body))

func _on_body_exited(body):
	if body.has_signal("interact_pressed"):
		if body.interact_pressed.is_connected(_on_interact):
			body.interact_pressed.disconnect(_on_interact)

func _on_interact(player):
	var mask = player.get_node_or_null("Mask")
	
	if not is_used:
		# Player wants to take mask
		if mask == null:
			# Only allow taking if player hands are empty
			take_mask(player)
	else:
		# Player wants to return mask
		if mask != null and mask.has_meta("rack_id"):
			if mask.get_meta("rack_id") == id:
				return_mask(player, mask)

func take_mask(player):
	is_used = true
	polygon.color = Color.GRAY
	get_node("DragonSprite").visible = false
	
	var scene_path = "res://scenes/PlayScriptMaskIcon" + str(id) + ".tscn"
	if ResourceLoader.exists(scene_path):
		var mask_scene = load(scene_path)
		var mask_instance = mask_scene.instantiate()
		mask_instance.name = "Mask"
		mask_instance.set_meta("rack_id", id)
		player.add_child(mask_instance)
		# Position mask above player
		mask_instance.position = Vector2(-25, -70) 
		# Adjust scale if needed, icons are 50x50, player is scaled 0.7
		# Since mask is child of player, it inherits scale 0.7.
		# 50px * 0.7 = 35px. Player is ~40px wide? 
		# Let's adjust position to be visually nice.
	else:
		push_error("Mask scene not found: " + scene_path)

func return_mask(player, mask_instance):
	is_used = false
	polygon.color = original_color
	get_node("DragonSprite").visible = true
	mask_instance.queue_free()
