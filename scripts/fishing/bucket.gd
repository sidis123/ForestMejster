class_name Bucket
extends PickableDispenser

## The queue containing the types of fish in the order they've been added
var _fish_queue : Array[Fish.FishType] = []

var _fish : Fish = null

func _process(_delta):
	if _fish and not _fish.is_picked_up():
		_fish_queue.append(_fish.type)
		_fish.queue_free()

## Test if this object can dispense a pickup
func can_pick_up(by: Node3D) -> bool:
	return _fish_queue.size() > 0


## Instantiate the scene with the last fish type
func _get_dispensable_instance():
	var fish_type = _fish_queue.pop_back()
	# NOTE: very manual matching of type to index in the array of dispensed scenes
	match fish_type:
		Fish.FishType.Kuoja:
			return dispensed_scenes[0].instantiate()
		Fish.FishType.Lynas:
			return dispensed_scenes[1].instantiate()
		Fish.FishType.Raude:
			return dispensed_scenes[2].instantiate()
		_:
			return null


## Save a ref to a fish that enters the bucket
func _on_body_entered(body):
	if body is Fish:
		_fish = body as Fish


## Remove the ref
func _on_body_exited(body):
	if body == _fish:
		_fish = null
