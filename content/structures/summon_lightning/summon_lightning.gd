extends Structure

export(String, FILE, "*.tscn") var lightning_path = "res://mods-unpacked/Yoko-YzTato/content/structures/summon_lightning/lightning.tscn"
export(float) var exist_duration = 3.0
export(float) var charge_duration = 1.0

onready var cloud: Sprite = $"%Cloud"
onready var cloud_position: Position2D = $"%CloudPosition"
onready var hit_area: Area2D = $"HitArea"
onready var tween: Tween = $"Tween"
onready var duration_timer: Timer = $"DurationTimer"
onready var charge_timer: Timer = $"ChargeTimer"
onready var attack_timer: Timer = $"AttackTimer"

var args: TakeDamageArgs = null
var enemies_in_area: Array = []
var weapon_pos: int = -1

# =========================== Extension =========================== #
func set_data(data: Resource) -> void:
    .set_data(data)
    _fantasy_set_data(data)

# =========================== Custom =========================== #
func _fantasy_set_data(data: Resource) -> void:
    cloud.material.set_shader_param("lightning_power", 0.0)

    weapon_pos = data.weapon_pos
    args = TakeDamageArgs.new(player_index)
    args.set_meta("custom_color", Color("#0099ff"))

    duration_timer.wait_time = exist_duration
    charge_timer.wait_time = charge_duration
    attack_timer.wait_time = stats.cooldown / 60.0

    duration_timer.start()
    charge_timer.start()

# =========================== Method =========================== #
func _on_HitArea_body_entered(body: Enemy) -> void:
    if body.dead: return

    if !enemies_in_area.has(body): enemies_in_area.append(body)

func _on_HitArea_body_exited(body: Enemy) -> void:
    if enemies_in_area.has(body): enemies_in_area.erase(body)

func _on_DurationTimer_timeout():
    if !(_pending_die or dead): deferred_die()

func _on_ChargeTimer_timeout():
    attack_timer.start()

func _on_AttackTimer_timeout():
    for enemy in enemies_in_area:
        if !is_instance_valid(enemy) or enemy.dead: continue

        var lightning_instance: Node2D = load(lightning_path).instance()
        cloud_position.add_child(lightning_instance)
        lightning_instance.setup(cloud_position.global_position, enemy.global_position)

        enemy.add_decaying_speed(enemy.current_stats.speed * stats.speed_percent_modifier / 100)
        var damage: int = Utils.ncl_get_dmg_with_scaling_stats(base_stats.damage, base_stats.scaling_stats, player_index)
        var damage_taken: Array = enemy.take_damage(damage, args)
        RunData.add_weapon_dmg_dealt(weapon_pos, damage_taken[1], player_index)
