class_name FishingWater
extends Area3D

## Number of times the player needs to correctly click to catch the fish.
@export var number_of_trials: int = 3

## The time you need to wait between trials.
@export var trial_time: float = 3.0

@onready var trial_timer: Timer = get_node("TrialTimer")

## The time in seconds that the player has to react to a trial.
@export var catch_windown: float = 1.0

@onready var catch_timer: Timer = get_node("CatchTimer")

var can_catch: bool = false

## Multiplyer that determines the randomness of time between trials.
## 0 means no randomness, 
## 1 means the time between trials can last anywhere between 0 s and twice the normal time.
@export var trial_wait_time_randomness: float = 0.2

## The size of the time window in which the player should react.
#@export var trial_moment_time: float = 1.0

## The fishing rod container.
@onready var fishing_rod: FishingRod = get_node("/root/Main/FishingRod/FishingRod")

## The fishing float.
@onready var fishing_float: FishingFloat = get_node("/root/Main/FishingRod/FishingFloat")

## The player (needed to target the fish).
@onready var player: XROrigin3D = get_node("/root/Main/PlayerInstance")

var trial_number: int = 0

var fishing_in_progress: bool = false

## The fish scene that will be spawned upon catching.
const FishScene = preload("res://scenes/fishing/fish.tscn")

# TODO: implement distraction logic

# Called when the node enters the scene tree for the first time.
func _ready():
	if not fishing_rod:
		push_error("Fishing water failed to find the fishing rod")
	fishing_rod.action_pressed.connect(_on_fishing_rod_action)
	fishing_rod.tugged.connect(_on_fishing_rod_tugged)
	
	# Connect the signals - in script is more efficient than in inspector
	body_entered.connect(_on_water_entered)
	body_exited.connect(_on_water_exited)


func _start_fishing():
	print("We fishing")
	trial_number = 1
	_reset_timers()
	fishing_in_progress = true

func _complete_trial():
	print("Good job")
	fishing_float.emit_particles()
	trial_number += 1
	_reset_timers()
	
func _fail_trial():
	_reset_timers()

func _catch_fish():
	print("You caught it baby")
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
	print("We done fishing")
	fishing_in_progress = false
	trial_number = 0
	trial_timer.stop()
	catch_timer.stop()


func _reset_timers():
	trial_timer.wait_time = _get_time_until_next_trial()
	catch_timer.wait_time = catch_windown
	trial_timer.start()

## Calculates the randomised time until next trial.
func _get_time_until_next_trial() -> float:
	var randomness = trial_time * trial_wait_time_randomness
	var time_until_next_trial = randf_range(trial_time - randomness, trial_time + randomness)
	return time_until_next_trial


## Handles the entry of the fishable water. 
## Connected to the body entered signal of this node.
func _on_water_entered(body: Node3D):
	# Check if the body that landed in the water has a func for processing this event
	if body.has_method("on_water_entered"):
		# Call it if it does
		body.on_water_entered()
		if body == fishing_float:
			_start_fishing()
	else:
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
		print("An unrecognised body has exited the water: " + str(body))


## Handles the logic upon fishing rod action. 
## Connected to the action_pressed signal of the fishing rod container.
func _on_fishing_rod_action(pickable: Variant):
	print("Fishing water detected a fishing rod action")


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


## Connected to the timeout of the trial timer.
func _on_trial_timer_timeout():
	print("It do be biting")
	fishing_float.plunge()
	can_catch = true
	catch_timer.start()


func _on_catch_timer_timeout():
	print("Missed it, bud")
	can_catch = false
	_fail_trial()
