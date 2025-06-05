class_name SpringGimbal;
extends Node3D;

@export_flags_3d_physics var ray_collision_mask: int = 1:
	set(value):
		ray_collision_mask = value;
		_set_ray_mask(value);
	get():
		return _get_ray_mask();

@export_custom(PROPERTY_HINT_NONE, "suffix:m") var spring_length: float = 1.0:
	set(value):
		spring_length = value;

@export_custom(PROPERTY_HINT_NONE, "suffix:m") var margin: float = 0.1;


@export_subgroup("Shape")
@export var shape: Shape3D:
	set(value):
		_set_debug_shape(value);
		shape = value;

@export_flags_3d_physics var shape_collision_mask: int = 1:
	set(value):
		shape_collision_mask = value;
		_set_shape_mask(value);
	get():
		return _get_shape_mask();

@export var override_shape_basis: bool = false;

@export var shape_transform_locked: Transform3D:
	set(value):
		_set_debug_transform(value);
		shape_transform_locked = value;

@export var shape_lock_rotation_x: bool = false;

@export var shape_lock_rotation_y: bool = false;

@export var shape_lock_rotation_z: bool = false;


@export_subgroup("Child Properties")
@export var child_lock_rotation_x: bool = false;

@export var child_lock_rotation_y: bool = false;

@export var child_lock_rotation_z: bool = false;

var child_basis_locked: Dictionary;
var collision_node: Area3D;

var collision: Dictionary;

var ray_mask: int = 1;
var shape_mask: int = 1;
var current_spring_length: float;
var keep_child_basis: bool = false;

func _ready() -> void:
	if child_lock_rotation_x or child_lock_rotation_y or child_lock_rotation_z:
		_init_child_data(null);
	
	connect("child_entered_tree", _init_child_data);
	connect("child_exiting_tree", _init_child_data);

	collision_node = Area3D.new();
	collision_node.collision_layer = 0;
	collision_node.add_to_group("Util");

	var collision_shape: CollisionShape3D = CollisionShape3D.new();
	collision_shape.shape = shape;
	collision_node.add_child(collision_shape);
	add_child(collision_node);

	collision_node.global_transform = get_children()[0].global_transform;

	if shape_lock_rotation_x or shape_lock_rotation_y or shape_lock_rotation_z:
		collision_node.global_transform = shape_transform_locked;

func _init_child_data(_data) -> void:
	var children: Array = get_children();
	for i: int in range(get_child_count()):
		if children[i] is Node3D and not children[i].is_in_group("Util"):
			var child: Node3D = children[i];
			var child_rid = child.get_instance_id();
			child_basis_locked[child_rid] = child.global_transform;

func _set_ray_mask(value: int) -> void:
	ray_mask = value;

func _get_ray_mask() -> int:
	return ray_mask;
	
func _set_shape_mask(value: int) -> void:
	shape_mask = value;
	
	if collision_node:
		collision_node.collision_mask = value;

func _get_shape_mask() -> int:
	return shape_mask;

func _set_debug_shape(new_shape: Shape3D) -> void:
	if collision_node:
		collision_node.get_child(0).shape = new_shape;

func _set_debug_transform(new_transform: Transform3D) -> void:
	if collision_node:
		collision_node.global_transform = new_transform;

func _physics_process(delta: float) -> void:
	_process_spring(delta);

