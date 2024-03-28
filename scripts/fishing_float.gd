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
	#issisaugot rigid body positiona i variabla ir tada naudot jy kur zuvy spawnint
	var positionFortheFish=global_position
	var targetino = Vector3(22.46, 0, 24.058)
	connected = !connected
	
	
	if connected:
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
		landed_in_water.emit()
	else:
		# Ff colliding with anything else, the float is reset
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
			# Calculate initial velocity to hit the target with an arched trajectory
			# Calculate initial velocity to hit the target with an arched trajectory
			var gravity = -9.8 # Gravity value (adjust as needed)
			var displacement = target_position - fish_spawn_position
			var time_to_reach_target = -displacement.y / gravity
			var horizontal_velocity = Vector3(displacement.x / (time_to_reach_target * 10), 0, displacement.z / (time_to_reach_target * 10)) # Slower horizontal velocity
			var vertical_velocity = Vector3(0, -gravity * (time_to_reach_target * 6), 0) # Higher vertical velocity
			new_fish.linear_velocity = horizontal_velocity + vertical_velocity
		else:
			print("Failed to instance fish.")
	else:
		print("Fish scene not found or could not be loaded.")


















