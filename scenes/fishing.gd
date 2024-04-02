extends Area3D
class_name FishingWater


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


## This function is connected to the body entered signal
## It is called once an object (body parameter) enters the fishable water
func on_water_entered(body: Node3D):
	print(body)
	
