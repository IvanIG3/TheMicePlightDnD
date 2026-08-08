extends GutTest


const PredatorScene := preload("res://predator/predator.tscn")


func _instantiate() -> Node:
	var predator: Node = PredatorScene.instantiate()
	add_child_autofree(predator)
	return predator


func test_predator_inherits_all_components() -> void:
	var predator: Node = _instantiate()
	assert_not_null(predator.get_node_or_null("AttributeComponent"), "AttributeComponent inherited")
	assert_not_null(predator.get_node_or_null("StatsComponent"), "StatsComponent inherited")
	assert_not_null(predator.get_node_or_null("HealthComponent"), "HealthComponent inherited")
	assert_not_null(predator.get_node_or_null("FactionComponent"), "FactionComponent inherited")
	assert_not_null(predator.get_node_or_null("GridPositionComponent"), "GridPositionComponent inherited")
	assert_not_null(predator.get_node_or_null("ActionBudgetComponent"), "ActionComponent inherited")
	assert_not_null(predator.get_node_or_null("TargetingComponent"), "TargetingComponent inherited")
	assert_not_null(predator.get_node_or_null("BrainSlot"), "BrainSlot inherited")


func test_predator_has_intent_component() -> void:
	var predator: Node = _instantiate()
	var intent: IntentComponent = predator.get_node("IntentComponent")
	assert_not_null(intent, "IntentComponent child present")


func test_predator_faction_is_predator() -> void:
	var predator: Node = _instantiate()
	var faction_comp: FactionComponent = predator.get_node("FactionComponent")
	assert_eq(faction_comp.faction, FactionIds.FACTION_PREDATOR, "faction is predator")


func test_predator_has_ai_brain_in_brain_slot() -> void:
	var predator: Node = _instantiate()
	var brain_slot: Node = predator.get_node("BrainSlot")
	assert_eq(brain_slot.get_child_count(), 1, "BrainSlot has 1 child (the brain)")
	var brain: Node = brain_slot.get_child(0)
	assert_true(brain is PredatorAIBrain, "brain is PredatorAIBrain")


func test_ai_brain_is_bound_to_predator() -> void:
	var predator: Node = _instantiate()
	var brain: PredatorAIBrain = predator.get_node("BrainSlot/PredatorAIBrain")
	assert_not_null(brain._intent, "brain._intent is set after _ready()")
	assert_eq(brain._intent, predator.get_node("IntentComponent"), "brain._intent is the predator's IntentComponent")
