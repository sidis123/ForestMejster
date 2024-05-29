extends Node3D

@export var move_speed: float = 4.0
var is_moving = true
var kipsas_collision = null
var tent_instance = null
var initial_position: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	var puntukas = get_node("/root/Staging/Scene/Main/Combat/Puntukass")
	puntukas.kipsas_toggle_movement.connect(_on_Bezdukas_toggle_movement)
	kipsas_collision = get_node("Cube/BezdukasDissapearingBody/CollisionShape3D")

# Called when the movement state is toggled.
func _on_Bezdukas_toggle_movement():
	is_moving = !is_moving  # Toggle the movement state
	
	if !is_moving:
		# Instantiate the Tent node
		if is_instance_valid(kipsas_collision):
			tent_instance = preload("res://scenes/rock_small_v_1.tscn").instantiate()
			tent_instance.global_transform.origin = self.global_transform.origin
			get_tree().get_root().add_child(tent_instance)
			tent_instance.visible = true
			# Store the current position before hiding
			initial_position = self.global_transform.origin
			# Remove the current Kipsas node from the scene
			self.visible = false
			if is_instance_valid(kipsas_collision):
				kipsas_collision.disabled = true
		# Stop animation when not moving

	else:
		# Remove the Tent node from the scene
		if is_instance_valid(kipsas_collision):
			if tent_instance:
				tent_instance.queue_free()
		# Restore position
			self.global_transform.origin = initial_position
			self.visible = true
			if is_instance_valid(kipsas_collision):
				kipsas_collision.disabled = false
		# Play walking animation when moving


func _physics_process(delta: float) -> void:
	pass
