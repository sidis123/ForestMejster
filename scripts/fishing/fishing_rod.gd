@tool
class_name FishingRod
extends XRToolsPickable


## The fishing rod object.
##
## This extends the XRToolsPickable script that allows a [RigidBody3D] to be picked up by an
## [XRToolsFunctionPickup] attached to a players controller.
##
## The fishing rod contains (as its children) the [FishingFloat] and [Line] objects.


## The fishing float.
@onready var fishing_float: FishingFloat = get_node("../FishingFloat")


#func _ready():
	#super._ready() # Run the parent _ready() function to get the grab points
