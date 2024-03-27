class_name Line
extends Node3D

@export_category("Line settings")
@export var line_radius: float = 0.1
@export var line_resolution = 180

## Override of the line material
@export var polygon_material_override: Material : set = set_polygon_material_override

@export_category("End points")
@export var start_point: Node3D
@export var end_point: Node3D
var start_point_position: Vector3 = Vector3.ZERO
var end_point_position: Vector3 = Vector3.ZERO

## The Path3D node that represents the path of the line
var path: Path3D

## The curve of the path
var curve: Curve3D

## The CSGPolygon3D node that represents the volume of the line
var polygon: CSGPolygon3D

## Variables used for debugging
var spam_delay = 2.0
var time_since_spam = 0.0

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
		
	spam(0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update the positions of the points
	if start_point and end_point:
		update_line_position()
	
	spam(delta)
	
	# Fill the path with volume
	update_polygon()


func set_line_position() -> void:
	# Set the line's origin to the start point position
	global_position = start_point.global_position
	
	# Reset the curve and add the points
	curve.clear_points()
	curve.add_point(Vector3.ZERO)
	curve.add_point(end_point.global_position - global_position)


func update_line_position() -> void:
	# Set the line's origin to the start point position
	global_position = start_point.global_position
	
	# Reset the points' positions
	curve.set_point_position(0, Vector3.ZERO)
	curve.set_point_position(1, end_point.global_position - global_position)


func update_polygon() -> void:
	# The next section resets the global rotation of the polygon to 0
	# I have no I idea why this is necessary and why inheriting the same rotation
	# as the path it adds volume to is bad for it, but the inherited rotation
	# is added top of the rotation of the path.
	# E.g. if one of the parents ir rotated by 90 degrees, the polygon will be
	# 90 degrees off the actual curve - I love Godot
	
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


func set_polygon_material_override(material : Material) -> void:
	polygon_material_override = material
	if is_inside_tree() and polygon:
		polygon.set_material(material)

## Function used for debugging
func spam(delta: float):
	time_since_spam += delta
	if time_since_spam >= spam_delay:
		time_since_spam = 0.0
		# Gal reikia transform origin pakeisti?
		print("----------------------------------")
		print("Linijos globali pozicija: " + str(global_position) + "; relatyvi tėvui: " + str(position))
		print("Linijos globali rotacija: " + str(global_transform.basis.get_euler()) + "; relatyvi tėvui: " + str(transform.basis.get_euler()))
		print("Path globali pozicija: " + str(path.global_position) + "; relatyvi tėvui: " + str(path.position))
		print("Path globali rotacija: " + str(path.global_transform.basis.get_euler()) + "; relatyvi tėvui: " + str(path.transform.basis.get_euler()))
		print("Polygon globali pozicija: " + str(polygon.global_position) + "; relatyvi tėvui: " + str(polygon.position))
		print("Polygon globali rotacija: " + str(polygon.global_transform.basis.get_euler()) + "; relatyvi tėvui: " + str(polygon.transform.basis.get_euler()))
		print("----------------------------------\n")
