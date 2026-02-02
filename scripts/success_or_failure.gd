extends Node2D

var audio_player: AudioStreamPlayer

func _ready():
    audio_player = AudioStreamPlayer.new()
    add_child(audio_player)

func success():
    show()
    get_node("Success").show()
    var tween = create_tween()
    tween.tween_property(get_node("Success"), "modulate:a", 0.0, 0.6).from(1.0)
    tween.finished.connect(hide)
    
    # Play applause
    var stream = preload("res://sfx/Applause.wav")
    audio_player.stream = stream
    
    var duration = stream.get_length()
    # Ensure we have at least 1 second to play
    var max_start = max(0.0, duration - 1.0)
    var start_pos = randf_range(0.0, max_start)
    
    audio_player.volume_db = -80.0
    audio_player.play(start_pos)
    
    # Fade in and out
    var audio_tween = create_tween()
    audio_tween.tween_property(audio_player, "volume_db", 0.0, 0.2)
    audio_tween.tween_interval(0.6)
    audio_tween.tween_property(audio_player, "volume_db", -80.0, 0.2)
    audio_tween.tween_callback(audio_player.stop)
    audio_tween.tween_callback(func(): audio_player.volume_db = 0.0)


func failure():
    show()
    get_node("Failure").show()
    var tween = create_tween()
    tween.tween_property(get_node("Failure"), "modulate:a", 0.0, 0.6).from(1.0)
    tween.finished.connect(hide)
    
    # Play gasp
    var stream = preload("res://sfx/gasp.wav")
    audio_player.stream = stream
    audio_player.volume_db = 0.0
    audio_player.play()
