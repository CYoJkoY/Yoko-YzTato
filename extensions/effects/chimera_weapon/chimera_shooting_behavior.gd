extends RangedWeaponShootingBehavior

# =========================== Extention =========================== #
func shoot_projectile(rotation:float = _parent.rotation, knockback: Vector2 = Vector2.ZERO) -> Node:
    var projectile = _yztato_chimera_shoot_projectile(rotation, knockback)

    return projectile

# =========================== Custom =========================== #
func _yztato_chimera_shoot_projectile(rotation:float = _parent.rotation, knockback: Vector2 = Vector2.ZERO) -> Node:
    var projectile_index: int
    var projectile_stats: RangedWeaponStats = _parent.current_stats
    if _parent.current_chimera_projs.size() != 0:
        projectile_index = max(0, _parent._nb_shots_taken - 1) % _parent.current_chimera_projs.size()
        projectile_stats = _parent.current_chimera_projs[projectile_index]

    var args = WeaponServiceSpawnProjectileArgs.new()
    args.knockback_direction = knockback
    args.effects = _parent.effects
    args.from_player_index = _parent.player_index

    if _parent.current_chimera_projs.size() != 0:
        var projectile_stats_and_args:Array = _yztato_modify_projectile(projectile_stats, args)
        projectile_stats = projectile_stats_and_args[0]
        args = projectile_stats_and_args[1]

    var projectile = WeaponService.spawn_projectile(
        _parent.muzzle.global_position,
        projectile_stats,
        rotation,
        _parent,
        args
    )
    projectile.set_damage_tracking_key("")

    emit_signal("projectile_shot", projectile)

    return projectile

# =========================== Method =========================== #
func _yztato_modify_projectile(projectile_stats: RangedWeaponStats, args: WeaponServiceSpawnProjectileArgs)-> Array:
    for effect in _parent.effects:
        if effect.get_id() == "yztato_chimera_weapon":
            var projectile_index = (_parent._nb_shots_taken - 1) % _parent.current_chimera_projs.size()
            var chimera_texture_sets = _parent.current_chimera_texture_sets
            if projectile_index >= _parent.current_chimera_projs_textures_paths.size():
                projectile_index = projectile_index % _parent.current_chimera_projs_textures_paths.size()
            if _parent.current_chimera_projs_textures_paths.size() == 0:
                return [projectile_stats, args]
            var texture_path = _parent.current_chimera_projs_textures_paths[projectile_index]
            for texture_data in chimera_texture_sets:
                if texture_path == texture_data.texture.resource_path:
                    if texture_data.enable_flags["modify_projectile_speed"]:
                        projectile_stats.projectile_speed = texture_data.projectile_speed

                    if texture_data.enable_flags["modify_effects"]:
                        args.effects = texture_data.effects
                    break
    return [projectile_stats, args]
