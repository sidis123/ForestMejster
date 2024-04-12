@tool
class_name Fish
extends XRToolsPickable

@onready var mesh = get_node("Mesh")

func set_mesh_scale(scale: Vector3):
	mesh.set_scale(scale)

func pick_up(by: Node3D) -> void:
	super.pick_up(by)
	mesh.set_scale(Vector3(2, 2, 2)) # Reset the mesh scale
