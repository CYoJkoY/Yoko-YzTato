extends Structure

export (float) var time = 5.0

onready var _timer: Timer = $Timer

var enemies_in_range: Array = []
var frame_count: int = 0
var weapon_pos: int = -1

# =========================== Extension =========================== #
func _ready():
    _timer.wait_time = time
    _timer.start()

func _physics_process(_delta: float):
    frame_count += 1
    if frame_count >= stats.cooldown \
    and !enemies_in_range.empty():
        frame_count = 0
        for enemy in enemies_in_range:
            if enemy and not enemy.dead:
                enemy.add_decaying_speed(enemy.current_stats.speed * stats.speed_percent_modifier / 100)
                var args = TakeDamageArgs.new(player_index)
                var damage_taken: Array = enemy.take_damage(stats.damage, args)
                RunData.add_weapon_dmg_dealt(weapon_pos, damage_taken[1], player_index)

func set_data(data: Resource)->void :
    .set_data(data)
    weapon_pos = data.weapon_pos

# =========================== Custom =========================== #
func yztato_on_trap_area_entered(body: Node):
    if body is Enemy and not body.dead:
        if not enemies_in_range.has(body):
            enemies_in_range.append(body)

func yztato_on_trap_area_exited(body: Node):
    if enemies_in_range.has(body):
        enemies_in_range.erase(body)

func yztato_on_trap_duration_finished():
    if not dead: die()
