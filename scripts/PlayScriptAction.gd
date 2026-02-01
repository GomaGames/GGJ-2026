extends HBoxContainer

@onready var icon_container = $IconContainer
@onready var text_container = $TextContainer

func setup(mask_id: int, actions: Array):
  # Load mask icon
  var icon_path = "res://scenes/PlayScriptMaskIcon%d.tscn" % mask_id
  if ResourceLoader.exists(icon_path):
    var icon_scene = load(icon_path)
    if icon_scene:
      var icon_instance = icon_scene.instantiate()
      icon_container.add_child(icon_instance)
  
    # Add text labels
    for action in actions:

      var label = Label.new()
      if action.has("position"):
        label.text = str(action["position"]).capitalize() + " Stage" if str(action["position"]).capitalize() == str("Center") else "Stage " + str(action["position"]).capitalize()
        label.modulate = Color(0.8, 0.8, 0.8) # Slightly dim for stage directions
      elif action.has("line"):
        label.text = str(action["line"])
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  
      text_container.add_child(label)

func setupSceneStart(scene_id: int):
      var label = Label.new()
      label.text = "\nNEW SCENE"
      text_container.add_child(label)
      self.size.y = 10
