extends "res://singletons/player_run_data.gd"

static func init_stats(all_null_values: bool = false) -> Dictionary:

	if (not Utils == null) :
		var vanilla_stats = .init_stats(all_null_values)

		var new_stats: = {
			"trees": 0,                                                     # Debug : Only For Assert
			
		}

		new_stats.merge(vanilla_stats)

		return new_stats;
	else:
		return {}

static func init_effects() -> Dictionary:

	if (not Utils == null) :
		var vanilla_effects = .init_effects()

		var new_effects: = {
			"yztato_gain_items_end_of_wave": [],                            # effect : 获得value数量的对应物品
			"yztato_destory_weapons": [],                                   # effect : 每局结束时, 摧毁所有物品, 并给与value数量的对应物品
			"yztato_set_stat": [],                                          # effect : 每局结束时, 将对应属性的值设置为value值
			"yztato_adjust_wave_timer": [],                                 # key : "sum" -> 每波时间 + 对应value数值 | "mul" -> 每波时间 * 对应value数值 | "rep" -> 每波时间变成对应value数值 | "mul_plus" -> 每波时间增减对应 value%
			"yztato_adjust_wave_max_enemies": [],                           # key : "sum" | "mul" | "rep" | "mul_plus" 同上
			"yztato_multi_crit": 0,                                         # value : 不为0时生效, 当暴击率 > 1时, 若暴击, 则消耗1暴击率, 暴击伤害循环乘以暴击倍率
			"yztato_useful_crit": [],                                       # key : "better" -> value不为0时生效，暴击率 > 1时，若暴击则消耗1暴击率, 暴击伤害循环乘暴击时的暴击率 | "val" -> 暴击率 > 1时，暴击伤害为 (原暴击伤害 * value %)
			"yztato_life_steal": [],                                        # key : "better" -> 吸血量为 吸血率(小数格式) 和 1 之间的最大值 | "val" -> 吸血量为 (武器伤害 * value %) 和 1 之间的最大值
			"yztato_melee_erase_bullets": 0,                                # value -> 不为0时，近战武器可清除敌人子弹
			"yztato_flying_sword": [],                                      # key : "attack" -> 御剑模式 | "attack_limit" -> 设定御剑条件, 当武器伤害大于 value才会触发御剑模式 | "sword_array" -> 剑阵模式 | "sword_array_limit" -> 设定使用条件, 当武器伤害大于 value 时才会进入剑阵模式
			"yztato_blade_storm": [],                                       # key : "OP" -> 可消除子弹 | "Normal" -> 不可消除子弹
			"yztato_leave_fire": [],                                        # duration -> 持续秒数 \\\ scale -> 火圈范围
			"yztato_chimera_weapon": [],                                    # value -> 仅为文本展示, "接下来依次发射value个投掷物" \\\ chimera_projectile_stats -> 接下来要发射的投掷物
			"yztato_explosion_erase_bullets": 0,                            # value -> 不为0时，爆炸可清除敌人子弹
			"yztato_upgrade_range_killed_enemies": 0,                       # value -> 达到value杀敌数时，武器升级
			"yztato_gain_stat_when_killed_single_scaling": [],              # key : "all" -> 作用于所有武器 \\\ value -> 初始需求杀敌数 \\\ stat -> 获得的属性 \\\ stat_nb -> 获得的属性数 \\\ scaling -> 用于增加需要杀敌数的属性 \\\ scaling_percent -> 衡量百分比
			"yztato_melee_bounce_bullets": 0,                               # value -> 以value%速度将敌人子弹反弹回去
			"yztato_special_picked_up_change_stat": [],                     # key -> 需要拾取的消耗品名 \\\ value -> 需要拾取的消耗品数 \\\ stat -> 增加的属性名 \\\ stat_nb -> 加的属性数 (负数代表减)
			"yztato_weapon_set_filter": [],                                 # effect : 商店里面只会出现set_id的set系列武器
			"yztato_extrusion_attack": [],                                  # effect : 怪物间会出现挤压伤害 
			"yztato_weapon_set_delete": [],                                 # effect : 商店里面不会出现set_id的set系列武器
			"yztato_boomerang_weapon": [],                                  # max_damage_mul -> 最近处伤害倍率 \\\ min_damage_mul -> 最远处伤害倍率 \\\ boomerang_wait -> 是否需等待回旋武器回来才冷却 \\\ lock_range -> 是否锁定范围(是否受范围属性影响) \\\ lock_speed -> 是否锁定回旋武器速度(是否受投射物速度属性影响) \\\ knockback_only_back -> 只在返回时造成击退
			"yztato_one_shot_loot": 0,                                      # effect : 不为0时，可秒杀战利品敌人
			"yztato_extra_upgrade": 0,                                      # effect : 选择升级属性时，有value%概率多选一次
			"yztato_blood_rage": [],                                        # effect : 每interval秒触发一次时间扭曲，使敌人减速enemy_slow_percent%，提升attack_speed_bonus%攻击速度、dodge_bonus%闪避率和hp_regen_bonus生命恢复，持续duration秒，击败敌人可重置冷却
			"yztato_stat_on_hit": [],                                       # effect : 每被击中一次，变化value的属性值
			"yztato_invincible_on_hit_duration": 0,                         # effect : 每被击中一次，无敌value秒
			"yztato_crit_damage": 0,                                        # effect : 增加value%的暴击伤害
			"yztato_force_curse_items": 0,                                  # effect : 强制所有物品添加诅咒效果
			"yztato_gain_random_primary_stat_when_killed": [],              # effect : 杀死num敌人后，随机主属性变化 value
			"yztato_random_primary_stat_on_hit": 0,                         # effect : 每被击中一次，随机主属性变化 value
			"yztato_damage_against_not_boss": 0,                            # effect : 对非boss敌人的伤害倍率
			"yztato_random_primary_stat_over_time": [],                     # effect : 每经过interval秒，随机主属性变化value
			"yztato_multi_hit": [],                                         # effect : 每次命中敌人将多造成value次伤害，数值为damage_percent%原伤害
			"yztato_combo_hit": [],                                         # effect : time_window秒内命中同一敌人，造成的伤害会增加value%
			"yztato_vine_trap": [],                                         # effect : 击中敌人有chance概率生成trap_count数量藤曼
			"yztato_stats_chance_on_level_up": [],                          # effect : 升级时，有value2%概率获得value点key属性
			"yztato_heal_on_damage_taken": [],                              # effect : 受伤时,有value%概率恢复受到的value2%的伤害
			"yztato_temp_stats_per_interval": [],                           # effect : 一波内，每interval秒，stat属性变化value，每波结束消失 \\\ reset_on_hit -> 变化的属性是否在受伤时归零
			"yztato_extra_enemies_next_waves": [],                          # effect : 未来waves个波次会出现value个extra_group_data怪物组
			"yztato_damage_scaling": [],                                    # effect : 每拥有a点属性A，则武器伤害会随b%属性B、c%属性C...影响
			"yztato_random_curse_on_reroll": [],                            # effect : 重新刷新商店时，随机value件物品和武器有value2%的几率被诅咒
			
		}

		new_effects.merge(vanilla_effects)

		return new_effects;
	else:
		return {}
