extends Node3D

var timer = 0
@export var stopTime = 10  # Stop emitting particles after 10 seconds

func _ready():
	start_timer()

func start_timer():
	timer = stopTime

func _process(delta):
	if timer > 0:
		timer -= delta
		if timer <= 0:
			stop_emission()

func stop_emission():
	var fire_particles = $Fire/GPUParticles3D
	if fire_particles:
		fire_particles.emitting = false  # Stop emitting particles
	else:
		print("Fire particles node not found!")

func _on_Campfire_body_entered(body):
	if body.is_in_group("fire_wood"):
		reset_timer()
		body.queue_free()  # Make the object disappear

func reset_timer():
	timer = stopTime
	var fire_particles = $Fire/GPUParticles3D
	if fire_particles:
		fire_particles.emitting = true  # Start emitting particles
		print("Particles restarted")
	else:
		print("Fire particles node not found!")
	start_timer()

