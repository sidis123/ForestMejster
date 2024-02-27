extends Node3D

var pause_menu_container: Node
var paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_menu_container = $PauseMenuContainer

	if not pause_menu_container:
		print("PauseMenuContainer not found!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		handlePause()
		
func handlePause():
	paused = !paused
	
	if paused:
		# Engine.time_scale = 0 - Can't use time_scale with XR
		pause_menu_container.show()
	else:
		pause_menu_container.hide()
