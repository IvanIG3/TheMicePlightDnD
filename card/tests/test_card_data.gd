extends GutTest


const CardDataPath := "res://card/card_data.gd"
const EffectDataPath := "res://effect/effect_data.gd"


var _data_script: GDScript
var _data: Resource


func before_each() -> void:
	_data_script = load(CardDataPath)
	assert_not_null(_data_script, "CardData script must exist at " + CardDataPath)
	_data = _data_script.new()


func test_card_data_extends_resource() -> void:
	assert_true(_data is Resource, "CardData is a Resource")


func test_default_id_is_empty_stringname() -> void:
	assert_eq(_data.id, &"", "default id is empty StringName")


func test_default_name_is_empty_string() -> void:
	assert_eq(_data.name, "", "default name is empty string")


func test_default_description_is_empty_string() -> void:
	assert_eq(_data.description, "", "default description is empty string")


func test_default_energy_cost_is_zero() -> void:
	assert_eq(_data.energy_cost, 0, "default energy_cost is 0")


func test_default_family_is_none() -> void:
	assert_eq(_data.family, CardFamilies.NONE, "default family is CardFamilies.NONE")


func test_default_type_is_attack() -> void:
	assert_eq(_data.type, CardTypes.ATTACK, "default type is CardTypes.ATTACK")


func test_default_range_is_one() -> void:
	assert_eq(_data.range, 1, "default range is 1")


func test_default_range_shape_is_line() -> void:
	assert_eq(_data.range_shape, RangeShapes.LINE, "default range_shape is RangeShapes.LINE")


func test_default_area_shape_is_single() -> void:
	assert_eq(_data.area_shape, AreaShapes.SINGLE, "default area_shape is AreaShapes.SINGLE")


func test_default_area_size_is_one() -> void:
	assert_eq(_data.area_size, 1, "default area_size is 1")


func test_default_effects_is_empty_array() -> void:
	assert_eq(_data.effects.size(), 0, "default effects is empty Array")
	assert_true(_data.effects is Array, "effects is an Array")


func test_default_scaling_attributes_is_empty_array() -> void:
	assert_eq(_data.scaling_attributes.size(), 0, "default scaling_attributes is empty Array")


func test_default_exhaust_is_false() -> void:
	assert_false(_data.exhaust, "default exhaust is false")


func test_default_tags_is_empty_array() -> void:
	assert_eq(_data.tags.size(), 0, "default tags is empty Array")


func test_id_is_assignable() -> void:
	_data.id = &"my_card"
	assert_eq(_data.id, &"my_card", "id is settable")


func test_energy_cost_is_assignable() -> void:
	_data.energy_cost = 3
	assert_eq(_data.energy_cost, 3, "energy_cost is settable")


func test_range_is_assignable() -> void:
	_data.range = 5
	assert_eq(_data.range, 5, "range is settable")


func test_exhaust_is_assignable() -> void:
	_data.exhaust = true
	assert_true(_data.exhaust, "exhaust is settable")


func test_effects_array_accepts_effect_data() -> void:
	var effect_script: GDScript = load(EffectDataPath)
	assert_not_null(effect_script, "EffectData script must exist at " + EffectDataPath)
	var effect: Resource = effect_script.new()
	var arr: Array[EffectData] = [effect]
	_data.effects = arr
	assert_eq(_data.effects.size(), 1, "effects array holds EffectData entries")
