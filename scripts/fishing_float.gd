extends RigidBody3D

# Whether the float is connected to the fishing rod
var connected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called every physics frame
func _physics_process(delta):
	pass

# Called during physics processing, allowing safe reading and modification of the object's simulation state 
func _integrate_forces(state):
	pass
	
# Handles the interaction signal from the fishing rod
func _on_interaction():
	pass
