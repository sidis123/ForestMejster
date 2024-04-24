class_name FishingWater
extends Area3D


## The fish scene that will be spawned upon catching.
const FishScene = preload("res://scenes/fishing/fish.tscn")

## Number of times the player needs to correctly click to catch the fish.
@export var number_of_trials: int = 3

## The time you need to wait between trials.
@export var trial_time: float = 3.0

## Multiplyer that determines the randomness of time between trials.
## 0 means no randomness, 
## 1 means the time between trials can last anywhere between 0 s and twice the normal time.
@export var trial_wait_time_randomness: float = 0.2

## The time between distractions.
@export var distraction_time: float = 2.0

## Multiplyer that determines the randomness of time between distractions.
@export var distraction_time_randomness: float = 0.0

## The time in seconds that the player has to react to a trial.
@export var catch_windown: float = 1.0

var can_catch: bool = false

var trial_number: int = 0

var fishing_in_progress: bool = false

@onready var trial_timer: Timer = get_node("TrialTimer")

@onready var catch_timer: Timer = get_node("CatchTimer")

@onready var distraction_timer: Timer = get_node("DistractionTimer");

## The fishing rod container.
@onready var fishing_rod: FishingRod = get_node("/root/Main/FishingRod/FishingRod")

## The fishing float.
@onready var fishing_float: FishingFloat = get_node("/root/Main/FishingRod/FishingFloat")

## The player (needed to target the fish).
@onready var player: XROrigin3D = get_node("/root/Main/PlayerInstance")

@onready var water_mesh: MeshInstance3D = get_node("../")

@onready var water_shader: ShaderMaterial

var wind_distraction: bool = false
var wind_transition_speed: float = 0.2
var wind_transition_time: float = 0.0

# TODO: implement distraction logic

# Called when the node enters the scene tree for the first time.
func _ready():
	fishing_rod.action_pressed.connect(_on_fishing_rod_action)
	fishing_rod.tugged.connect(_on_fishing_rod_tugged)
	
	# Connect the signals - in script is more efficient than in inspector
	body_entered.connect(_on_water_entered)
	body_exited.connect(_on_water_exited)
	
	if water_mesh:
		water_shader = water_mesh.get_surface_override_material(0)

func _process(delta):
	if wind_distraction:
		#water_shader.set_shader_parameter("triangleSpeed", 5);
		#wind_distraction = false
		#var triangle_height = water_shader.get_shader_parameter("triangleHeight")
		var triangle_speed = water_shader.get_shader_parameter("triangleSpeed")
		#if triangle_height < 0.6 or triangle_speed < 0.8:
		if triangle_speed < 5:
			#water_shader.set_shader_parameter("triangleSpeed", 2);
			#water_shader.set_shader_parameter("triangleHeight", min(0.6, triangle_height + delta * wind_transition_speed));
			water_shader.set_shader_parameter("triangleSpeed", min(5, triangle_speed + delta * wind_transition_speed));
		
		
		

func _start_fishing():
	trial_number = 1
	_reset_timers()
	fishing_in_progress = true

func _complete_trial():
	fishing_float.emit_particles()
	trial_number += 1
	_reset_timers()
	
func _fail_trial():
	_reset_timers()

func _catch_fish():
	var fish_spawn_position = fishing_float.global_position
	
	if FishScene:
		# Create a new instance of the fish
		var fish_instance = FishScene.instantiate()
		
		if fish_instance:
			# Add the fish and set it up
			add_child(fish_instance)
			fish_instance.set_mesh_scale(Vector3(10, 10, 10))
			fish_instance.global_position = fish_spawn_position

			# Calculate initial velocity to hit the target with an arched trajectory
			var displacement = player.global_position - fish_spawn_position
			var time_to_reach_target = displacement.y / gravity
			var horizontal_velocity = Vector3(displacement.x / (time_to_reach_target * 10), 0, displacement.z / (time_to_reach_target * 10)) # Slower horizontal velocity
			var vertical_velocity = Vector3(0, gravity * (time_to_reach_target * 6), 0) # Higher vertical velocity
			# TODO: the linear velocity should be set in _integrate_forces(), not in a wholy different script
			fish_instance.linear_velocity = horizontal_velocity + vertical_velocity
			# TODO: implement a cap on the fish impulse so it wouldn't fly out of the map


func _finish_fishing():
	fishing_in_progress = false
	trial_number = 0
	trial_timer.stop()
	catch_timer.stop()
	distraction_timer.stop()


func _reset_timers():
	trial_timer.wait_time = _get_time_until_next_trial()
	catch_timer.wait_time = catch_windown
	distraction_timer.wait_time = _get_time_until_distraction()
	trial_timer.start()
	distraction_timer.start()

## Calculates the randomised time until next trial.
func _get_time_until_next_trial() -> float:
	var randomness = trial_time * trial_wait_time_randomness
	var time_until_next_trial = randf_range(trial_time - randomness, trial_time + randomness)
	return time_until_next_trial

func _get_time_until_distraction() -> float:
	var randomness = distraction_time * distraction_time_randomness
	var time = randf_range(distraction_time - randomness, distraction_time + randomness)
	return time

## Handles the entry of the fishable water. 
## Connected to the body entered signal of this node.
func _on_water_entered(body: Node3D):
	# Check if the body that landed in the water has a func for processing this event
	if body.has_method("on_water_entered"):
		# Call it if it does
		body.on_water_entered(global_position.y) # TODO: this breaks floats
		if body == fishing_float:
			_start_fishing()
	else:
		pass
		print("An unrecognised body has entered the water: " + str(body))


## Handles the exit of the fishable water. 
## Connected to the body exited signal of this node.
func _on_water_exited(body: Node3D):
	# Check if the body that exited the water has a func for processing this event
	if body.has_method("on_water_exited"):
		# Call it if it does
		body.on_water_exited()
		if body == fishing_float:
			_finish_fishing()
	else:
		pass
		print("An unrecognised body has exited the water: " + str(body))


## Handles the logic upon fishing rod action. 
## Connected to the action_pressed signal of the fishing rod container.
func _on_fishing_rod_action(pickable: Variant):
	pass


## Handles the fishing rod tug.
func _on_fishing_rod_tugged():
	if can_catch:
		catch_timer.stop()
		can_catch = false
		if trial_number < number_of_trials:
			_complete_trial()
		else:
			_catch_fish()
			_finish_fishing()
			fishing_float._reset()


## Connected to the timeout of the trial timer - when the moment to catch comes.
func _on_trial_timer_timeout():
	fishing_float.plunge()
	can_catch = true
	catch_timer.start()


## Connected to the timeout of the catch timer - when the moment to catch passes.
func _on_catch_timer_timeout():
	can_catch = false
	_fail_trial()


func _on_distraction_timer_timeout():
	if fishing_in_progress:
		wind_distraction = true
