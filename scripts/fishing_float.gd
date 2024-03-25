extends RigidBody3D

var target: Node3D
var fishing_rod_container: Node3D
#var reset: bool = false

# Spring force constant
const k := 5.0

# Whether the float is connected to the fishing rod
var connected: bool = true

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
		global_position = target.global_position

# Called during physics processing, allowing safe reading and modification of the object's simulation state 
#func _integrate_forces(state):
	#if connected:
		#if reset:
			#state.transform.origin = target.transform.origin
			#reset = false
		#var force_direction: Vector3 = target.global_position - global_position
		#var force: Vector3 = force_direction * k
		#state.apply_force(force, Vector3.ZERO) 
	
# Handles the interaction signal from the fishing rod
func _on_action_pressed():
	connected = !connected
	if connected:
		freeze = true
	else:
		freeze = false
		linear_velocity = target.estimated_velocity
	#if connected:
		#reset = true

# Detects collisions
func _on_body_entered(body):
	#print(body)
	var layer = body.get_collision_layer()
	if layer and layer == 10: # check if colliding with fishable water
		pass
	else:
		# Reset if colliding with anything else
		connected = true
		freeze = true
