class_name Foreground;
extends SubViewport;

var screen_size: Vector2;

func _ready() -> void:
	_resize();
	get_tree().get_root().size_changed.connect(_resize);
	
func _resize() -> void:
	screen_size = get_window().size;
	size = screen_size;
