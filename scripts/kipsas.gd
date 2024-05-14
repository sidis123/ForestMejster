extends Node3D
# Variables to control circular motion
var radius = 4  # Radius of the circular path
var speed = 1.0   # Speed of movement
# Variables to track circular motion
var angle = 0.0   # Current angle
# Center of rotation
var center_of_rotation = Vector3(-8.85, 0, -8.2)  # Example position, adjust as needed
# Initial position of the node
var initial_position := Vector3()

var is_moving = true
var tent_instance = null
var kipsas_collision = null

func _ready():
	var puntukas = get_node("/root/Staging/Scene/Main/Puntukas")
	puntukas.kipsas_toggle_movement.connect(_on_Bezdukas_toggle_movement)
	kipsas_collision = get_node("Cube/BezdukasDissapearingBody/CollisionShape3D")
		# Store the initial position of the node
	initial_position = self.global_transform.origin

func _on_Bezdukas_toggle_movement():
	is_moving = !is_moving  # Toggle the movement state
	
	if !is_moving:
		# Instantiate the Tent node
		if is_instance_valid(kipsas_collision):
			tent_instance = preload("res://scenes/rock_small_v_1.tscn").instantiate()
			tent_instance.global_transform.origin = self.global_transform.origin
			get_tree().get_root().add_child(tent_instance)
			tent_instance.visible = true
			# Remove the current Kipsas node from the scene
			self.visible= false
			if is_instance_valid(kipsas_collision):
				kipsas_collision.disabled=true
		
	if is_moving:
		# Remove the Tent node from the scene
		if is_instance_valid(kipsas_collision):
			if tent_instance:
				tent_instance.queue_free()
			self.visible=true
			if is_instance_valid(kipsas_collision):
				kipsas_collision.disabled=false

func _process(delta):
	pass
	if is_moving:
# Update angle based on time and speed
		angle += speed * delta
		# Calculate new position in the circular path relative to initial position
		var x = initial_position.x + radius * cos(angle)
		var y = initial_position.y  # No change in y-coordinate
		var z = initial_position.z + radius * sin(angle)
		# Set the position of the node
		self.global_transform.origin = Vector3(x, y, z)
