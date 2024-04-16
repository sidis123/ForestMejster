extends Control

# The viewoport 2d in 3d that contains the pause menu.
# It should be the grandparent (2din3dviewport/viewport/menu)
@onready var pause_menu_viewport : Node3D = get_node("../../")

var player_camera: XRCamera3D

var paused: bool = false

@export_group("General")

@export var distance: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide the viewport
	pause_menu_viewport.visible = false
	pause_menu_viewport.set_enabled(false)
	
	var player: XROrigin3D = get_node("../../../PlayerInstance")
	
	if  player:
		player.controller_toggled_pause.connect(_on_pause_toggled)
		player_camera = player.get_node("PlayerCamera")
		
	# Make sure the scene is unpaused (pause gets inherited when reloading)
	get_tree().paused = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		position_menu()


func pause():
	paused = true
	pause_menu_viewport.visible = true
	pause_menu_viewport.set_enabled(true)
	print(get_tree())
	get_tree().paused = true
	
func unpause():
	paused = false
	pause_menu_viewport.visible = false
	pause_menu_viewport.set_enabled(false)
	get_tree().paused = false


func position_menu():
	# Get the forward direction of the player's camera
	var forward_dir: Vector3 = player_camera.global_transform.basis.z.normalized()
	
	# Position the menu in front of the player
	var new_position: Vector3 = player_camera.global_transform.origin - forward_dir * distance
	pause_menu_viewport.position = new_position
	
	# Rotate the viewport to face the player
	pause_menu_viewport.look_at(player_camera.global_transform.origin, Vector3.UP, true)


func _on_pause_toggled():
	if paused:
		unpause()
	else:
		pause()


func _on_resume_button_pressed():
	unpause()


func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_restart_game_button_pressed():
	# Reload the scene
	get_tree().reload_current_scene()


func _on_exit_game_button_pressed():
	get_tree().quit()
