@tool
class_name LiquidManager;
extends MeshInstance3D;

@export_range(0.0, 1.0) var fill_amount: float:
	set(value):
		set_fill_amount(value);
		fill_amount = value;
	get():
		return get_fill_amount();

@export var glass_thickness: float:
	set(value):
		set_glass_thickness(value);
		glass_thickness = value;
	get():
		return get_glass_thickness();

@export var liquid_color: Color:
	set(value):
		set_liquid_color(value);
		liquid_color = value;
	get():
		return get_liquid_color();

@export var liquid_glow_color: Color:
	set(value):
		set_liquid_glow_color(value);
		liquid_glow_color = value;
	get():
		return get_liquid_glow_color();

@export var container_height: float:
	set(value):
		set_container_height(value);
		container_height = value;
	get():
		return get_container_height();

@export var container_width: float:
	set(value):
		set_container_width(value);
		container_width = value;
	get():
		return get_container_width();

@export var wave_intensity: float:
	set(value):
		set_wave_intensity(value);
		wave_intensity = value;
	get():
		return get_wave_intensity();

@export var dampening: float = 3.0;
@export var spring_constant: float = 200.0;
@export var reaction: float = 4.0;

@export var material_id: int = 0;

var coeff: Vector2;
var coeff_old: Vector2;
var coeff_old_old: Vector2;

var pos: Vector3;
var pos_old: Vector3;
var pos_old_old: Vector3;

var material_pass_1
var material_pass_2

var accell : Vector2

func set_fill_amount(p_fill_amount : float):
	if is_inside_tree():
		if not material_pass_1 or not material_pass_2:
			get_material_passes();

		material_pass_1.set_shader_parameter("fill_amount", p_fill_amount)
		material_pass_2.set_shader_parameter("fill_amount", p_fill_amount)

func get_fill_amount() -> float:
	if not material_pass_1:
		get_material_passes();

	return material_pass_1.get_shader_parameter("fill_amount")

func set_glass_thickness(p_thickness : float):
	if is_inside_tree():
		if not material_pass_1 or not material_pass_2:
			get_material_passes();
		material_pass_1.set_shader_parameter("glass_thickness", p_thickness)
		material_pass_2.set_shader_parameter("glass_thickness", p_thickness)

func get_glass_thickness() -> float:
	if not material_pass_1:
		get_material_passes();
	return material_pass_1.get_shader_parameter("glass_thickness")

func set_liquid_color(p_color : Color):
	if is_inside_tree():
		if not material_pass_1 or not material_pass_2:
			get_material_passes();

		material_pass_1.set_shader_parameter("liquid_color", p_color)
		material_pass_2.set_shader_parameter("liquid_color", p_color)

func get_liquid_color() -> Color:
	if not material_pass_1:
		get_material_passes();
	return material_pass_1.get_shader_parameter("liquid_color")

func set_liquid_glow_color(p_color : Color):
	if is_inside_tree():
		if not material_pass_1 or not material_pass_2:
			get_material_passes();
		material_pass_1.set_shader_parameter("glow_color", p_color)
		material_pass_2.set_shader_parameter("glow_color", p_color)

func get_liquid_glow_color() -> Color:
	if not material_pass_1:
		get_material_passes();
	return material_pass_1.get_shader_parameter("glow_color")

func set_container_height(p_height : float):
	if is_inside_tree():
		if not material_pass_1 or not material_pass_2:
			get_material_passes();
		material_pass_1.set_shader_parameter("height", p_height)
		material_pass_2.set_shader_parameter("height", p_height)

func get_container_height() -> float:
	if not material_pass_1:
		get_material_passes();
	return material_pass_1.get_shader_parameter("height")

func set_container_width(p_width : float):
	if is_inside_tree():
		if not material_pass_1 or not material_pass_2:
			get_material_passes();
		material_pass_1.set_shader_parameter("width", p_width)
		material_pass_2.set_shader_parameter("width", p_width)

func get_container_width() -> float:
	if not material_pass_1:
		get_material_passes();
	return material_pass_1.get_shader_parameter("width")

func set_wave_intensity(p_intensity : float):
	if is_inside_tree():
		if not material_pass_1 or not material_pass_2:
			get_material_passes();
		material_pass_1.set_shader_parameter("wave_intensity", p_intensity)
		material_pass_2.set_shader_parameter("wave_intensity", p_intensity)

func get_wave_intensity() -> float:
	if not material_pass_1:
		get_material_passes();
	return material_pass_1.get_shader_parameter("wave_height") if material_pass_1.get_shader_parameter("wave_height") else 0.0
	
func get_surface_material(id: int) -> Material:
	var result: Material;
	if mesh.get_surface_count() > 0:
		var material: Material = mesh.surface_get_material(id);
		if material:
			result = material;

	if "material" in mesh:
		var material: Material = mesh.material;
		if material:
			result = material;
	return result;
	
func set_surface_material(id: int, mat: Material) -> void:
	if mesh.get_surface_count() > 0:
		mesh.surface_set_material(id, mat);
	#elif "material" in mesh:
		#mesh.material = mat;
		
	
func get_material_passes():
	var mat = get_surface_material(material_id).duplicate()
	material_pass_1 = mat
	material_pass_1.next_pass = material_pass_1.next_pass.duplicate()
	material_pass_2 = material_pass_1.next_pass
	set_surface_material(material_id, mat)

func _ready():
	pos = global_position;
	pos_old = pos;
	pos_old_old = pos_old;
	
	mesh = mesh.duplicate();

	var mat = get_surface_material(material_id).duplicate()
	mat.next_pass = mat.next_pass.duplicate()
	material_pass_2 = mat.next_pass
	material_pass_1 = mat
	set_surface_material(material_id, mat)

func _physics_process(delta):
	var accell_3d = (pos - 2 * pos_old + pos_old_old) / delta / delta
	pos_old_old = pos_old
	pos_old = pos
	pos = global_position

	accell = Vector2(accell_3d.x, accell_3d.z)

	coeff_old_old = coeff_old
	coeff_old = coeff
	coeff = delta*delta* (-spring_constant*coeff_old - reaction*accell) + 2 * coeff_old - coeff_old_old - delta * dampening * (coeff_old - coeff_old_old)

	if material_pass_1 != get_surface_material(material_id):
		material_pass_1 = get_surface_material(material_id)
		material_pass_2 = get_surface_material(material_id).next_pass;

	material_pass_1.set_shader_parameter("coeff", coeff)
	material_pass_2.set_shader_parameter("coeff", coeff)

	material_pass_1.set_shader_parameter("vel", (coeff - coeff_old) / delta)
