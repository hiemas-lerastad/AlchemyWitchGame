class_name MortarPestle;
extends ObjectContainer;

@export var pestle_position: Node3D;
@export var pestle: Moveable;
@export var pestle_trigger: Trigger;
@export var is_grinding: bool = false;
@export var combined_item_scene: PackedScene;
@export var combined_item_position: Node3D;
@export var animation_player: AnimationPlayer;
@export var grab_position: Node3D;

var combined_item: CombinedIngredient;
var has_combined_item: bool = false;
var process_time: float = 0.0;
var finished: bool = false;
var initial_hand_transform: Transform3D; 

func _custom_ready() -> void:
	pestle_trigger.connect("fire_trigger", _handle_pestle_trigger);

func _custom_add_handler(item: Moveable):
	finished = false;
	process_time = 0.0;

	if not combined_item and item is CombinedIngredient:
		has_combined_item = true;
		combined_item = item;
		add_child(item);
		contained_items.append(combined_item);
		combined_item.position = combined_item_position.position;
	elif not combined_item:
		has_combined_item = true;
		combined_item = combined_item_scene.instantiate();
		add_child(combined_item);
		contained_items.append(combined_item);
		combined_item.position = combined_item_position.position;

	if item != combined_item and item is not CombinedIngredient:
		combined_item.contained_items.append(item);
		remove_specific_item(item);
	elif item != combined_item:
		for nested_item in item.contained_items:
			combined_item.contained_items.append(nested_item);
			remove_specific_item(nested_item);

		remove_specific_item(item);

	combined_item.process_items();

func _custom_remove_specific_item_handler(item: Moveable) -> void:
	if item == combined_item:
		combined_item = null;
		has_combined_item = false;
		process_time = 0.0;
		finished = false;

func _handle_pestle_trigger(_id: String, _trigger: Node):
	if not is_grinding:
		pestle_trigger.collision_layer = Globals.COLLISION_LAYERS.NONE;
		is_grinding = true;
		GLOBALS.hand.is_free = false;
		GLOBALS.hand.reparent(pestle_position, true);
		GLOBALS.hand.set_state("Hold Vertical");
		animation_player.play("Pestle Grind");

func is_powder(item: Moveable) -> bool:
	return item.tags.find("ingredient_powder") != -1;

func grind_items(_event: int) -> void:
	if has_combined_item and combined_item.contained_items.size() > 0:
			#process_time += delta;
			#if process_time > 3.0:
		finished = true;
		var new_contained_items: Array = combined_item.contained_items.duplicate();
		
		for index in combined_item.contained_items.size():
			var item: Moveable = combined_item.contained_items[index];

			if item is Ingredient:
				if item.recipes and item.recipes[recipes_tag]:
					var new_item = item.recipes[recipes_tag].instantiate();
					new_item.update_color();
					new_contained_items.remove_at(index);
					item.queue_free();
					new_contained_items.insert(index, new_item)

		combined_item.contained_items = new_contained_items;

		combined_item.process_items();
	is_grinding = false;
	pestle_trigger.collision_layer = Globals.COLLISION_LAYERS.INTERACTABLE;
	GLOBALS.hand.is_free = true;
	GLOBALS.hand.set_desired_position(GLOBALS.player.hold_container.global_position);
	GLOBALS.hand.reparent(GLOBALS.player.hold_container, true);
	GLOBALS.hand.rotation = Vector3.ZERO;
	GLOBALS.hand.set_state("Rest");

func _custom_process(_delta: float) -> void:
	if is_grinding:
		GLOBALS.hand.set_desired_position(grab_position.global_position);

	pestle.set_desired_position(pestle_position.global_position);
