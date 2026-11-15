extends Pet

# Chimera pet summoned by consuming monster yarn.
# It lives for a single wave: the game kills every pet during the wave cleanup and
# only re-spawns the pets stored in RunData, so this summon never returns.

const COMPOSITE_SIZE: Vector2 = Vector2(96, 96)
const PANEL_HALF_SIZE: Vector2 = Vector2(48, 48)
const PANEL_STRIP_SIZE: Vector2 = Vector2(96, 48)
const MAX_PARTS: int = 3
const FALLBACK_ATTACK_CD: float = 0.8
const FALLBACK_DAMAGE: int = 8
const MELEE_RANGE: float = 52.0
const LEAP_RANGE: float = 260.0
const VOLLEY_RANGE: float = 300.0
const VOLLEY_PROJECTILE_SPEED: int = 700
const VOLLEY_EXTRA_PROJECTILES: int = 3
const MAX_PROJECTILES: int = 12
const PROJECTILE_MAX_RANGE: int = 900
const MAX_ABILITY_RANGE: float = 1200.0
const MIN_COOLDOWN: float = 0.3
const MAX_USABLE_COOLDOWN: float = 60.0
const BURST_COOLDOWN: float = 2.0
const MIN_PROJECTILE_SPEED: int = 300
const MAX_PROJECTILE_SPEED: int = 1500
const MIN_CHARGE_SPEED: float = 200.0
const CHARGE_HIT_RADIUS: float = 36.0
const CHASE_MIN_SPEED: float = 80.0

const KIND_MELEE: String = "melee"
const KIND_RANGED: String = "ranged"
const KIND_CHARGE: String = "charge"
const KIND_LEAP: String = "leap"
const KIND_VOLLEY: String = "volley"

var _abilities: Array = []
var _chase_target_position = null
var _chase_speed: float = 0.0
var _active_charge: Dictionary = {}
var _active_leap: Dictionary = {}

func _ready() -> void:
    ._ready()
    can_sleep = false

func update_data(_effect: PetEffect) -> void:
    pass

func build_from_enemies(enemies: Array) -> bool:
    var candidates: Array = _get_valid_enemies(enemies)
    if candidates.empty():
        return false
    candidates.shuffle()
    candidates = candidates.slice(0, min(MAX_PARTS, candidates.size()))
    var composite: Texture = _compose_textures(_get_part_textures(candidates))
    if composite == null:
        return false
    sprite.texture = composite
    _abilities = _build_abilities(candidates)
    return not _abilities.empty()

func _get_part_textures(candidates: Array) -> Array:
    var textures: Array = []
    for candidate in candidates:
        textures.append(candidate.sprite.texture)
    while textures.size() < MAX_PARTS:
        textures.append(textures[0])
    return textures

func _get_valid_enemies(enemies: Array) -> Array:
    var valid: Array = []
    for candidate in enemies:
        if not is_instance_valid(candidate) or candidate.dead:
            continue
        if candidate.sprite == null or candidate.sprite.texture == null:
            continue
        valid.append(candidate)
    return valid

func _build_abilities(enemies: Array) -> Array:
    var abilities: Array = []
    for source in enemies:
        abilities.append_array(_build_source_abilities(source))
    return abilities

# Each chimera part contributes every attack behavior of its source enemy.
func _build_source_abilities(source: Node) -> Array:
    var abilities: Array = []
    for behavior in _get_source_behaviors(source):
        var ability: Dictionary = _make_special_ability(behavior, source)
        if _is_usable_ability(ability):
            abilities.append(ability)
    if abilities.empty():
        abilities.append(_make_melee_ability(source))
    return abilities

# The base game parks unused behaviors at a sentinel cooldown so they never fire.
# Hand-triggered behaviors are converted into bursts instead of being inherited
# with their unusable cooldown.
func _is_usable_ability(ability: Dictionary) -> bool:
    if ability.empty():
        return false
    return ability.cooldown <= MAX_USABLE_COOLDOWN

func _is_disabled_cooldown(cooldown: float) -> bool:
    return cooldown > MAX_USABLE_COOLDOWN

func _get_source_behaviors(source: Node) -> Array:
    var behaviors = source.get("_all_attack_behaviors")
    if behaviors is Array and not behaviors.empty():
        return behaviors
    var primary = source.get("_attack_behavior")
    if primary == null:
        return []
    return [primary]

