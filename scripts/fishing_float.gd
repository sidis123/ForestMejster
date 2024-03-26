extends RigidBody3D

@export var float_force := 1.0
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = get_node('/root/Main/Water')
var time_since_last_push := 0.0  # Timer to track time since last push
var push_interval := 20.0  # Interval in seconds for the strong push
var strong_push_force := 4.0  # Adjust the strength of the strong push here

# Called when the node enters the scene tree for the first time.
func _ready():
	time_since_last_push = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called every physics frame
func _physics_process(delta):
	# Update the timer
	time_since_last_push += delta

	# Check if 20 seconds have passed
	if time_since_last_push >= push_interval:
		apply_central_impulse(Vector3.DOWN * strong_push_force)  # Apply a strong push upwards
		time_since_last_push = 0  # Reset the timer

	# Your existing floating logic
	if global_position.y < water.get_height():
		apply_force(Vector3.UP * float_force * gravity * 1.4)
