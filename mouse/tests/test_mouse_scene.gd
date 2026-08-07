extends GutTest


const MouseScene := preload("res://mouse/mouse.tscn")
const AttributeSetScript := preload("res://attribute/attribute_set.gd")
const MouseClassDataScript := preload("res://mouse/mouse_class_data.gd")


func _instantiate(class_data: Resource = null) -> Node:
	var mouse: Node = MouseScene.instantiate()
	if class_data != null:
		mouse.set("class_data", class_data)
	add_child_autofree(mouse)
	return mouse


func test_mouse_inherits_all_components() -> void:
	var mouse: Node = _instantiate()
	assert_not_null(mouse.get_node_or_null("AttributeComponent"), "AttributeComponent inherited")
	assert_not_null(mouse.get_node_or_null("StatsComponent"), "StatsComponent inherited")
	assert_not_null(mouse.get_node_or_null("HealthComponent"), "HealthComponent inherited")
	assert_not_null(mouse.get_node_or_null("FactionComponent"), "FactionComponent inherited")
	assert_not_null(mouse.get_node_or_null("GridPositionComponent"), "GridPositionComponent inherited")
	assert_not_null(mouse.get_node_or_null("ActionBudgetComponent"), "ActionBudgetComponent inherited")
	assert_not_null(mouse.get_node_or_null("TargetingComponent"), "TargetingComponent inherited")
	assert_not_null(mouse.get_node_or_null("BrainSlot"), "BrainSlot inherited")


func test_mouse_faction_is_mouse() -> void:
	var mouse: Node = _instantiate()
	var faction_comp: FactionComponent = mouse.get_node("FactionComponent")
	assert_eq(faction_comp.faction, FactionIds.FACTION_MOUSE, "faction is mouse")


func test_player_input_brain_is_in_brain_slot() -> void:
	var mouse: Node = _instantiate()
	var brain_slot: Node = mouse.get_node("BrainSlot")
	assert_eq(brain_slot.get_child_count(), 1, "BrainSlot has 1 child (the brain)")
	var brain: Node = brain_slot.get_child(0)
	assert_true(brain.get_script() != null, "brain has a script attached")


func test_brain_is_bound_to_mouse() -> void:
	var mouse: Node = _instantiate()
	var brain: PlayerInputBrain = mouse.get_node("BrainSlot/PlayerInputBrain")
	assert_eq(brain._actor, mouse, "brain._actor is the Mouse")


func test_class_data_attributes_are_applied() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.set_score(AttributeIds.ATTR_STR, 14)
	attribute_set.set_score(AttributeIds.ATTR_CON, 12)
	var class_data: MouseClassData = MouseClassDataScript.new()
	class_data.attributes = attribute_set
	class_data.max_hp_base = 15
	var mouse: Node = _instantiate(class_data)
	var attr_comp: AttributeComponent = mouse.get_node("AttributeComponent")
	var health_comp: HealthComponent = mouse.get_node("HealthComponent")
	assert_eq(attr_comp.get_score(AttributeIds.ATTR_STR), 14, "STR from class_data")
	assert_eq(health_comp.max_hp, 17, "max_hp = 15 base + 2 CON mod")


func test_class_data_max_hp_initializes_health_to_max() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.set_score(AttributeIds.ATTR_CON, 10)
	var class_data: MouseClassData = MouseClassDataScript.new()
	class_data.attributes = attribute_set
	class_data.max_hp_base = 20
	var mouse: Node = _instantiate(class_data)
	var health_comp: HealthComponent = mouse.get_node("HealthComponent")
	assert_eq(health_comp.current_hp, 20, "current_hp equals max_hp after init")
	assert_eq(health_comp.max_hp, 20, "max_hp from class_data")
