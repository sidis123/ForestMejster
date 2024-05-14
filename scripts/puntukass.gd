extends Node3D

signal kipsas_toggle_movement

var time_accumulator = 0.0
var interval = 5.0

func _process(delta):
	time_accumulator += delta
	if time_accumulator >= interval:
		emit_signal("kipsas_toggle_movement")
		time_accumulator = 0.0
