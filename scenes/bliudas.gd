extends MeshInstance3D

enum FishState {
	NORMAL,
	ON_BLIUDAS
}

var fish_state = FishState.NORMAL

func _ready():
	# Connect the body_entered signal of the Area3D to the "_on_area_body_entered" function
	var area = $Area3D
	if area:
		area.connect("body_entered", Callable(self, "_on_area_body_entered"))

func _on_area_body_entered(body):
	# Check if the entering body is in the "Cookable" group
	if body.is_in_group("Cookable"):
		# Set fish state to ON_BLIUDAS
		fish_state = FishState.ON_BLIUDAS
		
		# Disable gravity for the entering body
		if body.has_method("set_gravity_scale"):
			body.set_gravity_scale(0)
		
		# Calculate the midpoint of the "bliudas" object
		var midpoint = global_transform.origin
		
		# Hardcoded values for X, Y, and Z positions
		var x_offset = 0.05
		var y_offset = 0.475
		var z_offset = 0.25
		
		# Move the entering body to the adjusted position
		body.global_transform.origin.x = midpoint.x + x_offset
		body.global_transform.origin.y = midpoint.y + y_offset
		body.global_transform.origin.z = midpoint.z + z_offset
		
		# Rotate the entering body 90 degrees on the X axis
		body.global_transform.basis = Basis(Vector3(0, 0, 1), deg_to_rad(90))

		# Remove linear velocity
		body.linear_velocity = Vector3.ZERO
		
		# Remove angular velocity
		body.angular_velocity = Vector3.ZERO
		
		
		
		print("Fish placed on the bliudas")
		print("Starting Cooking script")
		# Start the script (replace with actual script start logic)
		#body.start_cookingshaderscript()  # Start the cookingshaderscript
