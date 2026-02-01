extends AnimatedSprite2D

@export var spriteFrames: SpriteFrames

func _ready():
  # Load the SpriteFrames resource
  self.sprite_frames = sprite_frames
  
  # Play animation
  play("IdleRight")  # "IdleRight" is the animation name

func UpdateAnimation(speed, direction: Vector2):
  var directionString = "Right" if direction.x >= 0 else "Left"
  var walkString = "Idle" if speed == 0 else "Walk"
  play(walkString+directionString)
	
