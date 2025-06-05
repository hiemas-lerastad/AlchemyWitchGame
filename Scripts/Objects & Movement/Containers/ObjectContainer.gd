class_name ObjectContainer;
extends Moveable;

@export var valid_item_tags: Array[String];
@export var excluded_item_tags: Array[String];
@export var enable_move: bool = false;
@export var interaction_type: Globals.CONTAINER_INTERACTIONS = Globals.CONTAINER_INTERACTIONS.NONE;

@export_subgroup("Liquid")
@export var liquid_increase_on_item_added: bool = false;
@export var liquid_increase_amount: float = 0.0;
@export var associated_color: Color;

@export_subgroup("Crafting")
@export var recipes_tag: String;

var contained_items: Array;
var current_attributes: Array[Attribute];

func check_item_validity(item: Moveable) -> bool:
	var valid_tags: bool = false;
	var excluded_tags: bool = true;

	for tag in item.tags:
		if valid_item_tags.find(tag) != -1:
			valid_tags = true;

		if excluded_item_tags.find(tag) != -1:
			excluded_tags = false;

	if not valid_item_tags.size() > 0:
		valid_tags = true;

	var custom_check: bool = _custom_validation_check(item);
	return valid_tags and custom_check and excluded_tags;

func _custom_validation_check(_item: Moveable) -> bool:
	return true;

func add_item(item: Moveable) -> void:
	if item.get_parent_node_3d():
		item.get_parent_node_3d().remove_child(item);

	contained_items.append(item);

	process_input();

	_custom_add_handler(item);

	if increment_liquid_amount and liquid_manager:
		var increase_amount: int = 1;

		if item is CombinedIngredient:
			increase_amount = item.contained_items.size();

		increment_liquid_amount(increase_amount);

func _custom_add_handler(_item: Moveable) -> void:
	pass;

func get_interaction() -> bool:
	return interaction_type;

func remove_last_item():
	var item: Moveable = contained_items.back();
	if contained_items.size() > 0:
		contained_items.remove_at(contained_items.size() - 1);
		_custom_remove_last_item_handler(item);
		return item;

func _custom_remove_last_item_handler(_item: Moveable) -> void:
	pass;

func remove_specific_item(item: Moveable):
	var item_index: int = contained_items.find(item);
	if item_index != -1:
		contained_items.remove_at(item_index);

		_custom_remove_specific_item_handler(item);

		return item;

	return false;

func _custom_remove_specific_item_handler(_item: Moveable) -> void:
	pass;

func increment_liquid_amount(increment: int):
	if liquid_manager:
		var fill_amount: float = liquid_manager.fill_amount;
		fill_amount += liquid_increase_amount * increment;
		set_liquid_amount(fill_amount);

func process_input() -> void:
	var new_attributes: Array[Attribute] = [];
	var output_color: Color;

	for index in contained_items.size():
		var item: Moveable = contained_items[index];

		if item is Ingredient:
			item.update_color();

			new_attributes.append_array(item.attributes);

			var new_color: Color = item.associated_color;
			new_color.a = 1.0 / (index + 1);

			if not output_color:
				output_color = new_color;
			else:
				output_color = output_color.blend(new_color);
		elif item is CombinedIngredient:
			new_attributes.append_array(item.attributes);
			
			var new_color: Color = item.associated_color;
			new_color.a = 1.0 / (index + 1);

			if not output_color:
				output_color = new_color;
			else:
				output_color = output_color.blend(new_color);

	current_attributes = new_attributes;
	associated_color = output_color;

	if liquid_manager:
		liquid_manager.set_liquid_color(associated_color);
