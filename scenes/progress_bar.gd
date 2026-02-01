extends ProgressBar

func _ready():
    # Connect to static TimeManager signals
    TimeManager.on_time_changed = _on_time_changed
    TimeManager.on_time_up = _on_time_up
    
    # Initial setup
    max_value = 100
    value = 100
    
    # Optional: Show initial time
    _on_time_changed(TimeManager.current_time, TimeManager.max_time)

func _on_time_changed(current_time: float, max_time: float):
    # Update progress bar (0-100)
    var percentage = (current_time / max_time) * 100
    value = percentage
    
    # Optional: Color feedback
    if percentage < 10:
        modulate = Color.RED
    elif percentage < 30:
        modulate = Color.ORANGE
    elif percentage < 60:
        modulate = Color.YELLOW
    else:
        modulate = Color.GREEN

func _on_time_up():
    value = 0
    modulate = Color.RED

func _process(delta):
  TimeManager.update(delta)
