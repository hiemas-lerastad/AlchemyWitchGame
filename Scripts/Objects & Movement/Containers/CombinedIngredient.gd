class_name CombinedIngredient;
extends ObjectContainer;

@export var mortar_ingredient: MeshInstance3D;
@export var mortar_powder: MeshInstance3D;

var mortar_ingredient_color: Color;
var mortar_ingredient_materials: Array[Material];
var mortar_powder_color: Color;
var mortar_powder_materials: Array[Material];
var attributes: Array[Attribute];

func _custom_ready() -> void:
	mortar_ingredient_materials = get_mesh_materials(mortar_ingredient);
	mortar_powder_materials = get_mesh_materials(mortar_powder);

func check_item_validity(item: Moveable) -> bool:
	return not item is CombinedIngredient;

func is_powder(item: Moveable) -> bool:
	return item.tags.find("ingredient_powder") != -1;

func process_items() -> void:
	tags = [];
	attributes = [];

	if contained_items.size() > 0:
		var powder_items: Array = contained_items.filter(is_powder);
		var solid_items: Array = contained_items.filter(func(item: Moveable): return not is_powder(item));

		mortar_powder.visible = powder_items.size() > 0;
		mortar_ingredient.visible = solid_items.size() > 0;

		var solid_output_color: Color;
		var powder_output_color: Color;

		for index in solid_items.size():
			var item = solid_items[index];
			var new_color: Color = item.associated_color;

			for tag in item.tags:
				if not tag in tags:
					tags.append(tag);

			attributes.append_array(item.attributes);

			if not solid_output_color:
				solid_output_color = new_color;
			else:
				new_color.a = 1.0 / (index + 1);
				solid_output_color = solid_output_color.blend(new_color)

		for index in powder_items.size():
			var item = powder_items[index];
			var new_color: Color = item.associated_color;

			for tag in item.tags:
				if not tag in tags:
					tags.append(tag);

			attributes.append_array(item.attributes);

			if not powder_output_color:
				powder_output_color = new_color;
			else:
				new_color.a = 1.0 / (index + 1);
				powder_output_color = powder_output_color.blend(new_color)

		mortar_ingredient_color = solid_output_color;
		mortar_powder_color = powder_output_color;
		
		associated_color = mortar_ingredient_color.blend(Color(mortar_powder_color, 0.5));

		for material in mortar_ingredient_materials:
			material.set_shader_parameter("albedo", mortar_ingredient_color);

		for material in mortar_powder_materials:
			material.set_shader_parameter("albedo", mortar_powder_color)
