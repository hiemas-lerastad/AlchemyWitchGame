class_name Recipe;
extends Resource;

@export var id: int;
@export var input: Array[Attribute];
@export var output: Array[Attribute];
@export var special_output: PackedScene;

func is_valid(input_attributes: Array[Attribute]) -> Array[Attribute]:
	if input_attributes.size() < input.size():
		return [];
	for input_attribute in input:
		if not input_attributes.has(input_attribute):
			return [];
	return input;
