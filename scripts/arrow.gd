extends XRToolsPickable

const force_factor = 0.1

#cia krc funkcija skirta kad graziai skristu strele, bet neisejo tai velesniem bandymam nes sjp visai graziai ir db skrenda
#func _physics_process(delta):
#	if freeze_mode == RigidBody3D.FREEZE_MODE_KINEMATIC:
#		var forward_direction = -global_transform.basis.x
#		var forward_motion = linear_velocity
#	
#		var speed = forward_motion.length()
#		if speed > 1.0:
#			forward_motion = forward_motion.normalized()
#			var dot = 1.0 - max(0.0,forward_motion.dot(forward_direction))
#			var sideways = forward_motion.cross(forward_direction).normalized()
#			var force_vector = sideways.cross(forward_direction).normalized()
#			
#			var position = global_transform.basis *$ArrowMesh.transform.origin
#			apply_impulse(position,force_vector * dot * force_factor * speed)
			
			
			
#funkcija velesniam combatui i ka pataike tt.
#reik idet viska i ka gali pataikyt strele
func _on_Arrow_body_entered(body):
	#just react to the floor for now, this can be improved upon loads
	if body.name == "BezdukasBody":
		print("pataike i Bezduka :D")
		freeze=true
		freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	if body.name=="BezdukasDissapearingBody":
		print("pataike i Bezduka dissapearing bezduka :D")
		if body.get_parent():
			body.get_parent().queue_free()  # This will remove the parent of the BezdukasDissapearing node from the scene
		# Spawn a new Steak node at the same position as the arrow
		var steak_instance = load("res://scenes/steak.tscn").instantiate()
		steak_instance.global_transform.origin = global_transform.origin 
		get_tree().get_root().add_child(steak_instance)  # Add the new Steak node to the scene tree
		#spawn a new arrow
		#var arrow_instance = preload("res://scenes/arrow.tscn").instantiate()
		#var offset = Vector3(2.0, 0.0, 0.0)  # Adjust the X value as needed
		#arrow_instance.global_transform.origin = global_transform.origin + offset
		#get_tree().get_root().add_child(arrow_instance)  # Add the new Steak node to the scene tree
		queue_free()

