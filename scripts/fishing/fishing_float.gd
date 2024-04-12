class_name FishingFloat
extends RigidBody3D

## Whether the float is connected to the fishing rod
var connected: bool = true

## The float target that the float is attached to when connected
@onready var target: Node3D = get_node("../FishingRod/FloatTarget")

## The fishing rod.
@onready var fishing_rod: FishingRod = get_node("../FishingRod")

var in_water: bool = false

@export_category("Floating characteristics")

@export var float_force := 0.1
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water: FishingWater = get_node('/root/Main/Water/FishingWater')
@export var fish_interval:= 3
var time_since_last_push := 0.0  # Timer to track time since last push
var push_interval  # Default interval in seconds for the strong push
var strong_push_force := 0.0  # Adjust the strength of the strong push here
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

## The mesh of the float, used for changing the visual scale.
@onready var mesh: MeshInstance3D = get_node("FloatMesh")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check if fishing rod is found and connect to its signal
	if not fishing_rod:
		push_error("Fishing float failed to find the fishing rod")
	else:
		fishing_rod.action_pressed.connect(_on_action_pressed)
	
	# Find the float target
	if not target:
		push_error("Fishing float failed to find float target")
	
	# Set the interval for catching fish I guess
	set_fish_interval(fish_interval)
	
	# Make sure the float is reset
	_reset()


# Called every frame
func _process(_delta):
	if not connected and not in_water:
		_adjust_mesh_scale()


# Called every physics frame
func _physics_process(_delta):
	if connected:
		set_position_at_target()
		return
		
	if in_water:
		bob_in_water()
		return
	
	# Calculate the distance from the float to the rod
	_update_distance_to_rod()


func _update_distance_to_rod():
	distance = global_position.distance_to(target.global_position)
	if distance > max_distance:
		_reset()


## Used to calculate the scale the float mesh should be at the current distance.
func _adjust_mesh_scale():
	mesh.scale = Vector3.ONE * (distance / max_distance * (max_scale - min_scale) + min_scale)


## Resets the float back to the fishing rod.
func _reset():
	freeze = true
	connected = true
	set_position_at_target()


## Releases the float from the fishing rod.
func _release():
	connected = false
	freeze = false
	linear_velocity = target.estimated_velocity


## Sets the position of the float at the position of the float target
func set_position_at_target():
	
	global_position = target.global_position
	# Reset the mesh scale
	mesh.scale = Vector3.ONE * min_scale

var pushing_up: bool = false
var jump_force: float = 4.0

## Handles the bobbing logic and the time frame for spawning the fish.
func bob_in_water():
	# Update the timer for floating logic
	#time_since_last_push += delta
	
	# BUG: doesn't this recalculate the interval every physics frame?
	# Check if push interval (+-10%) has passed
	#var randomized_interval = push_interval + randf_range(-push_interval_randomness, push_interval_randomness)
	#if time_since_last_push >= randomized_interval:
		#apply_central_impulse(Vector3.DOWN * strong_push_force)  # Apply a strong push downwards
		#time_since_last_push = 0  # Reset the timer
		#push_active=true
		#can_spawn_fish = true

	
	## Bobs the float (applies upwards force once it gets bellow the water level)
	if global_position.y < water.global_position.y:
		apply_force(Vector3.UP * (float_force + mass * gravity))
	# BUG: equlizes (stops bobbing) eventually
		
	# Player misses the fish once the float gets above the water level after the push
	#if global_position.y >= water.global_position.y + 0.2 and push_active==true:
		#linear_velocity = Vector3.ZERO
		#push_active=false
		#can_spawn_fish = false

func plunge_on_bite():
	apply_central_impulse(Vector3.DOWN * strong_push_force)  # Apply a strong push downwards

## What is this used for?
func set_fish_interval(value):
	fish_interval = clamp(value, 1, 10)
	push_interval = fish_interval * 10.0
	push_interval_randomness = push_interval / 10


## Handles the interaction signal from the fishing rod
func _on_action_pressed(pickable: Variant):	
	if not connected:
		_reset()
	else:
		_release()


## Detects collisions with other bodies and resets the float upon touching something.
func _on_body_entered(body):
	var layer = body.get_collision_layer()
	if layer and layer != pow(2,9): 
		_reset()


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
			#var gravity = -9.8 # Gravity value (adjust as needed) (TODO: figure out if this can break bobbing (it overrides the gravity variable I guess))
			var displacement = target_position - fish_spawn_position
			var time_to_reach_target = -displacement.y / -gravity
			var horizontal_velocity = Vector3(displacement.x / (time_to_reach_target * 10), 0, displacement.z / (time_to_reach_target * 10)) # Slower horizontal velocity
			var vertical_velocity = Vector3(0, gravity * (time_to_reach_target * 6), 0) # Higher vertical velocity
			new_fish.linear_velocity = horizontal_velocity + vertical_velocity
			# TODO: implement a cap on the fish impulse so it wouldn't fly out of the map
		else:
			print("Failed to instance fish.")
	else:
		print("Fish scene not found or could not be loaded.")
