class_name SmoothRemoteTransform3D;
extends Node3D;

@export var movement_speed: float = 10;
@export var remote_path: Node;
@export var disabled: bool = false;

var current_position: Vector3;
var desired_position: Vector3;
var time: float = 0.0;

func _ready() -> void:
	if remote_path:
		current_position = remote_path.position;
		desired_position = current_position;

func set_remote_path(node: Node) -> void:
	if node:
		remote_path = node;
		current_position = remote_path.position;
		desired_position = current_position;

func _physics_process(delta: float) -> void:
	if remote_path:
		time += delta * movement_speed;

		if desired_position != remote_path.position:
			remote_path.position = current_position.lerp(desired_position, time);

		if global_position != remote_path.global_position:
			set_desired_position(global_position);

func set_desired_position(new_position: Vector3) -> void:
	current_position = remote_path.position;
	time = 0.0;

	if disabled:
		desired_position = current_position;
	else:
		desired_position = remote_path.get_parent_node_3d().to_local(new_position);
