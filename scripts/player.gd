extends XROrigin3D

var xr_interface: XRInterface

# Right controller variables
var xr_controller_right: XRController3D
var movement_turn_right: XRToolsMovementTurn
var function_pickup_right: XRToolsFunctionPickup
var function_pointer_right: XRToolsFunctionPointer

# Left controller variables
var xr_controller_left: XRController3D
var movement_direct_left: XRToolsMovementDirect
var function_pickup_left: XRToolsFunctionPickup
var function_pointer_left: XRToolsFunctionPointer

# Signals
signal pause_toggled

func _ready():
	init_xr_interface()
	init_controllers()

func init_xr_interface() -> void:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR failed to initialize, please check if your headset is connected")
		
func init_controllers() -> void:
	# Initialise the right controller and its children
	xr_controller_right = XRHelpers.get_right_controller(self)
	if not xr_controller_right:
		push_error("Right controller could not be found.")
	else:
		xr_controller_right.button_pressed.connect(_on_right_controller_button_pressed)
		xr_controller_right.button_released.connect(_on_right_controller_button_released)
		movement_turn_right = xr_controller_right.get_node("MovementTurn")
		function_pickup_right = xr_controller_right.get_node("FunctionPickupRight")
		function_pointer_right = xr_controller_right.get_node("FunctionPointer")
		if not function_pointer_right:
			push_error("The right function pointer was not found")
		else:
			function_pointer_right.visible = false
			function_pointer_right.set_process(false)
	
	# Initialise the left controller and its children
	xr_controller_left = XRHelpers.get_left_controller(self)
	if not xr_controller_left:
		push_error("Left controller could not be found.")
	else:
		xr_controller_left.button_pressed.connect(_on_left_controller_button_pressed)
		xr_controller_left.button_released.connect(_on_left_controller_button_released)
		movement_direct_left = xr_controller_left.get_node("MovementDirect")
		function_pickup_left = xr_controller_left.get_node("FunctionPickupLeft")
		function_pointer_left = xr_controller_left.get_node("FunctionPointer")
		if not function_pointer_left:
			push_error("The left function pointer was not found")
		else:
			function_pointer_left.visible = false
			function_pointer_left.set_process(false)

func toggle_pause() -> void:
	pause_toggled.emit()

func _on_right_controller_button_pressed(p_button: String) -> void:
	print(p_button + " was pressed on the right controller")	
	match p_button:
		"ax_button":
			function_pointer_right.set_enabled(true)
		_: 
			print("Button input unhandled")
			
func _on_right_controller_button_released(p_button: String) -> void:
	print(p_button + " was released on the right controller")
	match p_button:
		"ax_button":
			function_pointer_right.set_enabled(false)
		_: 
			print("Button release unhandled")
			
func _on_left_controller_button_pressed(p_button: String) -> void:
	print(p_button + " was pressed on the left controller")
	match p_button:
		"ax_button":
			function_pointer_left.visible = true
			function_pointer_left.set_process(true)
		"menu_button":
			toggle_pause()
		_: 
			print("Button press unhandled")
			
func _on_left_controller_button_released(p_button: String) -> void:
	print(p_button + " was released on the left controller")
	match p_button:
		"ax_button":
			function_pointer_left.visible = false
			function_pointer_left.set_process(false)
		_: 
			print("Button release unhandled")
	


# TODO: turn the Turn Mode on MovementTurn into a setting
