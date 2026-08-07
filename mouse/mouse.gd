class_name Mouse
extends Character

@export var class_data: MouseClassData = null

@onready var brain: PlayerInputBrain = %PlayerInputBrain
@onready var deck: DeckComponent = $DeckComponent
@onready var memorization: MemorizationComponent = $MemorizationComponent


func _ready() -> void:
	super._ready()
	if brain != null:
		brain.bind(self)
	if deck != null and memorization != null:
		deck.bind_memorization(memorization)
	if class_data == null:
		return
	if class_data.attributes != null:
		attribute_component.base = class_data.attributes
		if deck != null:
			deck.bind_attribute_score(class_data.attributes.get_score(AttributeIds.ATTR_INT))
	if class_data.max_hp_base > 0:
		health_component.init(class_data.max_hp_base, attribute_component)
		health_component.recompute_max_hp()
		health_component.current_hp = health_component.max_hp
	if class_data.max_energy_base > 0 and stats_component != null:
		stats_component.init(class_data.max_energy_base, attribute_component)
		stats_component.recompute_max_energy()
		stats_component.current_energy = stats_component.max_energy
	if class_data.initial_deck.size() > 0 and deck != null:
		deck.deck = class_data.initial_deck.duplicate()
		deck.shuffle_initial_deck()
		deck.draw(deck.max_hand_size)
