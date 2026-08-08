extends GutTest


func _load_data() -> Resource:
	return DamageEffectData.new()


func test_damage_effect_data_inherits_from_effect_data() -> void:
	var data: Resource = _load_data()
	assert_true(data.get_script().get_base_script() != null, "has a base script")
	var base_path: String = data.get_script().get_base_script().resource_path
	assert_eq(base_path, "res://effect/effect_data.gd", "inherits EffectData")


func test_default_damage_type_is_physical() -> void:
	var data: Resource = _load_data()
	assert_eq(data.damage_type, &"physical", "default damage_type is &\"physical\"")


func test_default_scaling_attribute_is_empty() -> void:
	var data: Resource = _load_data()
	assert_eq(data.scaling_attribute, &"", "default scaling_attribute is empty StringName")


func test_default_resistance_attribute_is_empty() -> void:
	var data: Resource = _load_data()
	assert_eq(data.resistance_attribute, &"", "default resistance_attribute is empty StringName")


func test_default_resistance_value_is_zero() -> void:
	var data: Resource = _load_data()
	assert_eq(data.resistance_value, 0, "default resistance_value is 0")


func test_type_id_is_damage() -> void:
	var data: Resource = _load_data()
	assert_eq(data.type_id, &"damage", "type_id is &\"damage\"")


func test_dice_defaults_to_null() -> void:
	var data: Resource = _load_data()
	assert_null(data.dice, "default dice is null")


func test_fields_are_assignable() -> void:
	var data: Resource = _load_data()
	var dice: DiceFormula = DiceFormula.new()
	dice.count = 2
	dice.die = 6
	dice.bonus = 3
	data.dice = dice
	data.scaling_attribute = &"strength"
	data.damage_type = &"special"
	data.resistance_attribute = &"dexterity"
	data.resistance_value = 12
	assert_eq(data.dice, dice, "dice round-trips")
	assert_eq(data.scaling_attribute, &"strength", "scaling_attribute round-trips")
	assert_eq(data.damage_type, &"special", "damage_type round-trips")
	assert_eq(data.resistance_attribute, &"dexterity", "resistance_attribute round-trips")
	assert_eq(data.resistance_value, 12, "resistance_value round-trips")
