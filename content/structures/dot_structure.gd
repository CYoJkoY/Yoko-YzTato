extends Structure

export(float) var time = 5.0

onready var duration_timer: Timer = $DurationTimer
onready var attack_timer: Timer = $AttackTimer

var enemies_in_range: Array = []
var weapon_pos: int = -1

# =========================== Extension =========================== #
func _ready():
    duration_timer.wait_time = time
    attack_timer.wait_time = stats.cooldown * 0.05

    duration_timer.start()
    attack_timer.start()

func set_data(data: Resource) -> void:
    .set_data(data)
    weapon_pos = data.weapon_pos

# =========================== Custom =========================== #
func _on_Area2D_body_entered(body: Node):
    if body is Enemy and not body.dead:
        if !enemies_in_range.has(body):
            enemies_in_range.append(body)

func _on_Area2D_body_exited(body: Node):
    if enemies_in_range.has(body):
        enemies_in_range.erase(body)

func _on_DurationTimer_timeout():
    if !dead: die()

func _on_AttackTimer_timeout(_delta: float):
    if enemies_in_range.empty(): return

    for enemy in enemies_in_range:
        if enemy and not enemy.dead:
            enemy.add_decaying_speed(enemy.current_stats.speed * stats.speed_percent_modifier / 100)
            var args = TakeDamageArgs.new(player_index)
            var damage_taken: Array = enemy.take_damage(stats.damage, args)
            RunData.add_weapon_dmg_dealt(weapon_pos, damage_taken[1], player_index)