func _make_special_ability(behavior: AttackBehavior, source: Node) -> Dictionary:
    if behavior is ShootingAttackBehavior:
        return _make_ranged_ability(behavior, source)
    if behavior is ChargingAttackBehavior:
        return _make_charge_ability(behavior, source)
    if behavior is JumpAttackBehavior:
        return _make_leap_ability(behavior)
    if behavior is SpawningAttackBehavior:
        return _make_volley_ability(behavior, source)
    return {}

func _make_ranged_ability(behavior: ShootingAttackBehavior, source: Node) -> Dictionary:
    if _is_disabled_cooldown(_frames_to_seconds(behavior.cooldown)):
        return _make_burst_ability(behavior, source)
    var ability: Dictionary = _make_ability(KIND_RANGED)
    ability.cooldown = _frames_to_seconds(behavior.cooldown)
    ability.min_range = behavior.min_range
    ability.max_range = _clamp_range(behavior)
    ability.damage = max(_get_projectile_damage(behavior), _get_source_damage(source))
    ability.projectile_count = clamp(behavior.number_projectiles, 1, MAX_PROJECTILES)
    ability.projectile_spread = behavior.projectile_spread
    ability.projectile_speed = clamp(behavior.projectile_speed, MIN_PROJECTILE_SPEED, MAX_PROJECTILE_SPEED)
    return ability

# A disabled behavior only fires when its enemy triggers it by hand (a pufferfish
# bursting its spikes on death, for example). The chimera inherits that barrage
# as a periodic radial burst so the ability is never lost.
func _make_burst_ability(behavior: ShootingAttackBehavior, source: Node) -> Dictionary:
    var ability: Dictionary = _make_ability(KIND_VOLLEY)
    ability.cooldown = BURST_COOLDOWN
    ability.max_range = VOLLEY_RANGE
    ability.damage = max(_get_projectile_damage(behavior), _get_source_damage(source))
    ability.projectile_count = clamp(
        behavior.number_projectiles, VOLLEY_EXTRA_PROJECTILES, MAX_PROJECTILES
    )
    ability.projectile_speed = clamp(
        behavior.projectile_speed, MIN_PROJECTILE_SPEED, MAX_PROJECTILE_SPEED
    )
    return ability

func _make_charge_ability(behavior: ChargingAttackBehavior, source: Node) -> Dictionary:
    var ability: Dictionary = _make_ability(KIND_CHARGE)
    ability.cooldown = _frames_to_seconds(behavior.cooldown)
    ability.min_range = behavior.min_range
    ability.max_range = _clamp_range(behavior)
    ability.damage = _get_source_damage(source)
    ability.charge_speed = max(MIN_CHARGE_SPEED, behavior.charge_speed)
    ability.charge_duration = max(0.1, behavior.charge_duration)
    return ability

func _make_leap_ability(behavior: JumpAttackBehavior) -> Dictionary:
    var ability: Dictionary = _make_ability(KIND_LEAP)
    ability.cooldown = max(MIN_COOLDOWN, behavior.cooldown)
    ability.max_range = max(LEAP_RANGE, behavior.landing_radius)
    ability.damage = max(1, behavior.damage)
    ability.landing_radius = max(32.0, behavior.landing_radius)
    return ability

func _make_volley_ability(behavior: SpawningAttackBehavior, source: Node) -> Dictionary:
    var ability: Dictionary = _make_ability(KIND_VOLLEY)
    ability.cooldown = _frames_to_seconds(behavior.cooldown)
    ability.max_range = VOLLEY_RANGE
    ability.damage = _get_source_damage(source)
    ability.projectile_count = clamp(
        behavior.nb_to_spawn + VOLLEY_EXTRA_PROJECTILES,
        VOLLEY_EXTRA_PROJECTILES,
        MAX_PROJECTILES
    )
    ability.projectile_speed = VOLLEY_PROJECTILE_SPEED
    return ability

func _make_melee_ability(source: Node) -> Dictionary:
    var ability: Dictionary = _make_ability(KIND_MELEE)
    ability.damage = _get_source_damage(source)
    return ability

func _make_ability(kind: String) -> Dictionary:
    return {
        "kind": kind,
        "cooldown": FALLBACK_ATTACK_CD,
        "remaining": rand_range(0.1, 0.5),
        "min_range": 0.0,
        "max_range": MELEE_RANGE,
        "damage": FALLBACK_DAMAGE,
        "projectile_count": 1,
        "projectile_spread": 0.0,
        "projectile_speed": VOLLEY_PROJECTILE_SPEED,
        "charge_speed": MIN_CHARGE_SPEED,
        "charge_duration": 0.5,
        "landing_radius": 80.0
    }

