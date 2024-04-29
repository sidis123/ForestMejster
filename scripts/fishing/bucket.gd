@tool
class_name Bucket
extends XRToolsPickable

# The fish scene that will be spawned upon interaction
const FishScene = preload("res://scenes/fishing/fish.tscn")

var fish_instance : Fish = null

## Overrides the pick up function of the pickable to spawn the fish
func pick_up(by: Node3D) -> void:
	if FishScene:
		# Create a new instance of the fish
		fish_instance = FishScene.instantiate()
		
		if fish_instance:
			# Add the fish and set it up
			add_child(fish_instance)
			fish_instance.global_position = global_position

			# Call the fish's pick up function
			fish_instance.pick_up(by)

func let_go(by: Node3D, p_linear_velocity: Vector3, p_angular_velocity: Vector3) -> void:
	if is_instance_valid(fish_instance):
		# Relay the let go function to the fish instance
		fish_instance.let_go(by, p_linear_velocity, p_angular_velocity)
		# Stop tracking the instance (it will now serve as an independant pickable)
		fish_instance = null
