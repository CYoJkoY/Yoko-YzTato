extends Node2D

export(String, FILE, "*.tscn") var lightning_path = "res://mods-unpacked/Yoko-YzTato/extensions/effects/summon_lightning/lightning.tscn"
var lightning_instance: Node2D = null
export(float) var charge_duration = 0.5
export(float) var strike_cooldown = 0.25

onready var cloud: Sprite = $"Cloud"
onready var hit_area: Area2D = $"HitArea"
onready var tween: Tween = $"Tween"

var enemies_in_area: Array = []
var is_casting: bool = false
var current_charge_time: float = 0.0
var player_index: int = -1

# =========================== Extension =========================== #
func _ready() -> void:
    cloud.material.set_shader_param("lightning_power", 0.0)

func _physics_process(_delta: float) -> void:
    if !is_casting or enemies_in_area.empty(): return

    current_charge_time += _delta

    if current_charge_time < charge_duration: return

    _strike_lightning()

func _strike_lightning() -> void:
    if enemies_in_area.empty(): return

    tween.interpolate_property(
        cloud.material,
        "shader_param/lightning_power",
        0.0, 1.5, 0.2,
        Tween.TRANS_SINE, Tween.EASE_OUT
    )

    tween.interpolate_property(
        cloud.material,
        "shader_param/lightning_power",
        1.5, 0.0, 0.2,
        Tween.TRANS_SINE, Tween.EASE_OUT
    )

    var target: Enemy = enemies_in_area[0]
    if lightning_instance == null: lightning_instance = load(lightning_path).instance()
    for _i in range(RunData.get_player_effect(Utils.yztato_summon_lightning_hash, player_index)):
        add_child(lightning_instance)
        lightning_instance.setup(cloud.global_position, target.global_position)
    
    yield (get_tree().create_timer(0.25), "timeout")
    lightning_instance.queue_free()
    lightning_instance = null

    is_casting = false
    current_charge_time = 0.0

    yield (get_tree().create_timer(strike_cooldown), "timeout")
    if enemies_in_area.empty(): return

    is_casting = true

# =========================== Method =========================== #
func _on_HitArea_body_entered(body: Unit) -> void:
    enemies_in_area.append(body)

func _on_HitArea_body_exited(body: Unit) -> void:
    enemies_in_area.erase(body)
