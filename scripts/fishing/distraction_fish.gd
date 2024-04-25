class_name DistractionFish
extends Distraction

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

func spawn(spawn_position: Vector3):
	global_position = spawn_position
	var random_angle = randf_range(0, TAU)
	rotation.y = random_angle
	animation_player.play("jump")
	print("Fish distraction spawned")

func _on_animation_finished(anim_name: StringName):
	if anim_name == "jump":
		queue_free()
