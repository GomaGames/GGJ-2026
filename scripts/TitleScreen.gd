extends Node2D

var p1_device = -1
var p2_device = -1
var game_starting = false

@onready var actor1 = $"Actor 1"
@onready var actor2 = $"Actor 2"
@onready var label_p1 = $"LabelP1"
@onready var label_p2 = $"LabelP2"
@onready var label_start = $"LabelStart"

func _ready():
	actor1.visible = false
	actor2.visible = false
	label_start.visible = false
	label_p1.text = "Player 1, press a button to join"
	label_p2.text = "Player 2, press a button to join"

func _input(event):
	if game_starting:
		return

	# Keyboard Input
	if event is InputEventKey and event.pressed:
		var joined_this_frame = false
		
		# Player 1 Join Keys: WASD + Space
		if event.keycode in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_SPACE]:
			if p1_device == -1:
				p1_device = -2
				GameManager.p1_device = p1_device
				label_p1.text = "Player 1 Ready (Keyboard)"
				actor1.visible = true
				joined_this_frame = true
				
		# Player 2 Join Keys: Arrows + Backspace
		if event.keycode in [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_BACKSPACE]:
			if p2_device == -1:
				p2_device = -2
				GameManager.p2_device = p2_device
				label_p2.text = "Player 2 Ready (Keyboard)"
				actor2.visible = true
				label_start.visible = true
				joined_this_frame = true
				
		# Start Game (Enter)
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if not joined_this_frame and label_start.visible:
				# Allow start if at least one keyboard player is present, or just generally allow it
				# If label_start is visible, it means we are ready.
				start_game()

	if event is InputEventJoypadButton and event.pressed:
		var joined_this_frame = false
		
		if p1_device == -1:
			p1_device = event.device
			GameManager.p1_device = p1_device
			label_p1.text = "Player 1 Ready"
			actor1.visible = true
			joined_this_frame = true
		elif p2_device == -1 and event.device != p1_device:
			p2_device = event.device
			GameManager.p2_device = p2_device
			label_p2.text = "Player 2 Ready"
			actor2.visible = true
			label_start.visible = true
			joined_this_frame = true
		
		# Check for Start button
		if not joined_this_frame and label_start.visible and event.button_index == JOY_BUTTON_START:
			if event.device == p1_device or event.device == p2_device:
				start_game()

func start_game():
	game_starting = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.BLACK, 2.0)
	tween.tween_callback(change_scene)

func change_scene():
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")
