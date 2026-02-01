class_name TimeManager

# Static variables - accessible everywhere
static var max_time: float = 120.0
static var current_time: float = 120.0
static var is_running: bool = false

# Static signals using Callables (Godot 4 style)
static var on_time_changed: Callable
static var on_time_up: Callable

# Timer reference
static var _timer: Timer

# Main function to start the timer
static func start_timer(seconds: float):
    """Call this to start the timer!"""
    max_time = seconds
    current_time = seconds
    is_running = true
    
    print("Timer started: ", seconds, " seconds")
    
    # Emit initial time changed
    _emit_time_changed()

# Update function (call this from somewhere!)
static func update(delta: float):
    if not is_running:
        return
    
    current_time -= delta
    current_time = max(0, current_time)
    
    _emit_time_changed()
    
    if current_time <= 0:
        _emit_time_up()
        is_running = false

# Helper functions
static func pause():
    is_running = false

static func resume():
    is_running = true

static func add_time(seconds: float):
    current_time += seconds
    _emit_time_changed()

static func stop():
    is_running = false
    current_time = 0
    _emit_time_changed()

static func reset():
    is_running = false
    current_time = max_time
    _emit_time_changed()

# Signal emitters
static func _emit_time_changed():
    if on_time_changed:
        on_time_changed.call(current_time, max_time)

static func _emit_time_up():
    if on_time_up:
        on_time_up.call()

# Getters
static func get_percentage() -> float:
    return current_time / max_time if max_time > 0 else 0.0

static func get_formatted_time() -> String:
    var minutes = int(current_time) / 60
    var seconds = int(current_time) % 60
    return "%02d:%02d" % [minutes, seconds]
