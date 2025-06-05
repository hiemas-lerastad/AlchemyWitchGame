class_name Ingredient;
extends Moveable;

@export var attributes: Array[Attribute];
@export var recipes: RecipeList;

var associated_color: Color;

func _custom_ready() -> void:
	update_color();

func update_color() -> void:
	var new_color: Color;

	for index in attributes.size():
		var attribute: Attribute = attributes[index];
		var temp_color = attribute.color;
		temp_color.a = 1.0 / (index + 1);

		if not new_color:
			new_color = temp_color;
		else:
			new_color = new_color.blend(temp_color);

	associated_color = new_color;
