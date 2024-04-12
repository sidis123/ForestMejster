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

@export var float_force: float = 1
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water: FishingWater = get_node('/root/Main/Water/FishingWater')
@export var fish_interval:= 3
var time_since_last_push := 0.0  # Timer to track time since last push
var push_interval  # Default interval in seconds for the strong push
var plunge_force: float = 0.4  # Adjust the strength of the strong push here
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

## The particle system of the float, used for emitting success particles.
@onready var particles: CPUParticles3D = get_node("SuccessParticles")

var bobbing_amplitude: float = 0.1  # Amplitude of the bobbing (max height/depth from the water level)
var bobbing_period: float = 1.0  # Time it takes to complete one full cycle of bobbing
var rotation_period: float = 3.0
var rotation_amplitude = 0.2  # Amplitude of the rotation (in radians)
var bobbing_time: float = 0.0  # Keep track of the elapsed time
var rotation_time: float = 0.0

var plunging: bool = false
var bobbing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check if fishing rod is found and connect to its signal
	if fishing_rod:
		fishing_rod.action_pressed.connect(_on_action_pressed)
	
	# Make sure the float is reset
	_reset()


# Called every frame
func _process(_delta):
	if not connected and not in_water:
		_adjust_mesh_scale()


# Called every physics frame
func _physics_process(delta):
	if connected:
		set_position_at_target()
	
	if not connected and not in_water:
		_update_distance_to_rod()


func _integrate_forces(state):
	if in_water:
		if plunging:
			_control_plunging(state)
			return
		
		#if emerging:
			#_control_emerging(state)
			#return
		
		if bobbing:
			_bob_in_water(state)


func _bob_in_water(state):
	# Increment time variables by the physics frame duration
	bobbing_time += state.step  
	rotation_time += state.step
	
	var target_y = water.global_position.y + bobbing_amplitude * sin(TAU / bobbing_period * bobbing_time)  # Calculate the target y using a sine wave
	
	# Calculate the angles for rotation based on sine and cosine waves
	var angle_x = rotation_amplitude * cos(TAU / rotation_period * rotation_time)
	var angle_z = rotation_amplitude * sin(TAU / rotation_period * rotation_time)
	
	# Create quaternions for rotations around X and Z axes
	var quat_x = Quaternion(Vector3(1, 0, 0), angle_x)
	var quat_z = Quaternion(Vector3(0, 0, 1), angle_z)
	
	# Combine the two quaternions
	var combined_quat = quat_x * quat_z
	
	# Apply the new position and combined quaternion to the rigid body's transform
	var current_transform = state.transform
	current_transform.origin.y = target_y
	current_transform.basis = Basis(combined_quat)
	state.set_transform(current_transform)


func _control_plunging(state):
	if state.linear_velocity.y < 0 or global_position.y < water.global_position.y:
		apply_force(Vector3.UP * (mass * gravity + float_force))
	else:
		plunging = false
		bobbing_time = 0.0
		bobbing = true


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
	# Reset the mesh scale
	mesh.scale = Vector3.ONE * min_scale
	global_rotation = Vector3.ZERO


## Releases the float from the fishing rod.
func _release():
	connected = false
	freeze = false
	linear_velocity = target.estimated_velocity


## Sets the position of the float at the position of the float target
func set_position_at_target():
	global_position = target.global_position


func plunge():
	bobbing = false
	apply_central_impulse(Vector3.DOWN * plunge_force)
	plunging = true


func emit_particles():
	particles.set_emitting(true)


## Handles the interaction signal from the fishing rod.
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


## Func that handles the entry into water - sets bools and maxes out the mesh scale.
## Called by the water.
func on_water_entered():
	print("The float entered the water")
	in_water = true
	plunging = true
	mesh.scale = Vector3.ONE * max_scale # increase the scale of the float mesh to max


## Handles the exit from water - resets all bools and variables related to water.
## Called by the water.
func on_water_exited():
	in_water = false
	plunging = false
	bobbing = false
	bobbing_time = 0.0
	rotation_time = 0.0
	print("The float exited the water")
