extends Node
class_name PlayScriptLoader

static func load_playscript(path: String) -> Array:
  var file = FileAccess.open(path, FileAccess.READ)
  if not file:
    push_error("Could not open playscript file: " + path)
    return []
  
  var content = file.get_as_text()
  return parse_yaml(content)

static func parse_yaml(content: String) -> Array:
  var lines = content.split("\n")
  var root = []
  var context_stack = [{"indent": -1, "obj": root, "type": "list"}]
  
  # This is a simplified parser specifically for the expected structure
  # It assumes a list at the root
  
  var current_act = {}
  var current_scene_list = []
  var current_scene_obj = []
  var current_actions_list = []
  var current_action_obj = {}
  var current_slips_list = []
  
  # Specific parsing based on known keys, simpler than generic parser
  var data = []
  var act_obj = null
  var mask_obj = null
  var action_obj = null
  var in_slips = false
  
  for line in lines:
    var trimmed = line.strip_edges()
    if trimmed.is_empty() or trimmed.begins_with("#"):
      continue
      
    var indent = line.length() - line.strip_edges(true, false).length()
    
    if trimmed.begins_with("- act:"):
      act_obj = {}
      act_obj["act"] = int(trimmed.split(":")[1].strip_edges())
      act_obj["scene"] = []
      data.append(act_obj)
      current_scene_list = act_obj["scene"]
      current_scene_obj = null
      mask_obj = null # Reset
      action_obj = null
      in_slips = false
      
    elif trimmed.begins_with("scene:"):
      current_scene_obj = []
      current_scene_list.append(current_scene_obj)
      
    elif trimmed.begins_with("- mask:"):
      if act_obj != null:
        mask_obj = {}
        mask_obj["mask"] = int(trimmed.split(":")[1].strip_edges())
        mask_obj["actions"] = []
        if current_scene_obj != null:
           current_scene_obj.append(mask_obj)
        action_obj = null
        in_slips = false
        
    elif trimmed.begins_with("actions:"):
      pass # Marker
      
    elif trimmed.begins_with("- position:"):
      if mask_obj != null:
        action_obj = {}
        action_obj["position"] = trimmed.split(":")[1].strip_edges()
        mask_obj["actions"].append(action_obj)
        in_slips = false
        
    elif trimmed.begins_with("- line:"):
      if mask_obj != null:
        action_obj = {}
        action_obj["line"] = trimmed.split(":")[1].strip_edges()
        action_obj["slips"] = []
        mask_obj["actions"].append(action_obj)
        in_slips = false
        
    elif trimmed.begins_with("slips:"):
      in_slips = true
      
    elif trimmed.begins_with("-") and in_slips:
      if action_obj != null and action_obj.has("slips"):
        var slip_text = trimmed.substr(1).strip_edges()
        action_obj["slips"].append(slip_text)
  
  return data
