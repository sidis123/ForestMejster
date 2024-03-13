extends XROrigin3D

var xr_interface: XRInterface

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		# Put our physics in sync with our expected frame rate
		# Engine.iterations_per_second = 90
		# (Instead set in project settings)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR failed to initialize, please check if your headset is connected")


# TODO: turn the Turn Mode on MovementTurn into a setting
