extends Node3D

var wood_instances := []
var wood_counter := 0

func _ready():
	pass

func _process(delta):
	pass

func _on_pile_area_exited(area):
	if area.is_in_group("wood"):
		if wood_instances.size() >= 200:
			# Delete the oldest instance
			var oldest_instance: Node = wood_instances.pop_front()
			oldest_instance.queue_free()
			print("Oldest log was deleted. ID: " + str(oldest_instance.get_instance_id()))
		
		# Remove from group so it doesn't cause issues later on
		area.remove_from_group("wood")

		# Spawn a new wood object
		var new_wood_instance = preload("res://scenes/pickable_wood.tscn").instantiate()
		if new_wood_instance:
			get_parent().add_child(new_wood_instance)
			wood_instances.append(new_wood_instance)
			new_wood_instance.global_transform.origin = Vector3(-4.268, 1.478, 1.282)
			wood_counter += 1
			print("New log was spawned. ID: " + str(wood_counter))
