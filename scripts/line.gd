@tool
class_name Line
extends Node3D

## Line Script.
##
## This script realises a 3D line between two nodes.

@export_category("Line settings")

## The radius of the line.
@export var line_radius: float = 0.1

## The resolution of the line (idk how it actually works).
@export var line_resolution = 180

## Override of the line material.
@export var polygon_material_override: Material : set = set_polygon_material_override

@export_category("End points")

## The starting point of the line.
@export var start_point: Node3D

## The end point of the line.
@export var end_point: Node3D

## The Path3D node that represents the path of the line.
var path: Path3D

## The curve of the path.
var curve: Curve3D

## The CSGPolygon3D node that represents the volume of the line.
var polygon: CSGPolygon3D

func _ready():
	# Retrieve the polygon and update its material
	polygon = $LinePolygon
	
	if not polygon:
		push_error("The polygon of the line was not found")
		
	if polygon_material_override:
		polygon.set_material(polygon_material_override)
	
	# Retrieve the path and its curve
	path = $LinePath
	curve = path.curve
	
	# Set the initial positions of the start and end points
	if not start_point or not end_point:
		push_error("The one or both end points of the line are not set")
	else:
		set_line_position()


func _process(_delta):
	# Update the positions of the points
	if start_point and end_point:
		update_line_position()
	
	# Fill the path with volume
	update_polygon()


## Sets the initial positions of the points of the Path3D.
func set_line_position() -> void:
	# Set the line's origin to the start point position
	global_position = start_point.global_position
	
	# Reset the curve and add the points
	curve.clear_points()
	curve.add_point(Vector3.ZERO)
	curve.add_point(end_point.global_position - global_position)


## Updates the positions of the points of the Path3D.
func update_line_position() -> void:
	# Set the line's origin to the start point position
	global_position = start_point.global_position
	
	# Reset the points' positions
	curve.set_point_position(0, Vector3.ZERO)
	curve.set_point_position(1, end_point.global_position - global_position)


## Updates and renders the CSGPolygon3D according to the line path.
func update_polygon() -> void:
	# The next section resets the global rotation of the polygon to 0
	# I have no I idea why this is necessary and why inheriting the same rotation
	# as the path it adds volume to is bad for it, but the inherited rotation
	# is added top of the rotation of the path.
	# E.g. if one of the parents ir rotated by 90 degrees, the polygon will be
	# 90 degrees off the actual curve - I love Godot.
	
	# Get the current global position of the polygon
	var current_global_position = polygon.global_transform.origin
	# Create a new Transform with zero rotation and the same position
	var zero_rotation_transform = Transform3D(Basis(), current_global_position)
	# Set the global transform with zero rotation
	polygon.global_transform = zero_rotation_transform
	
	# Add a circular volume across the path
	var circle = PackedVector2Array()
	for degree in line_resolution:
		var x = line_radius * sin(PI * 2 * degree / line_resolution)
		var y = line_radius * cos(PI * 2 * degree / line_resolution)
		var coords = Vector2(x, y)
		circle.append(coords)
		polygon.polygon = circle

## Changes the CSGPolygon3D's material.
func set_polygon_material_override(material : Material) -> void:
	polygon_material_override = material
	if is_inside_tree() and polygon:
		polygon.set_material(material)
