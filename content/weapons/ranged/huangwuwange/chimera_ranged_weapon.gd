extends RangedWeapon

# EFFECT : chimera_weapon_effect
var current_chimera_projs: Array = []
var current_chimera_projs_textures_paths: Array = []
var current_chimera_texture_sets: Array = []

# =========================== Extention =========================== #
func init_stats(at_wave_begin:bool = true)-> void :
    .init_stats(at_wave_begin)
    _yztato_chimera_init_stats()

# =========================== Custom =========================== #
func _yztato_chimera_init_stats()-> void:
    for effect in effects:
        if effect.get_id() != "yztato_chimera_weapon": continue
        
        for proj_stats in effect.chimera_projectile_stats:
            var projectile_instance = proj_stats.projectile_scene.instance()
            var sprite_node = projectile_instance.get_node_or_null("Sprite")
            current_chimera_projs_textures_paths.push_back(sprite_node.texture.resource_path)
            projectile_instance.queue_free()
            current_chimera_projs.push_back(WeaponService.init_ranged_stats(proj_stats, player_index))
        
        for proj_texture_set in effect.chimera_texture_sets:
            current_chimera_texture_sets.append(proj_texture_set)
