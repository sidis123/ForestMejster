extends RigidBody3D
class_name FishingFloat

## Whether the float is connected to the fishing rod
var connected: bool = true

## The float target that the float is attached to when connected
var target: Node3D

## The fishing rod container
var fishing_rod_container: Node3D


var in_water: bool = false

@export var float_force := 1.0
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = get_node('/root/Main/Water/FishingWaterNew')
@export var fish_interval:= 3
var time_since_last_push := 0.0  # Timer to track time since last push
var push_interval  # Default interval in seconds for the strong push
var strong_push_force := 4.0  # Adjust the strength of the strong push here
var push_interval_randomness  # Random factor for the push interval
var push_active: bool = false
var can_spawn_fish: bool = false  # Variable to determine if fish can be spawned

@export_category("Distance from fishing rod")

## The maximum distance the float can go from the fishing rod before it is reset.
@export var max_distance: float = 10.0
var distance: float = 0.0 # TODO: increase *MESH* scale based on distance from target

## The minimum scale of the float. The float mesh will be at this scale while on the rod.
@export var min_scale: float = 0.02

## The maximum scale of the float. The float mesh will reach this scale at the maximum distance or upon reaching water. 
@export var max_scale: float = 0.8

## The mesh of the float, used for changing scale.
var mesh: MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Find the mesh
	mesh = get_node("FloatMesh")
	
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
	
	# Reset the float
	reset()


# Called every frame
func _process(delta):
	if not connected and not in_water:
		mesh.scale = Vector3.ONE * (distance / max_distance * (max_scale - min_scale) + min_scale)

# Called every physics frame
func _physics_process(delta):
	if connected:
		set_position_at_target()
		return
		
	if in_water:
		bob_in_water(delta)
		return
		
	distance = global_position.distance_to(target.global_position)
	if distance > max_distance:
		reset()


## Resets the float back to the fishing rod.
func reset():
	connected = true
	freeze = true
	set_position_at_target()


## Sets the position of the float at the position of the float target
func set_position_at_target():
	global_position = target.global_position
	mesh.scale = Vector3.ONE * min_scale
	# BUG: if you reset the scale once (like in reset()) it doesn't always reset 
	# because its not in _inherited_forces() as it should've been


## Handles the bobbing logic and the time frame for spawning the fish.
func bob_in_water(delta):
	# Update the timer for floating logic
	time_since_last_push += delta
	
	# BUG: doesn't this recalculate the interval every physics frame?
	# Check if push interval (+-10%) has passed
	var randomized_interval = push_interval + randf_range(-push_interval_randomness, push_interval_randomness)
	if time_since_last_push >= randomized_interval:
		apply_central_impulse(Vector3.DOWN * strong_push_force)  # Apply a strong push downwards
		time_since_last_push = 0  # Reset the timer
		push_active=true
		can_spawn_fish = true
	
	# Bobs the float (applies upwards force once it gets bellow the water level)
	if global_position.y < water.global_position.y:
		apply_force(Vector3.UP * float_force * gravity * 1.3)
	# BUG: equlizes (stops bobbing) eventually
		
	# Player misses the fish once the float gets above the water level after the push
	if global_position.y >= water.global_position.y + 0.2 and push_active==true:
		linear_velocity = Vector3.ZERO
		push_active=false
		can_spawn_fish = false


## What is this used for?
func set_fish_interval(value):
	fish_interval = clamp(value, 1, 10)
	push_interval = fish_interval * 10.0
	push_interval_randomness = push_interval / 10

# Handles the interaction signal from the fishing rod
func _on_action_pressed():
	# Gdscript is snake case bro
	var positionFortheFish = global_position
	# Tf does this name mean?
	var targetino = Vector3(22.46, 0, 24.058)
	
	if not connected:
		if can_spawn_fish:
			spawn_and_shoot_fish(positionFortheFish,targetino)
		reset()
	else:
		connected = false
		freeze = false
		linear_velocity = target.estimated_velocity


## Detects collisions with other bodies and resets the float
func _on_body_entered(body):
	var layer = body.get_collision_layer()
	if layer and layer != pow(2,9): 
		reset()


## Func that handles the entry into water. Called by the water.
func on_water_entered():
	print("The float entered the water")
	in_water = true
	mesh.scale = Vector3.ONE * max_scale # increase the scale of the float mesh to max
	angular_velocity = Vector3()  # Reset angular velocity
	linear_velocity = Vector3()   # Reset linear velocity
	rotation = Vector3(0, rotation.y, 0)  # Maintain upright orientation
	time_since_last_push = 0
	# TODO: doing this not in integrate forces can cause glitching


# NOTE: if the float leaves the water area at any point it will be disabled - even if it happens during the push :)
func on_water_exited():
	in_water = false
	can_spawn_fish = false
	push_active = false
	print("The float exited the water")


# Spawns a fish and shoots it towards the player
# TODO: this should be in a separate fish script tbh
func spawn_and_shoot_fish(fish_spawn_position, target_position):
	print("Nu iškvietė")
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
			new_fish.global_position = fish_spawn_position

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
