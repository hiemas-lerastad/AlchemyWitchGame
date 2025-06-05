class_name CabinManager;
extends Node3D;

@export var object_container: Node3D;

func _ready() -> void:
	GLOBALS.object_container = object_container;
