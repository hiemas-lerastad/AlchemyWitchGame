class_name Moveable;
extends Node3D;

@export var movement_speed: float = 20;
@export var meshes: Array[MeshInstance3D];
@export var make_unique: bool = true;
@export var tags: Array[String];
@export var hover_state: Globals.INTERACTION_INDICATOR_TYPE = Globals.INTERACTION_INDICATOR_TYPE.NONE;
@export var hold_position: Node3D;
@export var hold_animation: String;

@export_subgroup("Liquid")
@export var liquid_manager: LiquidManager;
@export_range(0.0, 1.0) var liquid_min_amount: float = 0.0;
@export_range(0.0, 1.0) var liquid_max_amount: float = 1.0;
@export var liquid_hide_on_min: bool = true;

var last_position: Vector3;
var desired_position: Vector3;
var time: float = 0.0;
var materials: Array[Material] = [];
var materials_initalised: bool = false;

func _ready() -> void:
	last_position = position;
	desired_position = last_position;
	var new_materials: Array[Material] = [];

	if meshes.size() > 0 and make_unique:
		for mesh in meshes:
			if mesh.mesh:
				var new_mesh: Mesh = mesh.mesh.duplicate();
				mesh.mesh = new_mesh;

				for i in mesh.mesh.get_surface_count():
					var material: Material = mesh.mesh.surface_get_material(i);
					if material:
						var new_material = material.duplicate();
						mesh.mesh.surface_set_material(i, new_material);
						new_materials.append(new_material);

				if "material" in mesh.mesh:
					var material: Material = mesh.mesh.material;
					if material:
						var new_material = material.duplicate();
						mesh.mesh.material = new_material;
						new_materials.append(new_material);

	materials = new_materials;

	if liquid_manager:
		if liquid_manager.fill_amount <= liquid_min_amount and liquid_hide_on_min:
			liquid_manager.visible = false;
	
	_custom_ready();

func _custom_ready() -> void:
	pass;

func get_materials() -> Array[Material]:
	var new_materials: Array[Material] = [];
	
	for mesh in meshes:
		new_materials.append_array(get_mesh_materials(mesh));

	if liquid_manager:
		if liquid_manager.mesh:
			new_materials.append(liquid_manager.material_pass_1)
			new_materials.append(liquid_manager.material_pass_2)

	return new_materials;

func get_mesh_materials(current_mesh: MeshInstance3D) -> Array[Material]:
	var new_materials: Array[Material] = [];

	if current_mesh:
		if current_mesh.mesh:
			var new_mesh: Mesh = current_mesh.mesh;
			current_mesh.mesh = new_mesh;

			for i in current_mesh.mesh.get_surface_count():
				var material: Material = current_mesh.mesh.surface_get_material(i);
				if material:
					var new_material = material;
					current_mesh.mesh.surface_set_material(i, new_material);
					new_materials.append(new_material);

			if "material" in current_mesh.mesh:
				var material: Material = current_mesh.mesh.material;
				if material:
					var new_material = material;
					current_mesh.mesh.material = new_material;
					new_materials.append(new_material);

	return new_materials;

func _physics_process(delta: float) -> void:
	if not materials_initalised:
		var new_materials: Array[Material] = get_materials();

		if materials != new_materials:
			materials = new_materials;

		materials_initalised = true;

	time += delta * movement_speed;

	if desired_position != position:
		position = position.lerp(desired_position, time);
		last_position = position;
		time = 0.0;

	_custom_process(delta);

func _custom_process(_delta: float) -> void:
	pass;

func set_desired_position(new_position: Vector3) -> void:
	last_position = position;
	time = 0.0;
	if get_parent_node_3d():
		desired_position = get_parent_node_3d().to_local(new_position);
	else:
		desired_position = new_position;

func set_liquid_amount(amount: float):
	if amount > liquid_max_amount:
		amount = liquid_max_amount;
	if liquid_hide_on_min and not liquid_manager.visible and amount > liquid_min_amount:
		liquid_manager.visible = true;
	if liquid_manager:
		liquid_manager.fill_amount = amount;

func set_liquid_color(color: Color):
	if liquid_manager:
		liquid_manager.liquid_color = color;