func _process_spring(_delta: float) -> void:
	var motion: Vector3;
	var cast_direction: Vector3 = global_basis * Vector3(0, 0, 1);
	
	var motion_delta: float = 1.0;
	var _motion_delta_unsafe: float = 1.0;

	motion = Vector3(cast_direction * spring_length);
	
	if !shape:
		var ray_params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new();
		ray_params.from = global_transform.origin;
		ray_params.to = global_transform.origin + motion;
		ray_params.collision_mask = ray_mask;

		var space_rid: RID = get_world_3d().space;
		var space_state: PhysicsDirectSpaceState3D = PhysicsServer3D.space_get_direct_state(space_rid);
		var ray_result: Dictionary = space_state.intersect_ray(ray_params);

		if "collider" in ray_result:
			var distance: float = global_transform.origin.distance_to(ray_result.position);
			distance -= margin;
			motion_delta = distance / (spring_length);
			
			collision = ray_result;
		else:
			collision = {};
	else:
		var shape_transform: Transform3D;
		shape_transform.origin = global_transform.origin;
		shape_transform.basis = collision_node.global_transform.basis;

		if (shape_lock_rotation_x and shape_lock_rotation_y) or (shape_lock_rotation_x and shape_lock_rotation_z) or (shape_lock_rotation_z and shape_lock_rotation_y):
			shape_transform.basis = shape_transform_locked.orthonormalized().basis;
		elif shape_lock_rotation_x or shape_lock_rotation_y or shape_lock_rotation_z:
			var axis: String = 'z';
			if shape_lock_rotation_x:
				axis = 'y';
			elif shape_lock_rotation_y:
				axis = 'x'

			var current_transform: Transform3D = shape_transform.orthonormalized()
			var cached_transform: Transform3D = shape_transform_locked.orthonormalized()
			var lock: Quaternion = Quaternion(cached_transform.basis[axis], current_transform.basis[axis])
			var locked_transform: Transform3D = Transform3D(Basis(current_transform.basis.x * lock, current_transform.basis.y * lock, current_transform.basis.z * lock), current_transform.origin)
			shape_transform = locked_transform;

		var shape_params: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new();
		shape_params.shape_rid = shape.get_rid();
		shape_params.transform = shape_transform;
		shape_params.motion = motion;
		shape_params.collision_mask = shape_mask;

		var space_rid: RID = get_world_3d().space;
		var space_state: PhysicsDirectSpaceState3D = PhysicsServer3D.space_get_direct_state(space_rid);
		var collision_distances: PackedFloat32Array = space_state.cast_motion(shape_params);
		motion_delta = collision_distances[0];
		_motion_delta_unsafe = collision_distances[1];

		shape_params.transform.origin = global_transform.origin + cast_direction * ((spring_length + margin + 0.1) * motion_delta);
		collision = space_state.get_rest_info(shape_params);
		print('here')

	current_spring_length = spring_length * motion_delta;
	var child_transform: Transform3D;
	child_transform.origin = global_transform.origin + cast_direction * (spring_length * motion_delta);

	var children: Array = get_children();
	for i: int in range(get_child_count()):
		if children[i] is Node3D:
			var child: Node3D = children[i];
			var child_rid = child.get_instance_id();

			if not child.is_in_group("Util"):
				child_transform.basis = child.global_transform.basis;

				if (child_lock_rotation_x and child_lock_rotation_y) or (child_lock_rotation_x and child_lock_rotation_z) or (child_lock_rotation_z and child_lock_rotation_y):
					child_transform.basis = child_basis_locked[child_rid].orthonormalized().basis
				elif child_lock_rotation_x or child_lock_rotation_y or child_lock_rotation_z:
					var axis = 'z';
					if child_lock_rotation_x:
						axis = 'y';
					elif child_lock_rotation_y:
						axis = 'x'

					var current_transform: Transform3D = child_transform.orthonormalized()
					var cached_transform: Transform3D = child_basis_locked[child_rid].orthonormalized()
					var lock: Quaternion = Quaternion(cached_transform.basis[axis], current_transform.basis[axis])
					var locked_transform: Transform3D = Transform3D(Basis(current_transform.basis.x * lock, current_transform.basis.y * lock, current_transform.basis.z * lock), current_transform.origin)
					child_transform = locked_transform;

				child.global_transform = child_transform;
			else:
				var shape_transform: Transform3D;
				shape_transform.origin = child_transform.origin;
				shape_transform.basis = collision_node.global_transform.basis;

				if (shape_lock_rotation_x and shape_lock_rotation_y) or (shape_lock_rotation_x and shape_lock_rotation_z) or (shape_lock_rotation_z and shape_lock_rotation_y):
					shape_transform.basis = shape_transform_locked.orthonormalized().basis;
				elif shape_lock_rotation_x or shape_lock_rotation_y or shape_lock_rotation_z:
					var axis: String = 'z';
					if shape_lock_rotation_x:
						axis = 'y';
					elif shape_lock_rotation_y:
						axis = 'x'

					var current_transform: Transform3D = shape_transform.orthonormalized()
					var cached_transform: Transform3D = shape_transform_locked.orthonormalized()
					var lock: Quaternion = Quaternion(cached_transform.basis[axis], current_transform.basis[axis])
					var locked_transform: Transform3D = Transform3D(Basis(current_transform.basis.x * lock, current_transform.basis.y * lock, current_transform.basis.z * lock), current_transform.origin)
					shape_transform = locked_transform;

				collision_node.global_transform = shape_transform;
