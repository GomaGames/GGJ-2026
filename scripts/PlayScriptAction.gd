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

      if action.has("position"):
        var hbox = HBoxContainer.new()
        
        # Determine icon
        var pos_str = str(action["position"]).to_lower()
        var pos_icon_path = ""
        if pos_str == "left":
          pos_icon_path = "res://scenes/PlayScriptStageLeftIcon.tscn"
        elif pos_str == "right":
          pos_icon_path = "res://scenes/PlayScriptStageRightIcon.tscn"
        elif pos_str == "center":
          pos_icon_path = "res://scenes/PlayScriptCenterStageIcon.tscn"
          
        if pos_icon_path != "" and ResourceLoader.exists(pos_icon_path):
           var ic = load(pos_icon_path).instantiate()
           hbox.add_child(ic)
        
        var label = Label.new()
        label.text = str(action["position"]).capitalize() + " Stage" if str(action["position"]).capitalize() == str("Center") else "Stage " + str(action["position"]).capitalize()
        label.modulate = Color(0.8, 0.8, 0.8) # Slightly dim for stage directions
        
        hbox.add_child(label)
        text_container.add_child(hbox)
        
      elif action.has("line"):
        var label = Label.new()
        label.text = str(action["line"])
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        text_container.add_child(label)

func setupSceneStart(scene_id: int, costumesToUse):
      var label = Label.new()
      
      label.text = "\nENTER " + " and ".join(costumesToUse.map(func(n): return Utils.GetCostumeString(n)))
      text_container.add_child(label)
      self.size.y = 10
