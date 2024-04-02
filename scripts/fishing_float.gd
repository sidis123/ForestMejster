extends RigidBody3D

# Whether the float is connected to the fishing rod
var connected: bool = true

# The float target that the float is attached to when connected
var target: Node3D

# The fishing rod container
var fishing_rod_container: Node3D

# Signal for when the float lands in water (TODO: use this to start the fishing minigame)
signal landed_in_water

@export var float_force := 1.0
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = get_node('/root/Main/Water')
@export var fish_interval:= 3
var time_since_last_push := 0.0  # Timer to track time since last push
var push_interval  # Default interval in seconds for the strong push
var strong_push_force := 4.0  # Adjust the strength of the strong push here
var push_interval_randomness  # Random factor for the push interval
var push_active: bool = false
var can_spawn_fish: bool = false  # Variable to determine if fish can be spawned

# Called when the node enters the scene tree for the first time.
func _ready():
	# Disable the rigid body
	freeze = true
	
	# Find the fishing rod container
	fishing_rod_container = get_node("../")
	if not fishing_rod_container:
		push_error("Fishing float failed to find the fishing rod container")
	fishing_rod_container.action_pressed.connect(_on_action_pressed)
	
	# Find the float target
	target = get_node("../FishingRod/FloatTarget")
	if not target:
		push_error("Fishing float failed to find float target")
	set_fish_interval(fish_interval)
	
	
# Called every physics frame
func _physics_process(delta):
	if connected:
		set_position_at_target()
	
	if landed_in_water:
		bob_in_water(delta)


# Sets the position of the float at the position of the float target
func set_position_at_target():
	# Set the position of the float to the target
	global_position = target.global_position
	scale = Vector3(1, 1, 1)


# Handles the bobbing logic and the time frame for spawning the fish
func bob_in_water(delta):
	# Update the timer for floating logic
	time_since_last_push += delta
	
	# Check if push interval (+-10%) has passed
	var randomized_interval = push_interval + randf_range(-push_interval_randomness, push_interval_randomness)
	
	if time_since_last_push >= randomized_interval:
		apply_central_impulse(Vector3.DOWN * strong_push_force)  # Apply a strong push upwards
		time_since_last_push = 0  # Reset the timer
		push_active=true
		can_spawn_fish = true
	if global_position.y < water.get_height():
		apply_force(Vector3.UP * float_force * gravity * 1.3)
	# Player missed the fish
	if global_position.y >= water.get_height()+0.2 and push_active==true:
		linear_velocity = Vector3.ZERO
		push_active=false
		can_spawn_fish = false


func set_fish_interval(value):
	fish_interval = clamp(value, 1, 10)
	push_interval = fish_interval * 10.0
	push_interval_randomness = push_interval / 10

# Handles the interaction signal from the fishing rod
func _on_action_pressed():
	# Saves the position of the float at time of recall
	var positionFortheFish=global_position
	print("Back to rod")
	var targetino = Vector3(22.46, 0, 24.058)
	connected = !connected
	
	
	if connected and can_spawn_fish:
		#cia iskviest medoda kuris spawnina zuvyte
		spawn_and_shoot_fish(positionFortheFish,targetino)
		freeze = true
		
	else:
		freeze = false
		linear_velocity = target.estimated_velocity
	
	
# Detects collisions
func _on_body_entered(body):
	var layer = body.get_collision_layer()
	if layer and layer == pow(2,9): 
		# If colliding with fishable water, a signal is emitted 
		scale *= 17  # Increase the scale of the float 
		landed_in_water.emit()
		angular_velocity = Vector3()  # Reset angular velocity
		linear_velocity = Vector3()   # Reset linear velocity
		rotation = Vector3(0, rotation.y, 0)  # Maintain upright orientation
		time_since_last_push = 0
		
	else:
		# If colliding with anything else, the float is reset
		connected = true
		freeze = true


# Spawns a fish and shoots it towards the player
func spawn_and_shoot_fish(fish_spawn_position, target_position):
	# Retrieve the fish instance from the main scene
	var fish_scene = preload("res://scenes/fish.tscn")

	if fish_scene:
		# Create a new instance of the fish
		var new_fish = fish_scene.instantiate()

		if new_fish:
			# Set the scale of the new fish
			new_fish.scale *= 10

			# Add the new fish as a child of the scene
			get_parent().add_child(new_fish)

			# Set the position of the new fish
			new_fish.global_transform.origin = fish_spawn_position

			# Calculate initial velocity to hit the target with an arched trajectory
			var gravity = -9.8 # Gravity value (adjust as needed) (TODO: figure out if this can break bobbing (it overrides the gravity variable I guess))
			var displacement = target_position - fish_spawn_position
			var time_to_reach_target = -displacement.y / gravity
			var horizontal_velocity = Vector3(displacement.x / (time_to_reach_target * 10), 0, displacement.z / (time_to_reach_target * 10)) # Slower horizontal velocity
			var vertical_velocity = Vector3(0, -gravity * (time_to_reach_target * 6), 0) # Higher vertical velocity
			new_fish.linear_velocity = horizontal_velocity + vertical_velocity
			# TODO: implement a cap on the fish impulse so it wouldn't fly out of the map
		else:
			print("Failed to instance fish.")
	else:
		print("Fish scene not found or could not be loaded.")
