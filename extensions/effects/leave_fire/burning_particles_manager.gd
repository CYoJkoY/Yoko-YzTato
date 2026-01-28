extends Node

var burning_particles_pool: Array = []
const MAX_POOL_SIZE: int = 20
const PARTICLE_TSCN = preload("res://mods-unpacked/Yoko-YzTato/extensions/effects/leave_fire/ground_burning_particles.tscn")

func _ready():
    for _i in range(10):
        var particle_instance: CPUParticles2D = PARTICLE_TSCN.instance()
        particle_instance.visible = false
        add_child(particle_instance)
        burning_particles_pool.append(particle_instance)

func get_burning_particle():
    for particle in burning_particles_pool:
        if !particle.is_active:
            return particle
    
    if burning_particles_pool.size() < MAX_POOL_SIZE:
        var new_particle: CPUParticles2D = PARTICLE_TSCN.instance()
        new_particle.visible = false
        add_child(new_particle)
        burning_particles_pool.append(new_particle)
        return new_particle
    
    return null
