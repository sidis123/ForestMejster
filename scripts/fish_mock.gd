extends RigidBody3D

var swim_speed = 1.0
var random_factor = 1.2
var min_y_position = -4.5

func _ready():
	linear_velocity = Vector3(0, 0, swim_speed)
	linear_damp = 0.9
	angular_damp = 0.9

func _physics_process(delta):
	swim()

func swim():
	var direction = Vector3(randf_range(-5.0, 5.0), randf_range(-5.0, 5.0), randf_range(-5.0, 5.0))
	direction = direction.normalized()
	apply_central_impulse(direction * swim_speed * random_factor)

func _integrate_forces(state):
	# Ensure fish doesn't go below specific water level, so that they can't get stuck at the bottom pits
	var current_position = get_position()
	if current_position.y < min_y_position:
		current_position.y = min_y_position
		set_position(current_position)

func _on_Fish_body_entered(body):
	swim()
