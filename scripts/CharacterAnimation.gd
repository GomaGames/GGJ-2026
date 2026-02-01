extends AnimatedSprite2D

@export var spriteFrames: SpriteFrames

func _ready():
  # Load the SpriteFrames resource
  self.sprite_frames = sprite_frames
  
  # Play animation
  play("IdleRight")  # "IdleRight" is the animation name
