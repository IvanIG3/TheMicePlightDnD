class_name AttributeSet
extends Resource

@export var strength: int = 10
@export var dexterity: int = 10
@export var constitution: int = 10
@export var intelligence: int = 10
@export var wisdom: int = 10
@export var charisma: int = 10

const _FIELD_BY_ATTR := {
	AttributeIds.ATTR_STR: "strength",
	AttributeIds.ATTR_DEX: "dexterity",
	AttributeIds.ATTR_CON: "constitution",
	AttributeIds.ATTR_INT: "intelligence",
	AttributeIds.ATTR_WIS: "wisdom",
	AttributeIds.ATTR_CHA: "charisma",
}

func get_value(attr: StringName) -> int:
	var field_name: String = _FIELD_BY_ATTR.get(attr, "")
	if field_name == "":
		return 0
	return get(field_name)

func modifier(attr: StringName) -> int:
	return get_value(attr) - AttributeModifier.MODIFIER_BASE
