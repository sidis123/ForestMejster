extends Area3D
class_name FishingWater

## Number of times the player needs to correctly click to catch the fish.
@export var number_of_trials: int = 3

## The total fishing time it should take to catch a fish.
@export var total_fishing_time: float = 8.0

## Multiplyer that determines the randomness of time between trials.
## 0 means no randomness, 
## 1 means the time between trials can last anywhere between 0 s and twice the normal time.
@export var trial_wait_time_randomness: float = 0.2

## The size of the time window in which the player should react.
@export var trial_moment_time: float = 1.0

## The fishing rod container
var fishing_rod_container: Node3D

## The fishing float
var fishing_float: FishingFloat

# Called when the node enters the scene tree for the first time.
func _ready():
	_connect_fishing_rod()
	_connect_fishing_float()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



## Handles the entry of the fishable water. 
## Connected to the body entered signal of this node.
func _on_water_entered(body: Node3D):
	# Check if the body that landed in the water has a func for processing this event
	if body.has_method("on_water_entered"):
		# Call it if it does
		body.on_water_entered()
	else:
		print("An unrecognised body has entered the water: " + str(body))


## Handles the exit of the fishable water. 
## Connected to the body exited signal of this node.
func _on_water_exited(body: Node3D):
	# Check if the body that exited the water has a func for processing this event
	if body.has_method("on_water_exited"):
		# Call it if it does
		body.on_water_exited()
	else:
		print("An unrecognised body has exited the water: " + str(body))


## Handles the logic upon fishing rod action. 
## Connected to the action_pressed signal of the fishing rod container.
func _on_fishing_rod_action():
	print("Fishing water detected a fishing rod action")


## Finds the fishing rod container node and connects its action_pressed signal to the _on_fishing_rod_action function.
func _connect_fishing_rod():
	# Find the fishing rod container
	fishing_rod_container = get_node("/root/Main/FishingRod")
	if not fishing_rod_container:
		push_error("Fishing water failed to find the fishing rod container")
	# Connect its signal
	fishing_rod_container.action_pressed.connect(_on_fishing_rod_action)


## Finds the fishing float node.
func _connect_fishing_float():
	fishing_float = fishing_rod_container.get_node("FishingFloat")
	if not fishing_float:
		push_error("Fishing water failed to find the fishing float")
