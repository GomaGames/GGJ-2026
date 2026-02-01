extends AnimatedSprite2D

@export var spriteFrames: SpriteFrames

func _ready():
  # Load the SpriteFrames resource
  self.sprite_frames = spriteFrames
  
  # Play animation
  play("IdleRight")  # "IdleRight" is the animation name

func UpdateAnimation(speed, direction: Vector2):
  var directionString = "Right" if direction.x >= 0 else "Left"
  var walkString = "Idle" if speed == 0 else "Walk"
  play(walkString+directionString)
  
func UpdateSprite(newFrames: SpriteFrames):
  self.sprite_frames = newFrames
  play("IdleRight")

func ResetSprite():
  self.sprite_frames = spriteFrames
  play("IdleRight")
