class_name Globals;
extends Node;

var player: Player;
var hand: Hand;
var object_container: Node3D;

enum COLLISION_LAYERS {
	NONE = 0,
	WORLD = 1,
	PLAYER = 2,
	INTERACTABLE = 4,
	SURFACE = 8,
	GRABBABLE = 16
}

enum VISIBILITY_LAYERS {
	MAIN = 1,
	FOREGROUND = 2,
}

enum CONTAINER_INTERACTIONS {
	NONE,
	REMOVE_ITEM,
	MOVEABLE,
	BEAKER,
	COMBINED_ITEM
}

enum INTERACTION_INDICATOR_TYPE {
	NONE,
	GRAB,
	POINT,
	FLIP_LEFT,
	FLIP_RIGHT,
	GLOW
}

#enum ALCHEMY_ATTRIBUTES {
	#Aer, #Air
	#Aqua, #Water
	#Ignis, #Fire,
	#Terra, #Earth
#}
