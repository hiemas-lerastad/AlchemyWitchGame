class_name Player;
extends CharacterBody3D;

@export_subgroup("External Nodes")
@export var hand: Hand;

@export_subgroup("Internal Nodes")
@export var pivot: Node3D;
@export var spring_arm: SpringGimbal;
@export var hold_position: SmoothRemoteTransform3D;
@export var hold_container: Node3D;
@export var interact_shape: Shape3D;
@export var hand_rest_position: Node3D;

var is_holding: bool = false;
var held_item: Node3D;

func _ready() -> void:
	GLOBALS.player = self;

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * 0.006)
			pivot.rotate_x(-event.relative.y * 0.006)
			pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func physics_player_interaction() -> void:
	if is_holding:
		held_item.set_desired_position(hold_container.global_position);
		if held_item.hold_position:
			hand.set_desired_position(held_item.hold_position.global_position);
		else:
			hand.set_desired_position(hold_container.global_position);
	elif hand.is_free:
		if not spring_arm.collision.is_empty():
			var collider: Node3D = instance_from_id(spring_arm.collision.collider_id);
			if "hover_state" in collider:
				if collider.hover_state == Globals.INTERACTION_INDICATOR_TYPE.GRAB:
					if collider is ObjectContainer and collider.contained_items.size() == 0 and not collider.enable_move:
						hand.set_state("Rest");
					else:
						hand.set_state("Grabbable");
				elif collider.hover_state == Globals.INTERACTION_INDICATOR_TYPE.POINT:
					hand.set_state("Point");
			else:
				hand.set_state("Rest");
		else: 
			hand.set_state("Rest");

		hand.set_desired_position(hand_rest_position.global_position);

	if Input.is_action_just_pressed("interact_press"):
		handle_interaction();

func _physics_process(_delta: float) -> void:
	physics_player_interaction();

func handle_interaction():
	print(is_holding)
	print(spring_arm.collision)
	if not is_holding and not spring_arm.collision.is_empty() and hand.is_free:
		var collider: Node3D = instance_from_id(spring_arm.collision.collider_id);

		if collider.is_in_group("Grabbable"):
			_set_held_item(collider, spring_arm.collision.shape, spring_arm.collision.position);
		elif not is_holding and collider is ObjectContainer and collider.is_in_group("Container"):
			var interaction_type: int = collider.interaction_type;

			if interaction_type == Globals.CONTAINER_INTERACTIONS.REMOVE_ITEM:
				var item: Moveable = collider.remove_last_item();
				if item:
					_set_held_item(item, spring_arm.collision.shape, spring_arm.collision.position);
			elif interaction_type == Globals.CONTAINER_INTERACTIONS.BEAKER:
				if collider.beaker:
					var item: Moveable = collider.remove_specific_item(collider.beaker);
					if item:
						_set_held_item(item, spring_arm.collision.shape, spring_arm.collision.position);
			elif interaction_type == Globals.CONTAINER_INTERACTIONS.COMBINED_ITEM:
				if collider.combined_item:
					var item: Moveable = collider.remove_specific_item(collider.combined_item);
					if item:
						_set_held_item(item, spring_arm.collision.shape, spring_arm.collision.position);
		elif collider is Trigger:
			collider.handle_interaction();

	elif is_holding and not spring_arm.collision.is_empty():
		var collider: Node3D = instance_from_id(spring_arm.collision.collider_id);
		if collider.is_in_group("Surface") or collider.is_in_group("Container"):
			_unset_held_item(collider, spring_arm.collision.normal);

func _set_held_item(object: Node3D, collider_id: int, collider_position: Vector3) -> void:
	var owner_id: int = object.shape_find_owner(collider_id)
	var collision_shape: CollisionShape3D = object.shape_owner_get_owner(owner_id);

	if object.is_in_group("Grabbable"):
		if object.hold_animation:
			hand.set_state(object.hold_animation);
		else:
			hand.set_state("Grab");

		is_holding = true;
		held_item = object;
		hold_position.disabled = false;

		if held_item.get_parent_node_3d():
			held_item.reparent(hold_container, true);
		else:
			hold_container.add_child(held_item);
			held_item.global_position = collider_position;

		held_item.collision_layer = 0;

		for material in held_item.materials:
			if material:
				material.set_shader_parameter("foreground", true);

		spring_arm.shape_transform_locked = collision_shape.global_transform;
		spring_arm.shape = collision_shape.shape;

func _unset_held_item(object_collider: Node3D, collision_normal: Vector3) -> void:
	print(collision_normal)
	if is_holding and object_collider.is_in_group("Surface") and (collision_normal == Vector3.UP or collision_normal == Vector3.DOWN):
		hand.set_state("Rest");
		is_holding = false;
		hold_position.disabled = true;
		held_item.reparent(GLOBALS.object_container, true)
		held_item.set_desired_position(hold_position.global_position);
		held_item.collision_layer = Globals.COLLISION_LAYERS.INTERACTABLE + Globals.COLLISION_LAYERS.GRABBABLE;

		for material in held_item.materials:
			if material:
				material.set_shader_parameter("foreground", false);

		held_item = null;
		spring_arm.shape = null;
		spring_arm.collision = {};
	elif is_holding and object_collider is ObjectContainer and object_collider.is_in_group("Container"):
		if object_collider.check_item_validity(held_item):
			hand.set_state("Rest");
			is_holding = false;
			hold_position.disabled = true;

			for material in held_item.materials:
				if material:
					material.set_shader_parameter("foreground", false);

			object_collider.add_item(held_item);

			held_item = null;
			spring_arm.shape = null;
			spring_arm.collision = {};
