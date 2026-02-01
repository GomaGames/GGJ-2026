extends PanelContainer

@onready var tween := get_tree().create_tween()
var isOpen := false

var hidden_pos:Vector2
var shown_pos:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shown_pos = position
	
	hidden_pos = Vector2(-size.x, position.y)

	position = hidden_pos
	visible = true
	
func toggle():
	isOpen = !isOpen
	tween.kill()
	tween = get_tree().create_tween()
	var target = shown_pos if isOpen else hidden_pos
	
	tween.tween_property(self, "position", target, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_toggle_script"):
		toggle()
