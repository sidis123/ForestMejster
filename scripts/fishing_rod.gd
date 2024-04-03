extends Node3D

# The fishing rod pickable object
var fishing_rod_pickable: XRToolsPickable

# The fishing float
var fishing_float: RigidBody3D

signal action_pressed

func _ready():
	fishing_rod_pickable = get_node("FishingRod")
	if not fishing_rod_pickable:
		push_error("Fishing rod container failed to find the pickable object")
	fishing_rod_pickable.action_pressed.connect(_on_action_pressed)
	
	fishing_float = get_node("FishingFloat")
	if not fishing_float:
		push_error("Fishing rod container failed to find the fishing float")


# Catch the pickable objects action pressed signal and reemit it
# This is done only so the float (and other things in the future) doesn't have to directly connect to the pickable object
func _on_action_pressed(pickable: Variant):
	action_pressed.emit()