func _frames_to_seconds(frames: float) -> float:
    return max(MIN_COOLDOWN, frames / 60.0)

# Several enemies keep their shooting range at a sentinel value because they only
# fire at a scripted moment. The chimera fires at will, so the inherited reach is
# bounded to something it can actually shoot across.
func _clamp_range(behavior: AttackBehavior) -> float:
    var reach: float = max(float(behavior.max_range), MELEE_RANGE)
    return clamp(reach, max(float(behavior.min_range) + MELEE_RANGE, MELEE_RANGE), MAX_ABILITY_RANGE)

func _get_projectile_damage(behavior: ShootingAttackBehavior) -> int:
    if behavior.projectile_damage > 0:
        return behavior.projectile_damage
    return int(max(1, behavior.damage))

func _get_source_damage(source: Node) -> int:
    if source.current_stats != null and source.current_stats.damage > 0:
        return source.current_stats.damage
    return FALLBACK_DAMAGE

func _compose_textures(textures: Array) -> Texture:
    var canvas: Image = Image.new()
    canvas.create(int(COMPOSITE_SIZE.x), int(COMPOSITE_SIZE.y), false, Image.FORMAT_RGBA8)
    canvas.fill(Color(0, 0, 0, 0))
    for index in textures.size():
        var panel_size: Vector2 = PANEL_STRIP_SIZE if index == 2 else PANEL_HALF_SIZE
        var panel: Image = _make_panel(textures[index], panel_size)
        if panel != null:
            canvas.blit_rect(panel, Rect2(Vector2.ZERO, panel.get_size()), _get_panel_position(index))
    var composite: ImageTexture = ImageTexture.new()
    composite.create_from_image(canvas, Texture.FLAG_FILTER)
    return composite

func _get_panel_position(index: int) -> Vector2:
    if index == 1:
        return Vector2(PANEL_HALF_SIZE.x, 0.0)
    if index == 2:
        return Vector2(0.0, PANEL_HALF_SIZE.y)
    return Vector2.ZERO

func _make_panel(texture: Texture, panel_size: Vector2) -> Image:
    if texture == null or not texture.has_method("get_data"):
        return null
    var source: Image = texture.get_data()
    if source == null or source.get_width() <= 0 or source.get_height() <= 0:
        return null
    var panel: Image = source.get_rect(Rect2(Vector2.ZERO, Vector2(source.get_width(), source.get_height())))
    panel.convert(Image.FORMAT_RGBA8)
    panel.resize(int(panel_size.x), int(panel_size.y), Image.INTERPOLATE_BILINEAR)
    return panel

func _physics_process(delta: float) -> void:
    ._physics_process(delta)
    _chase_target_position = null
    _chase_speed = 0.0
    if _end_of_wave or dead or not RunData.wave_in_progress:
        return
    _tick_abilities(delta)
    var target = _find_nearest_enemy()
    if target == null:
        return
    if not _active_charge.empty() or not _active_leap.empty():
        return
    var distance: float = global_position.distance_to(target.global_position)
    var ability_index: int = _pick_ready_ability(distance)
    if ability_index >= 0:
        _use_ability(ability_index, target)
        return
    _chase_target_position = target.global_position
    _chase_speed = max(CHASE_MIN_SPEED, float(current_stats.speed))

func _tick_abilities(delta: float) -> void:
    for ability in _abilities:
        ability.remaining = max(0.0, ability.remaining - delta)

func _find_nearest_enemy():
    if _entity_spawner_ref == null:
        return null
    var nearest = null
    var nearest_distance: float = INF
    for candidate in _get_valid_enemies(_entity_spawner_ref.get_all_enemies(false)):
        var distance := global_position.distance_squared_to(candidate.global_position)
        if distance < nearest_distance:
            nearest = candidate
            nearest_distance = distance
    return nearest

func _pick_ready_ability(distance: float) -> int:
    for index in _abilities.size():
        var ability: Dictionary = _abilities[index]
        if ability.remaining > 0.0 or not Utils.is_between(distance, ability.min_range, ability.max_range):
            continue
        return index
    return -1

func _use_ability(index: int, target: Node) -> void:
    var ability: Dictionary = _abilities[index]
    ability.remaining = ability.cooldown
    match ability.kind:
        KIND_RANGED:
            _fire_ranged(ability, target)
        KIND_VOLLEY:
            _fire_volley(ability)
        KIND_CHARGE:
            _start_charge(ability, target)
        KIND_LEAP:
            _start_leap(ability, target)
        _:
            target.take_damage(ability.damage + _get_suture_bonus(), TakeDamageArgs.new(player_index))

