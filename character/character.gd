class_name Character
extends Node


@export var display_name: String = ""


@export var faction: StringName = FactionIds.FACTION_NEUTRAL


@export var attribute_set: AttributeSet = null


@export var max_hp_base: int = 10


@export var brain_scene: PackedScene = null


@onready var attribute_component: AttributeComponent = $AttributeComponent


@onready var stats_component: StatsComponent = $StatsComponent


@onready var health_component: HealthComponent = $HealthComponent


@onready var faction_component: FactionComponent = $FactionComponent


@onready var grid_position_component: GridPositionComponent = $GridPositionComponent


@onready var action_budget_component: ActionBudgetComponent = $ActionBudgetComponent


@onready var targeting_component: TargetingComponent = $TargetingComponent


@onready var brain_slot: Node = $BrainSlot


func _ready() -> void:
	if faction_component != null:
		faction_component.faction = faction
	if attribute_component != null and attribute_set != null:
		attribute_component.base = attribute_set
	if brain_scene != null and brain_slot != null:
		var brain: Node = brain_scene.instantiate()
		brain_slot.add_child(brain)
