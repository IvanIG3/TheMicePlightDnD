extends GutTest


const CharacterScene := preload("res://character/character.tscn")


func _instantiate(extras: Dictionary = {}) -> Node:
	var character: Node = CharacterScene.instantiate()
	for key in extras:
		character.set(key, extras[key])
	add_child_autofree(character)
	return character


func test_character_has_all_eight_components() -> void:
	var character: Node = _instantiate()
	assert_not_null(character.get_node_or_null("AttributeComponent"), "AttributeComponent present")
	assert_not_null(character.get_node_or_null("StatsComponent"), "StatsComponent present")
	assert_not_null(character.get_node_or_null("HealthComponent"), "HealthComponent present")
	assert_not_null(character.get_node_or_null("FactionComponent"), "FactionComponent present")
	assert_not_null(character.get_node_or_null("GridPositionComponent"), "GridPositionComponent present")
	assert_not_null(character.get_node_or_null("ActionBudgetComponent"), "ActionBudgetComponent present")
	assert_not_null(character.get_node_or_null("TargetingComponent"), "TargetingComponent present")
	assert_not_null(character.get_node_or_null("BrainSlot"), "BrainSlot present")


func test_default_faction_is_neutral() -> void:
	var character: Node = _instantiate()
	var faction_comp: FactionComponent = character.get_node("FactionComponent")
	assert_eq(faction_comp.faction, FactionIds.FACTION_NEUTRAL, "default faction is neutral")


func test_faction_export_is_copied_to_component() -> void:
	var character: Node = _instantiate({"faction": FactionIds.FACTION_MOUSE})
	var faction_comp: FactionComponent = character.get_node("FactionComponent")
	assert_eq(faction_comp.faction, FactionIds.FACTION_MOUSE, "faction is mouse")


func test_attribute_set_export_is_copied_to_attribute_component() -> void:
	var attribute_set: AttributeSet = AttributeSet.new()
	attribute_set.set_score(AttributeIds.ATTR_STR, 16)
	var character: Node = _instantiate({"attribute_set": attribute_set})
	var attr_comp: AttributeComponent = character.get_node("AttributeComponent")
	assert_eq(attr_comp.get_score(AttributeIds.ATTR_STR), 16, "STR is 16 from attribute_set")


func test_brain_slot_is_empty_by_default() -> void:
	var character: Node = _instantiate()
	var brain_slot: Node = character.get_node("BrainSlot")
	assert_eq(brain_slot.get_child_count(), 0, "BrainSlot has no children by default")


func test_brain_scene_is_instantiated_into_brain_slot() -> void:
	var brain_scene: PackedScene = PackedScene.new()
	var brain_root: Node = Node.new()
	brain_scene.pack(brain_root)
	brain_root.free()
	var character: Node = _instantiate({"brain_scene": brain_scene})
	var brain_slot: Node = character.get_node("BrainSlot")
	assert_eq(brain_slot.get_child_count(), 1, "BrainSlot has 1 child from brain_scene")
