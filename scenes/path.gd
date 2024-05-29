extends Node

var path_follow: PathFollow3D
var path_follow1: PathFollow3D
var path_follow2: PathFollow3D
var path_follow3: PathFollow3D
var path_follow4: PathFollow3D
var path_follow5: PathFollow3D
var move_speed: float = 1
var is_movement_enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	path_follow = $Path3D/PathFollow3D
	path_follow1 = $Path3D2/PathFollow3D
	path_follow2 = $Path3D3/PathFollow3D
	path_follow3 = $Path3D4/PathFollow3D
	path_follow4 = $Path3D5/PathFollow3D
	path_follow5 = $Path3D6/PathFollow3D
	if path_follow == null:
		print("Error: PathFollow3D not found")
	else:
		print("PathFollow3D successfully loaded")
	var puntukas = get_node("/root/Staging/Scene/Main/Combat/Puntukass")
	puntukas.kipsas_toggle_movement.connect(_on_Bezdukas_toggle_movement)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_movement_enabled and path_follow != null and path_follow.visible:  # Only move if enabled and visible
		path_follow.progress -= move_speed * delta
		path_follow1.progress -= move_speed * delta
		path_follow2.progress -= move_speed * delta
		path_follow3.progress -= move_speed * delta
		path_follow4.progress -= move_speed * delta
		path_follow5.progress -= move_speed * delta
# Called when the movement state is toggled.
func _on_Bezdukas_toggle_movement():
	is_movement_enabled = !is_movement_enabled
