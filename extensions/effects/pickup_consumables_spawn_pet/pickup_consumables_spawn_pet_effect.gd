extends Effect

export(String) var stat_to_consume: String = ""
export(int) var consume_amount: int = 1
export(PackedScene) var pet_scene
export(bool) var build_from_enemies: bool = false
export(String) var trigger_consumable_id: String = ""

var _stat_hash: int = Keys.empty_hash

func _init() -> void:
    _stat_hash = Keys.generate_hash(stat_to_consume)

static func get_id() -> String:
    return "yztato_pickup_consumables_spawn_pet"

func _generate_hashes() -> void:
    ._generate_hashes()
    _stat_hash = Keys.generate_hash(stat_to_consume)

func apply(player_index: int) -> void:
    if custom_key_hash != Keys.empty_hash:
        RunData.get_player_effect(custom_key_hash, player_index).append(self)

func unapply(player_index: int) -> void:
    if custom_key_hash != Keys.empty_hash:
        RunData.get_player_effect(custom_key_hash, player_index).erase(self)
    return

func on_consumable_picked_up(_consumable: Node, player_index: int) -> void:
    if _consumable == null or _consumable.consumable_data == null:
        return
    if not _matches_trigger(_consumable):
        return
    if consume_amount <= 0 or _stat_hash == Keys.empty_hash:
        return
    if Utils.get_stat(_stat_hash, player_index) < consume_amount:
        return
    var enemies: Array = _get_alive_enemies() if build_from_enemies else []
    if build_from_enemies and enemies.size() < 3:
        return
    var pet = spawn_pet(player_index)
    if pet == null:
        return
    if build_from_enemies and pet.has_method("build_from_enemies"):
        if not pet.build_from_enemies(enemies):
            pet.queue_free()
            return
    RunData.add_stat(_stat_hash, -consume_amount, player_index)

func _matches_trigger(consumable: Node) -> bool:
    if trigger_consumable_id.empty():
        return true
    return consumable.consumable_data.my_id_hash == Keys.generate_hash(trigger_consumable_id)

func spawn_pet(player_index: int):
    var main = Engine.get_main_loop().current_scene
    if not is_instance_valid(main):
        return null
    var spawner = main._entity_spawner
    if not is_instance_valid(spawner) or pet_scene == null:
        return null
    if player_index < 0 or player_index >= main._players.size():
        return null
    var spawn_args: EntitySpawner.SpawnEntityArgs = EntitySpawner.SpawnEntityArgs.new(
        spawner.get_spawn_pos_in_area(main._players[player_index].global_position, 100),
        EntityType.PET
    )
    spawn_args.player_index = player_index
    var pet = spawner.spawn_entity(pet_scene, spawn_args, null)
    if pet != null:
        pet.player_index = player_index
    return pet

func _get_alive_enemies() -> Array:
    var enemies: Array = []
    var main = Engine.get_main_loop().current_scene
    if not is_instance_valid(main):
        return enemies
    var spawner = main._entity_spawner
    if not is_instance_valid(spawner):
        return enemies
    for enemy in spawner.get_all_enemies(false):
        if is_instance_valid(enemy) and not enemy.dead and enemy.sprite != null and enemy.sprite.texture != null:
            enemies.append(enemy)
    return enemies

func serialize() -> Dictionary:
    var data = .serialize()
    data.stat_to_consume = stat_to_consume
    data.consume_amount = consume_amount
    data.pet_scene = pet_scene.resource_path if pet_scene != null else ""
    data.build_from_enemies = build_from_enemies
    data.trigger_consumable_id = trigger_consumable_id
    return data

func deserialize_and_merge(data: Dictionary) -> void:
    .deserialize_and_merge(data)
    stat_to_consume = data.get("stat_to_consume", "")
    consume_amount = data.get("consume_amount", 1)
    var scene_path: String = data.get("pet_scene", "")
    pet_scene = load(scene_path) if not scene_path.empty() else null
    build_from_enemies = data.get("build_from_enemies", false)
    trigger_consumable_id = data.get("trigger_consumable_id", "")
    _stat_hash = Keys.generate_hash(stat_to_consume)

