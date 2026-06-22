extends Structure

export(float) var time = 5.0

onready var duration_timer: Timer = $DurationTimer
onready var attack_timer: Timer = $AttackTimer

var args: TakeDamageArgs = null
var enemies_in_range: Array = []
var weapon_pos: int = -1

# =========================== Extension =========================== #
func set_data(data: Resource) -> void:
    .set_data(data)
    _fantasy_set_data(data)

# =========================== Custom =========================== #
func _fantasy_set_data(data: Resource) -> void:
    weapon_pos = data.weapon_pos
    args = TakeDamageArgs.new(player_index)

    duration_timer.wait_time = time
    attack_timer.wait_time = stats.cooldown / 60.0

    duration_timer.start()
    attack_timer.start()

# =========================== Method =========================== #
func _on_Area2D_body_entered(body: Enemy):
    if body.dead: return

    if !enemies_in_range.has(body): enemies_in_range.append(body)

func _on_Area2D_body_exited(body: Enemy):
    if enemies_in_range.has(body): enemies_in_range.erase(body)

func _on_DurationTimer_timeout():
    if !(_pending_die or dead): deferred_die()

func _on_AttackTimer_timeout():
    for enemy in enemies_in_range:
        if !is_instance_valid(enemy) or enemy.dead: continue

        enemy.add_decaying_speed(enemy.current_stats.speed * stats.speed_percent_modifier / 100)
        var damage: int = Utils.ncl_get_dmg_with_scaling_stats(base_stats.damage, base_stats.scaling_stats, player_index)
        var damage_taken: Array = enemy.take_damage(damage, args)
        RunData.add_weapon_dmg_dealt(weapon_pos, damage_taken[1], player_index)
