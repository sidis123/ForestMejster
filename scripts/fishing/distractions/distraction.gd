class_name Distraction
extends Node3D

var active: bool = false

func activate(spawn_position: Vector3, fishing_rod: FishingRod) -> void:
	push_error("activate() function not implemented by subclass")

func deactivate():
	set_process(false)
	visible = false
	active = false
