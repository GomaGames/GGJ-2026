extends Node2D

class_name MainScene

@onready var action_list = %ActionList
@onready var playscript_layer = %PlayScript
@onready var stage_left = %StageLeft
@onready var center_stage = %CenterStage
@onready var stage_right = %StageRight
@onready var stage_left_prompts = %StageLeftPrompts
@onready var center_stage_prompts = %CenterStagePrompts
@onready var stage_right_prompts = %StageRightPrompts

const HAPPINESS_METER_SECONDS = 60

# Desk State
var active_player = null
var players_in_desk_zone = []

# Stage State
var player_zones = {} # Map player -> zone_name

# Script State
var current_act_scenes = []
var global_position_context = "center" # Default start

# Prompt State
var active_prompt = null
var prompt_player = null
var prompt_zone = ""
var target_action_ref = null
static var expected_mask_id = -1

var nav_timer = 0.0
var nav_held_dir = 0
const NAV_REPEAT_INTERVAL = 0.5

const PROMPT_SCENE = preload("res://scenes/PromptList.tscn")

var is_game_over: bool = false
var game_timer_started: bool = false

func _ready():
  # Load script
  var data = PlayScriptLoader.load_playscript("res://assets/playscript-real.yml")
  var act1_data = null
  for act in data:
    if act.get("act") == 1:
      act1_data = act
      break
      
  if act1_data:
    current_act_scenes = act1_data.get("scene", [])
    render_act()
    
  # Setup Desk Interaction
  var interaction_area = $"Script Desk"
  if interaction_area:
    interaction_area.body_entered.connect(_on_desk_body_entered)
    interaction_area.body_exited.connect(_on_desk_body_exited)
    
  # Setup Stage Zones
  stage_left.body_entered.connect(func(b): _on_stage_zone_entered(b, "left"))
  stage_left.body_exited.connect(func(b): _on_stage_zone_exited(b, "left"))
  center_stage.body_entered.connect(func(b): _on_stage_zone_entered(b, "center"))
  center_stage.body_exited.connect(func(b): _on_stage_zone_exited(b, "center"))
  stage_right.body_entered.connect(func(b): _on_stage_zone_entered(b, "right"))
  stage_right.body_exited.connect(func(b): _on_stage_zone_exited(b, "right"))

  # Connect Players
  var actor1 = $"Actor 1"
  var actor2 = $"Actor 2"
  if actor1: actor1.interact_pressed.connect(func(): _on_player_interact(actor1))
  if actor2: actor2.interact_pressed.connect(func(): _on_player_interact(actor2))
  
  # setup timer actions
  TimeManager.on_time_up = _on_time_up

func _input(event):
  if active_prompt != null and prompt_player != null:
    # Check if input is from the prompt player
    if is_input_for_player(event, prompt_player):
      get_viewport().set_input_as_handled()
      
      var is_up = false
      var is_down = false
      var is_confirm = false
      
      if event is InputEventKey:
        # Strict key checking based on player ID
        if prompt_player.player_id == 1:
          if Input.is_action_just_pressed("player_1_w"): is_up = true
          if Input.is_action_just_pressed("player_1_s"): is_down = true
          if event.pressed and event.keycode == KEY_SPACE: is_confirm = true
        elif prompt_player.player_id == 2:
          if event.pressed:
            if event.keycode == KEY_UP: is_up = true
            if event.keycode == KEY_DOWN: is_down = true
            if event.keycode == KEY_BACKSPACE: is_confirm = true
        
      elif event is InputEventJoypadButton and event.pressed:
        if event.button_index == JOY_BUTTON_DPAD_UP: is_up = true
        if event.button_index == JOY_BUTTON_DPAD_DOWN: is_down = true
        if event.button_index == JOY_BUTTON_A: is_confirm = true
      
      # Joystick motion handled in _process for debounce
      
      # Handle actions
      if is_up:
        active_prompt.select_prev()
      elif is_down:
        active_prompt.select_next()
      elif is_confirm:
        verify_action()

func is_input_for_player(event, player):
  var device = -1
  if player.player_id == 1: device = GameManager.p1_device
  else: device = GameManager.p2_device
  
  if device == -2: # Keyboard
    if event is InputEventKey:
      return true
  else:
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
      return event.device == device
  return false

