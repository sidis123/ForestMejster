extends MeshInstance3D

var fishing_float: RigidBody3D
var fishing_rod_container: Node3D
@onready var collision_shape = get_node("/root/Main/Water/FishingWater/FishingWaterCollisionShape")

#var sceneA = preload("res://path_to_scene_A.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	fishing_float = get_node("/root/Main/FishingRod/FishingFloat")
	fishing_rod_container = get_node("/root/Main/FishingRod")
	#fishing_float.landed_in_water.connect(_on_landed_in_water)
	#fishing_rod_container.action_pressed.connect(_on_action_pressed)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_height() -> float:
	return global_position.y

func _on_landed_in_water():
	# Disable the CollisionShape3D
	collision_shape.disabled = true

func _on_action_pressed():
	collision_shape.disabled = false
