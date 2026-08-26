extends "res://projectiles/player_projectile.gd"

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func bounce(thing_hit: Node) -> void :
    .bounce(thing_hit)
    _hitbox.damage *= 1 + (RunData.get_player_effect(Utils.yztato_bounce_dmg_multiplier_hash, _get_player_index()) / 100.0)
