@tool
class_name MeshToConvexShape;
extends Node;

@export var clean: bool = true;
@export var simple: bool = false;

@export var mesh: Mesh:
	set(value):
		mesh = value;
		if value:
			shape = value.create_convex_shape(clean, simple);

@export var shape: Shape3D:
	set(value):
		shape = value;
