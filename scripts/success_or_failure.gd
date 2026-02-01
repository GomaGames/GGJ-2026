extends Node2D


func success():
    show()
    get_node("Success").show()
    var tween = create_tween()
    tween.tween_property(get_node("Success"), "modulate:a", 0.0, 0.6).from(1.0)
    tween.finished.connect(hide)


func failure():
    show()
    get_node("Failure").show()
    var tween = create_tween()
    tween.tween_property(get_node("Failure"), "modulate:a", 0.0, 0.6).from(1.0)
    tween.finished.connect(hide)
