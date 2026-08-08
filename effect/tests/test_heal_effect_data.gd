extends GutTest


func _load_data() -> Resource:
	return HealEffectData.new()


func test_heal_effect_data_inherits_from_effect_data() -> void:
	var data: Resource = _load_data()
	assert_true(data.get_script().get_base_script() != null, "has a base script")
	var base_path: String = data.get_script().get_base_script().resource_path
	assert_eq(base_path, "res://effect/effect_data.gd", "inherits EffectData")


func test_default_description_is_empty() -> void:
	var data: Resource = _load_data()
	assert_eq(data.description, "", "default description is empty string")


func test_default_tags_is_empty() -> void:
	var data: Resource = _load_data()
	assert_eq(data.tags.size(), 0, "default tags is empty array")


func test_type_id_is_heal() -> void:
	var data: Resource = _load_data()
	assert_eq(data.type_id, &"heal", "type_id is &\"heal\"")


func test_dice_defaults_to_null() -> void:
	var data: Resource = _load_data()
	assert_null(data.dice, "default dice is null")


func test_dice_is_assignable() -> void:
	var data: Resource = _load_data()
	var dice: DiceFormula = DiceFormula.new()
	dice.count = 2
	dice.die = 4
	dice.bonus = 2
	data.dice = dice
	assert_eq(data.dice, dice, "dice round-trips")
	assert_eq(data.dice.count, 2, "dice.count round-trips")
	assert_eq(data.dice.die, 4, "dice.die round-trips")
	assert_eq(data.dice.bonus, 2, "dice.bonus round-trips")
