extends CharacterBody2D

@export var player_id = 1
@export var speed = 600.0

var can_move = true
signal interact_pressed
var _interact_cooldown = false

func _physics_process(delta):
  var device = -1
  if player_id == 1:
	device = GameManager.p1_device
  elif player_id == 2:
	device = GameManager.p2_device
  
  if device == -1:
	return # Player not assigned
	
  # Check for interaction (Button 0/A/Cross or Space)
  var interact = false
  if device == -2:
	# Keyboard
	if player_id == 1:
	  interact = Input.is_key_pressed(KEY_SPACE)
	elif player_id == 2:
	  interact = Input.is_key_pressed(KEY_BACKSPACE)
  else:
	# Gamepad
	interact = Input.is_joy_button_pressed(device, JOY_BUTTON_A)
	
  if interact:
	if not _interact_cooldown:
	  interact_pressed.emit()
	  _interact_cooldown = true
	  # Simple cooldown to prevent double-triggering
	  get_tree().create_timer(0.2).timeout.connect(func(): _interact_cooldown = false)
  
  if not can_move:
	return
	
  var direction = Vector2.ZERO
  
  if device == -2:
	# Keyboard Movement
	if player_id == 1:
	  if Input.is_action_pressed("player_1_a"): direction.x -= 1
	  if Input.is_action_pressed("player_1_d"): direction.x += 1
	  if Input.is_action_pressed("player_1_w"): direction.y -= 1
	  if Input.is_action_pressed("player_1_s"): direction.y += 1
	elif player_id == 2:
	  if Input.is_key_pressed(KEY_LEFT): direction.x -= 1
	  if Input.is_key_pressed(KEY_RIGHT): direction.x += 1
	  if Input.is_key_pressed(KEY_UP): direction.y -= 1
	  if Input.is_key_pressed(KEY_DOWN): direction.y += 1
  else:
	# Joystick input
	var x = Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
	var y = Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
	
	# Deadzone
	if abs(x) < 0.2: x = 0
	if abs(y) < 0.2: y = 0
	
	direction = Vector2(x, y)
	
	# D-pad input override (optional, but good for digital control)
	if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_UP): direction.y = -1
	if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN): direction.y = 1
	if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_LEFT): direction.x = -1
	if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_RIGHT): direction.x = 1

  get_node("Sprite").UpdateAnimation(speed, direction)
  
  if direction.length() > 1.0:
	direction = direction.normalized()
  elif direction.length() > 0:
	# Keep magnitude if less than 1 (for analog control)
	pass
	
  velocity = direction * speed
  move_and_slide()
