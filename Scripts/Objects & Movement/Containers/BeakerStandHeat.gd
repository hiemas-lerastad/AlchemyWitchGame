class_name BeakerStandHeat;
extends ObjectContainer;

@export var beaker_position: Node3D;
@export var is_heating: bool = false;
@export var wick_trigger: Trigger;
@export var wick_material: Material;
@export var light: OmniLight3D;

var has_beaker: bool = false;
var beaker: Moveable;
var process_time: float = 0.0;
var finished: bool = false;

func _custom_ready() -> void:
	wick_trigger.connect("fire_trigger", _handle_wick_trigger);

func _handle_wick_trigger(_id: String, _trigger: Node):
	if is_heating:
		unset_processing();
	else:
		set_processing();

func _custom_add_handler(item: Moveable):
	if item.tags.find("container_beaker") != -1 and not has_beaker:
		has_beaker = true;
		beaker = item;
		add_child(item);
		beaker.position = beaker_position.position
		beaker.set_desired_position(beaker_position.global_position);
	else:
		beaker.add_item(item);
		remove_specific_item(item);

	finished = false;
	process_time = 0.0;
	
func _custom_remove_specific_item_handler(item: Moveable) -> void:
	if item == beaker:
		beaker = null;
		has_beaker = false;
		process_time = 0.0;
		finished = false;

func _custom_validation_check(item: Moveable) -> bool:
	if item.tags.find("container_beaker") != -1 and not has_beaker:
		return true;
	elif has_beaker:
		for tag in item.tags:
			if beaker.valid_item_tags.find(tag) != -1:
				return true;

	return false;

func set_processing() -> void:
	light.visible = true;
	is_heating = true;
	wick_material.set_shader_parameter("albedo", Vector3(1.0, 0.0, 0.0));

func unset_processing() -> void:
	light.visible = false;
	is_heating = false;
	wick_material.set_shader_parameter("albedo", Vector3(0.0, 0.0, 0.0));

func process_items(delta: float) -> void:
	if is_heating and has_beaker and not finished:
		if beaker.contained_items.size() > 0:
			process_time += delta;
			if process_time > 3.0:
				finished = true;
				var new_contained_items: Array = beaker.contained_items.duplicate();

				for index in beaker.contained_items.size():
					var item: Moveable = beaker.contained_items[index];

					if item is Ingredient:
						if item.recipes and item.recipes[recipes_tag]:
							var new_item = item.recipes[recipes_tag].instantiate();
							new_contained_items.remove_at(index);
							item.queue_free();
							new_contained_items.insert(index, new_item)

				beaker.contained_items = new_contained_items;

				beaker.process_input();

func _custom_process(delta: float) -> void:
	process_items(delta);
