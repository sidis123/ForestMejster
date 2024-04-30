@tool
class_name NewLine
extends MeshInstance3D

## Line Script.
##
## This script realises a 3D line between two nodes.

@export_category("Line settings")

@export var radius: float = 1

@export var material : Material

@export_category("End points")

## The starting point of the line.
@export var start_point: Node3D #: set = _set_start_point

## The end point of the line.
@export var end_point: Node3D #: set = _set_end_point


func _ready():
	if start_point and end_point:
		_initialize_line()


func _set_start_point(p: Node3D):
	if not start_point and end_point:
		start_point = p
		_initialize_line()
	else:
		start_point = p


func _set_end_point(p: Node3D):
	if not end_point and start_point:
		end_point = p
		_initialize_line()
	else:
		end_point = p


func _initialize_line():
	if not start_point or not end_point:
		return

	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = radius
	cylinder_mesh.bottom_radius = radius
	cylinder_mesh.height = 1.0  # Initial height, adjusted dynamically
	mesh = cylinder_mesh
	
	if not material:
		material = ORMMaterial3D.new()
		material.albedo_color = Color.WHITE
		mesh.material = material
	else:
		mesh.material = material

func _process(delta):
	update_line()

func update_line():
	if not start_point or not end_point:
		return

	var start_pos = start_point.global_position
	var end_pos = end_point.global_position
	var dir = end_pos - start_pos
	
	if dir.length() > 0:
		if mesh.top_radius == 0:
			mesh.top_radius = radius
			mesh.bottom_radius = radius
		
		# Update the position to the middle of the line
		global_position = start_pos + dir * 0.5

		# Update the cylinder's height to match the length
		mesh.height = dir.length()

		# Update the rotation to point from start to end
		look_at(end_pos, Vector3.UP)
		rotate_object_local(Vector3.RIGHT, PI/2)
	else:
		mesh.height = 0
		mesh.top_radius = 0
		mesh.bottom_radius = 0
