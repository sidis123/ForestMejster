extends Node3D

## Delay before the next impulse
@export var impulse_delay = 2.0
var impulse_time = 0.0

## The movement speed of the start node
@export var move_speed = 1.5

var end: RigidBody3D
var start: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	end = $Container/End
	start = $Container/Start


func _process(delta):
	if Input.is_action_pressed("ui_left"):
		var new_position = start.global_position
		new_position.x -= move_speed * delta
		start.global_position = new_position
		
	if Input.is_action_pressed("ui_right"):
		var new_position = start.global_position
		new_position.x += move_speed * delta
		start.global_position = new_position
		
	if Input.is_action_pressed("ui_up"):
		var new_position = start.global_position
		new_position.z -= move_speed * delta
		start.global_position = new_position
		
	if Input.is_action_pressed("ui_down"):
		var new_position = start.global_position
		new_position.z += move_speed * delta
		start.global_position = new_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	impulse_time += delta
	if impulse_time >= impulse_delay:
		impulse_time = 0.0
		var random_force = Vector3(
			randf_range(-8, 8),  # Random X component between 0 and 1
			randf_range(0, 8),  # Random Y component between 0 and 1
			randf_range(-8, 8)   # Random Z component between 0 and 1
		)
		end.apply_impulse(random_force)
