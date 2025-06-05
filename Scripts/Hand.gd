class_name Hand;
extends Moveable;

@export var animation_tree: AnimationTree;
@export var animation_player: AnimationPlayer;
@export var animation_duration: float = 0.3;

var animation_time: float = 0.0;
var previous_state: String = "Rest";
var current_state: String = "Rest";
var is_free: bool = true;

func _custom_ready() -> void:
	GLOBALS.hand = self;

func _process(delta: float) -> void:
	if current_state != previous_state and animation_time <= animation_duration:
		animation_time += delta;

		if current_state == "Grab":
			animation_tree.set("parameters/Grab Blend/blend_amount", animation_time / animation_duration);
			animation_tree.set("parameters/Point Blend/blend_amount", clamp(animation_tree.get("parameters/Point Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));
			animation_tree.set("parameters/Grabbable Blend/blend_amount", clamp(animation_tree.get("parameters/Grabbable Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));
			animation_tree.set("parameters/Hold Vertical Blend/blend_amount", clamp(animation_tree.get("parameters/Hold Vertical Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));

		elif current_state == "Point":
			animation_tree.set("parameters/Point Blend/blend_amount", animation_time / animation_duration);
			animation_tree.set("parameters/Grab Blend/blend_amount", clamp(animation_tree.get("parameters/Grab Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));
			animation_tree.set("parameters/Grabbable Blend/blend_amount", clamp(animation_tree.get("parameters/Grabbable Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));
			animation_tree.set("parameters/Hold Vertical Blend/blend_amount", clamp(animation_tree.get("parameters/Hold Vertical Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));

		elif current_state == "Grabbable":
			animation_tree.set("parameters/Grabbable Blend/blend_amount", animation_time / animation_duration);
			animation_tree.set("parameters/Point Blend/blend_amount", clamp(animation_tree.get("parameters/Point Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));
			animation_tree.set("parameters/Grab Blend/blend_amount", clamp(animation_tree.get("parameters/Grab Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));
			animation_tree.set("parameters/Hold Vertical Blend/blend_amount", clamp(animation_tree.get("parameters/Hold Vertical Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));

		elif current_state == "Hold Vertical":
			animation_tree.set("parameters/Grabbable Blend/blend_amount", clamp(animation_tree.get("parameters/Grabbable Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));
			animation_tree.set("parameters/Point Blend/blend_amount", clamp(animation_tree.get("parameters/Point Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));
			animation_tree.set("parameters/Grab Blend/blend_amount", clamp(animation_tree.get("parameters/Grab Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));
			animation_tree.set("parameters/Hold Vertical Blend/blend_amount", animation_time / animation_duration)

		else:
			animation_tree.set("parameters/Point Blend/blend_amount", clamp(animation_tree.get("parameters/Point Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));
			animation_tree.set("parameters/Grab Blend/blend_amount", clamp(animation_tree.get("parameters/Grab Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));
			animation_tree.set("parameters/Grabbable Blend/blend_amount", clamp(animation_tree.get("parameters/Grabbable Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));
			animation_tree.set("parameters/Hold Vertical Blend/blend_amount", clamp(animation_tree.get("parameters/Hold Vertical Blend/blend_amount") - delta / animation_duration, 0.0, 1.0));

func set_state(state: String) -> void:
	if current_state != state:
		previous_state = current_state;
		current_state = state;
		animation_time = 0.0;