var interact_cooldown_timers = {}

func _process(delta):
  # Prompt Navigation (Joystick)
  if active_prompt and prompt_player:
    handle_prompt_joystick_nav(delta)

  # Decrement cooldowns
  for player in interact_cooldown_timers.keys():
    if interact_cooldown_timers[player] > 0:
      interact_cooldown_timers[player] -= delta
      if interact_cooldown_timers[player] < 0:
        interact_cooldown_timers[player] = 0

func _on_player_interact(player):
  if active_prompt != null:
    return # Handled by _input
    
  # Check Cooldown
  if interact_cooldown_timers.get(player, 0) > 0:
    return

  # Check Desk
  if player in players_in_desk_zone:
    handle_desk_interact(player)
    return
    
  # Check Stage
  if player in player_zones:
    try_start_action(player, player_zones[player])

# --- Desk Logic ---
func _on_desk_body_entered(body):
  if body is CharacterBody2D and "player_id" in body:
    if not body in players_in_desk_zone:
      players_in_desk_zone.append(body)

func _on_desk_body_exited(body):
  if body in players_in_desk_zone:
    players_in_desk_zone.erase(body)

func handle_desk_interact(player):
  if active_player == player:
    active_player.can_move = true
    active_player = null
    if playscript_layer: playscript_layer.visible = false
    return
    
  if active_player == null:
    active_player = player
    player.can_move = false
    if playscript_layer: playscript_layer.visible = true

# --- Stage Logic ---
func _on_stage_zone_entered(body, zone):
  if body is CharacterBody2D and "player_id" in body:
    player_zones[body] = zone

func _on_stage_zone_exited(body, zone):
  if body in player_zones and player_zones[body] == zone:
    player_zones.erase(body)

func try_start_action(player, zone):
  var target = get_next_action_target()
  if not target:
    print("No active action")
    return
    
  # Create prompts
  var line = target.action["line"]
  var slips = target.action.get("slips", []).duplicate()
  
  var options = [line] + slips
  options.shuffle()
  
  var prompt_parent = null
  match zone:
    "left": prompt_parent = stage_left_prompts
    "center": prompt_parent = center_stage_prompts
    "right": prompt_parent = stage_right_prompts
    
  if prompt_parent:
    var prompt = PROMPT_SCENE.instantiate()
    prompt_parent.add_child(prompt)
    prompt.setup(options)
    
    active_prompt = prompt
    prompt_player = player
    prompt_zone = zone
    target_action_ref = target
    
    nav_held_dir = 0
    nav_timer = 0
    
    player.can_move = false

func verify_action():
  if not active_prompt or not target_action_ref:
    close_prompt()
    return
    
  var selected_text = active_prompt.get_selected_option()
  var correct_text = target_action_ref.action["line"]
  
  # Check 1: Line
  if selected_text != correct_text:
    print("Boo: Wrong line")
    close_prompt()
    return
    
  # Check 2: Position
  if prompt_zone != target_action_ref.required_position:
    print("Boo: Wrong position (Expected %s, got %s)" % [target_action_ref.required_position, prompt_zone])
    close_prompt()
    return
    
  # Check 3: Mask
  var player_mask_id = prompt_player.maskID
    
  if player_mask_id != expected_mask_id:
    print("Boo: Wrong mask (Expected %d, got %d)" % [expected_mask_id, player_mask_id])
    close_prompt()
    return
    
  # Success!
  complete_action()

