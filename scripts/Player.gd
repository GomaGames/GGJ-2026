extends CharacterBody2D

@export var player_id = 1
@export var speed = 300.0

func _physics_process(delta):
	var device = -1
	if player_id == 1:
		device = GameManager.p1_device
	elif player_id == 2:
		device = GameManager.p2_device
	
	if device == -1:
		return # Player not assigned
		
	var direction = Vector2.ZERO
	
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
	
	if direction.length() > 1.0:
		direction = direction.normalized()
	elif direction.length() > 0:
		# Keep magnitude if less than 1 (for analog control)
		pass
		
	velocity = direction * speed
	move_and_slide()
