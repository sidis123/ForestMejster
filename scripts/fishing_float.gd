extends RigidBody3D

# Whether the float is connected to the fishing rod
var connected: bool = true

# The float target that the float is attached to when connected
var target: Node3D

# The fishing rod container
var fishing_rod_container: Node3D

# Signal for when the float lands in water (TODO: use this to start the fishing minigame)
signal landed_in_water

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
	
	
# Called every physics frame
func _physics_process(delta):
	if connected:
		# Set the position of the float to the target
		global_position = target.global_position
	
	
# Handles the interaction signal from the fishing rod
func _on_action_pressed():
	connected = !connected
	if connected:
		freeze = true
	else:
		freeze = false
		linear_velocity = target.estimated_velocity
	
	
# Detects collisions
func _on_body_entered(body):
	var layer = body.get_collision_layer()
	if layer and layer == pow(2,9): 
		# If colliding with fishable water, a signal is emitted  
		landed_in_water.emit()
	else:
		# Ff colliding with anything else, the float is reset
		connected = true
		freeze = true
