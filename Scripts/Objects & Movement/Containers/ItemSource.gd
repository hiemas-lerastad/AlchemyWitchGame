class_name ItemSource;
extends ObjectContainer;

@export var item_scene: PackedScene;

func _custom_ready() -> void:
	var new_item = item_scene.instantiate();
	contained_items.append(new_item);

func _custom_add_handler(item: Moveable) -> void:
	remove_specific_item(item);

func _custom_validation_check(item: Moveable) -> bool:
	if item is ObjectContainer:
		if item.contained_items.size() == 0:
			return true;

	return false;

func _custom_remove_last_item_handler(_item: Moveable) -> void:
	var new_item = item_scene.instantiate();
	contained_items.append(new_item);
