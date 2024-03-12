extends XROrigin3D

var xr_interface: XRInterface
var pause_menu: Node

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR connected")
		
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		get_viewport().use_xr = true
	else:
		print(("OpenXR not connected !"))
		
	pause_menu = get_node("/root/Main/PauseMenuContainer/Viewport/PauseMenu")
	if pause_menu == null:
		print("Error: Pause menu not found by player")
	else:
		print(pause_menu)
	
	if pause_menu != null && pause_menu.has_signal("Paused") && pause_menu.has_signal("Unpaused"):
		pause_menu.Paused.connect(_on_paused)
		pause_menu.Unpaused.connect(_on_unpaused)

func _on_paused():
	# Disables the player's ability to move and interact
	$LeftHand/MovementDirect.enabled = false
	$LeftHand/FunctionPickup.enabled = false
	$RightHand/FunctionPickup.enabled = false
	# Enables the pointers so the player could interact with the menu
	$LeftHand/FunctionPointer.enabled = true
	$RightHand/FunctionPointer.enabled = true

func _on_unpaused():
	# Enables the player's ability to move and interact
	$LeftHand/MovementDirect.enabled = true
	$LeftHand/FunctionPickup.enabled = true
	$RightHand/FunctionPickup.enabled = true
	# Disables the pointers
	$LeftHand/FunctionPointer.enabled = false
	$RightHand/FunctionPointer.enabled = false
