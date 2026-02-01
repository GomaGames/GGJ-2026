extends AnimatedSprite2D

@export var spriteFrames: SpriteFrames

var facingRight = true

func _ready():
  # Load the SpriteFrames resource
  self.sprite_frames = spriteFrames
  
  # Play animation
  play("IdleRight")  # "IdleRight" is the animation name

func UpdateAnimation(speed, direction: Vector2):
  if direction.x > 0:
    facingRight = true
  if direction.x < 0:
    facingRight = false

  var directionString = "Right" if facingRight else "Left"
  var walkString = "Idle" if direction.x == 0 and direction.y == 0 else "Walk"
  play(walkString+directionString)
  
func UpdateSprite(newFrames: SpriteFrames):
  self.sprite_frames = newFrames
  play("IdleRight")

func ResetSprite():
  self.sprite_frames = spriteFrames
  play("IdleRight")
