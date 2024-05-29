extends Node3D

signal kipsas_toggle_movement

var time_accumulator = 0.0
var interval = 5.0
var degam=false
var max_distance = 12  # Maximum distance to play sound
var puntukas_position = Vector3(-3.622, 0.812, 16.042)  # Replace with the actual coordinates of puntukas



func _process(delta):
	time_accumulator += delta
	if time_accumulator >= interval:
		emit_signal("kipsas_toggle_movement")
		degam = !degam
		time_accumulator = 0.0
	
	var eye1 = $Fire/GPUParticles3D
	var eye2 = $Fire2/GPUParticles3D
	var sound_player = $AudioStreamPlayer3D  # Assuming the AudioStreamPlayer3D node is a child of this node

# Get references to the puntukas and player nodes
	var player = get_node("/root/Staging/Scene/Main/XROrigin3D")  # Adjust the path to your player node
	
	var distance_to_player = puntukas_position.distance_to(player.global_transform.origin)

	if degam:
		eye1.emitting = true
		eye2.emitting = true
		if distance_to_player <= max_distance and not sound_player.playing:  # Play sound if within distance
			sound_player.play()
	else:
		eye1.emitting = false
		eye2.emitting = false
		sound_player.stop()  # Stop the sound when degam is false
