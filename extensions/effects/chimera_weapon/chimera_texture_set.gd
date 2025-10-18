extends Resource

export(Resource) var texture
export(int) var damage := 1
export(int, -10000, 10000) var knockback := 0
export(float, 0.0, 1.0, 0.05) var knockback_piercing := 0.0
export(int) var piercing := 0
export(float, 0, 1, 0.05) var piercing_dmg_reduction := 0.5
export(int) var bounce := 0
export(float, 0, 1, 0.05) var bounce_dmg_reduction := 0.5
export(bool) var can_bounce = true
export(Array, Resource) var effects

export(Dictionary) var enable_flags = {
	"modify_damage": false,
	"modify_knockback": false,
	"modify_knockback_piercing": false,
	"modify_projectile_speed": false,
	"modify_piercing": true,
	"modify_piercing_dmg_reduction": true,
	"modify_bounce": true,
	"modify_bounce_dmg_reduction": true,
	"modify_effects": false,
}
