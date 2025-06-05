class_name Trigger;
extends Node3D;

@export var id: String;
@export var hover_state: Globals.INTERACTION_INDICATOR_TYPE = Globals.INTERACTION_INDICATOR_TYPE.NONE;

signal fire_trigger;

func handle_interaction() -> void:
	fire_trigger.emit(id, self);