func complete_action():
  # Update global position context in case next scene relies on it
  global_position_context = target_action_ref.required_position
  
  # Success! Add some time to the timer
  if not game_timer_started:
    TimeManager.start_timer(HAPPINESS_METER_SECONDS)
    game_timer_started = true
  else:
    TimeManager.add_time(10)
  
  # Remove action from data
  var scene = current_act_scenes[target_action_ref.scene_index]
  var actions = scene[0]["actions"]
  actions.remove_at(target_action_ref.action_index)
  


  
  
  # Check if scene is cleared of lines
  var has_lines = false
  for a in actions:
    if a.has("line"):
      has_lines = true
      break
  
  if not has_lines:
    # check if the actual scene is also done, or if we are just switching masks
    scene.remove_at(0)
    if scene.size() == 0:
      current_act_scenes.remove_at(target_action_ref.scene_index)
      
    # Check if Act is Complete (no scenes left)
    if current_act_scenes.is_empty():
      print("Game Completed")
      await get_tree().create_tween().tween_property($".", "modulate", Color.BLACK, 2.0).finished
      get_tree().change_scene_to_file("res://scenes/TheEndScene.tscn")
      return

    # remove the halo and add a new one if the mask changes
    if expected_mask_id != current_act_scenes[0][0]["mask"]:
      prompt_player.get_node("CurrentCostume").visible = false
      expected_mask_id = current_act_scenes[0][0]["mask"]  # set the new costume to be grabbed
  else:
    # figure out the halo logic from the current setup instead
    if expected_mask_id != scene[0]["mask"]:
      prompt_player.get_node("CurrentCostume").visible = false
      expected_mask_id = scene[0]["mask"]  # set the new costume to be grabbed

    
  render_act()
  close_prompt()

func close_prompt():
  if active_prompt:
    active_prompt.queue_free()
  active_prompt = null
  if prompt_player:
    prompt_player.can_move = true
    # Set cooldown to prevent immediate re-trigger
    interact_cooldown_timers[prompt_player] = 0.5
    
  prompt_player = null
  prompt_zone = ""
  target_action_ref = null

# --- Helper ---
func get_next_action_target():
  var pos_ctx = global_position_context
  
  for s_idx in range(current_act_scenes.size()):
    var scene = current_act_scenes[s_idx]
    var actions = scene[0].get("actions", [])
    for a_idx in range(actions.size()):
      var action = actions[a_idx]
      if action.has("position"):
        pos_ctx = action["position"]
      elif action.has("line"):
        return {
          "scene_index": s_idx,
          "action_index": a_idx,
          "scene_item": scene,
          "action": action,
          "required_position": pos_ctx
        }
        
  return null

func render_act():
  for c in action_list.get_children():
    c.queue_free()
   
  var i = 1 
  for scene_item in current_act_scenes:
    # make the scene change line
    var newScene = preload("res://scenes/PlayScriptAction.tscn").instantiate()
    action_list.add_child(newScene)
    var maskList = []
    for action_item in scene_item:
      var mask_id = action_item.get("mask", 1)
      if mask_id not in maskList:
        maskList.append(mask_id)
    
    newScene.setupSceneStart(i,maskList)
    i=i+1
    for action_item in scene_item:
      var mask_id = action_item.get("mask", 1)
      var actions = action_item.get("actions", [])
      var row = preload("res://scenes/PlayScriptAction.tscn").instantiate()
      action_list.add_child(row)
      row.setup(mask_id, actions)
    
  # setup the first mask to be chosen
  expected_mask_id = current_act_scenes[0][0].mask

func handle_prompt_joystick_nav(delta):
  var device = -1
  if prompt_player.player_id == 1: device = GameManager.p1_device
  else: device = GameManager.p2_device
  
  if device >= 0:
    var y_axis = Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
    var current_dir = 0
    
    if y_axis < -0.5: current_dir = -1
    elif y_axis > 0.5: current_dir = 1
    
    if current_dir != 0:
      if current_dir != nav_held_dir:
        # First press
        nav_held_dir = current_dir
        nav_timer = NAV_REPEAT_INTERVAL
        if current_dir == -1: active_prompt.select_prev()
        else: active_prompt.select_next()
      else:
        # Holding
        nav_timer -= delta
        if nav_timer <= 0:
          nav_timer = NAV_REPEAT_INTERVAL
          if current_dir == -1: active_prompt.select_prev()
          else: active_prompt.select_next()
    else:
      # Released
      nav_held_dir = 0
      nav_timer = 0


func _on_time_up():
    # TimeManager calls this when we're out of time, set up game over screen
    print("Time up signal received")
    if is_game_over:
      return  # Prevent multiple triggers
    is_game_over = true
    
    # make game over overlay live
    self.get_node("GameOverText").visible = true
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color.BLACK, 5.0)
    tween.tween_callback(change_scene)

func change_scene():
  get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
