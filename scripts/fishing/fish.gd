@tool
class_name Fish
extends XRToolsPickable

## The fish object.
##
## Extends [XRToolsPickable]. Is spawned by fishing water.

## The mesh of the mesh.
@onready var mesh = get_node("Mesh")

## Sets the scale of the fish's mesh to given value.
func set_mesh_scale(mesh_scale: Vector3):
	mesh.set_scale(mesh_scale)

func pick_up(by: Node3D) -> void:
	super.pick_up(by)
	if mesh.get_parent().has_method("set_gravity_scale"): #reikalingas fisho cookinimui NEISTRINTI
		mesh.get_parent().set_gravity_scale(1)
	mesh.set_scale(Vector3(2, 2, 2)) # Reset the mesh scale
