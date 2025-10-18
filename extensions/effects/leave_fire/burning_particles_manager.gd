extends Node

var burning_particles_pool = []
var max_pool_size = 20

func _ready():
	for _i in range(10):
		var particle_instance = ProgressData.Yztato.LeaveFire.Tscn.instance()
		particle_instance.visible = false
		add_child(particle_instance)
		burning_particles_pool.append(particle_instance)

func get_burning_particle():
	for particle in burning_particles_pool:
		if not particle.is_active:
			return particle
	
	if burning_particles_pool.size() < max_pool_size:
		var new_particle = ProgressData.Yztato.LeaveFire.Tscn.instance()
		call_deferred("add_child", new_particle)
		burning_particles_pool.append(new_particle)
		return new_particle
	
	return null
