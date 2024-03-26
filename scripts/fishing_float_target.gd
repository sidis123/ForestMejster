extends Node3D

var previous_position := Vector3.ZERO
var current_position := Vector3.ZERO
var velocity_buffer := []  # Buffer to store recent velocity estimates
var buffer_size := 5  # Number of samples for averaging

var estimated_velocity := Vector3.ZERO
var instant_velocity := Vector3.ZERO

func _ready():
	previous_position = global_position

func _physics_process(delta):
	var current_position = global_position
	var instant_velocity = (current_position - previous_position) / delta
	previous_position = current_position
	
	# Ensure the buffer does not exceed the intended size
	if velocity_buffer.size() == buffer_size:
		velocity_buffer.pop_front()  # Remove the oldest sample
	
	# Add the most recent velocity estimate to the buffer
	velocity_buffer.append(instant_velocity)
	
	# Calculate the average velocity
	estimated_velocity = velocity_buffer.reduce(sum) / velocity_buffer.size()

func sum(accum, number):
	return accum + number