func _get_suture_bonus() -> int:
    if player_index < 0:
        return 0
    return int(Utils.get_stat(Utils.stat_yztato_suture_hash, player_index) / 2.0)

func _fire_ranged(ability: Dictionary, target: Node) -> void:
    var direction: Vector2 = global_position.direction_to(target.global_position)
    for index in ability.projectile_count:
        var angle: float = direction.angle()
        if ability.projectile_count > 1:
            var spread_step: float = float(index) / float(ability.projectile_count - 1)
            angle += lerp(-ability.projectile_spread, ability.projectile_spread, spread_step)
        _spawn_projectile(ability, angle)

func _fire_volley(ability: Dictionary) -> void:
    for index in ability.projectile_count:
        _spawn_projectile(ability, TAU * float(index) / float(ability.projectile_count))

func _spawn_projectile(ability: Dictionary, angle: float) -> void:
    var stats: RangedWeaponStats = RangedWeaponStats.new()
    stats.damage = ability.damage + _get_suture_bonus()
    stats.cooldown = int(ability.cooldown * 60.0)
    stats.projectile_speed = ability.projectile_speed
    stats.max_range = PROJECTILE_MAX_RANGE
    var args: WeaponServiceSpawnProjectileArgs = WeaponServiceSpawnProjectileArgs.new()
    args.from_player_index = player_index
    args.knockback_direction = Vector2.RIGHT.rotated(angle)
    WeaponService.spawn_projectile(global_position, stats, angle, self, args)

func _start_charge(ability: Dictionary, target: Node) -> void:
    _active_charge = {
        "direction": global_position.direction_to(target.global_position),
        "speed": ability.charge_speed,
        "duration": ability.charge_duration,
        "damage": ability.damage,
        "hit_enemies": []
    }

func _start_leap(ability: Dictionary, target: Node) -> void:
    _active_leap = {
        "start": global_position,
        "target": target.global_position,
        "elapsed": 0.0,
        "duration": 0.7,
        "radius": ability.landing_radius,
        "damage": ability.damage
    }

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
    ._integrate_forces(state)
    if not _active_charge.empty():
        _advance_charge(state)
        return
    if not _active_leap.empty():
        _advance_leap(state)
        return
    if _chase_target_position == null or not _can_move or _move_locked:
        return
    var to_target: Vector2 = _chase_target_position - state.transform.origin
    state.linear_velocity = to_target.normalized() * _chase_speed if to_target.length() > 4.0 else Vector2.ZERO

func _advance_charge(state: Physics2DDirectBodyState) -> void:
    state.linear_velocity = _active_charge.direction * _active_charge.speed
    _active_charge.duration -= state.step
    _apply_charge_damage(_active_charge)
    if _active_charge.duration <= 0.0:
        _active_charge = {}

func _advance_leap(state: Physics2DDirectBodyState) -> void:
    _active_leap.elapsed += state.step
    var progress: float = min(1.0, _active_leap.elapsed / _active_leap.duration)
    var leap_transform: Transform2D = state.transform
    leap_transform.origin = _active_leap.start.linear_interpolate(_active_leap.target, progress)
    state.transform = leap_transform
    if progress >= 1.0:
        _apply_leap_damage(_active_leap)
        _active_leap = {}

func _apply_leap_damage(leap: Dictionary) -> void:
    if _entity_spawner_ref == null:
        return
    for candidate in _get_valid_enemies(_entity_spawner_ref.get_all_enemies(false)):
        if global_position.distance_to(candidate.global_position) <= leap.radius:
            candidate.take_damage(leap.damage + _get_suture_bonus(), TakeDamageArgs.new(player_index))

func _apply_charge_damage(charge: Dictionary) -> void:
    if _entity_spawner_ref == null:
        return
    for candidate in _get_valid_enemies(_entity_spawner_ref.get_all_enemies(false)):
        if charge.hit_enemies.has(candidate):
            continue
        if global_position.distance_to(candidate.global_position) > CHARGE_HIT_RADIUS:
            continue
        candidate.take_damage(charge.damage + _get_suture_bonus(), TakeDamageArgs.new(player_index))
        charge.hit_enemies.append(candidate)

func respawn() -> void:
    .respawn()
    _end_of_wave = false
    _abilities.clear()
    _active_charge.clear()
    _active_leap.clear()

