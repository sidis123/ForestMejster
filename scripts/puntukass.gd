extends Node3D

signal kipsas_toggle_movement

var time_accumulator = 0.0
var interval = 5.0
var degam=false


func _process(delta):
	time_accumulator += delta
	if time_accumulator >= interval:
		emit_signal("kipsas_toggle_movement")
		degam = !degam
		time_accumulator = 0.0
	
	var eye1 = $Fire/GPUParticles3D
	var eye2 = $Fire2/GPUParticles3D
	if degam:
		eye1.emitting = true
		eye2.emitting = true
	else:
		eye1.emitting = false
		eye2.emitting = false
