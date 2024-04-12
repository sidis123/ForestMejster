@tool
class_name FishingRod
extends XRToolsPickable


## The fishing rod object.
##
## This extends the XRToolsPickable script that allows a [RigidBody3D] to be picked up by an
## [XRToolsFunctionPickup] attached to a players controller.
##
## The fishing rod contains (as its children) the [FishingFloat] and [Line] objects.

## Signal emittted when the fishing rod is tugged. 
signal tugged

## The fishing float.
@onready var fishing_float: FishingFloat = get_node("../FishingFloat")

## The float target.
@onready var float_target: FishingFloatTarget = get_node("FloatTarget")


#func _ready():
	#super._ready() # Run the parent _ready() function to get the grab points


func pick_up(by: Node3D) -> void:
	super.pick_up(by) # Run the parent pick up function
	float_target.set_picked_up(true) # Tell the target to start calculating


func let_go(by: Node3D, p_linear_velocity: Vector3, p_angular_velocity: Vector3) -> void:
	super.let_go(by, p_linear_velocity, p_angular_velocity) # Run the parent function
	float_target.set_picked_up(false) # Tell the target to stop calculating


func handle_tug():
	print("Bro tugging!")
	tugged.emit()
