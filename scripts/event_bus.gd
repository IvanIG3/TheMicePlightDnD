extends Node

# EventBus — the project's global signal hub. A pure pass-through: no state,
# no logic, no methods beyond the signal emissions. Cross-cutting events
# listed in docs/architecture/systems.md are declared here so the surface is
# stable from Phase 1 forward. Phase 1 components do NOT connect to EventBus
# (per locked decision); the bus exists for Phase 2+ consumers.

# Note on typing: payloads use the most specific type known at Phase 1.
# Concrete subclasses (CardData, BiomeData, ...) land in later phases; signals
# accept the base type (Resource, Node) so they remain usable now.

signal card_played(card: Resource, player: Node)
signal damage_applied(amount: int, source: Node, target: Node, is_crit: bool)
signal heal_applied(amount: int, target: Node)
signal entity_died(entity: Node)
signal status_applied(data: Resource, target: Node)
signal status_removed(data: Resource, target: Node)
signal trophy_imbued(trophy: Resource, mouse: Node)
signal turn_started(actor: Node)
signal turn_ended(actor: Node)
signal biome_entered(biome_data: Resource, seed: int)
signal biome_exited(biome_data: Resource)
signal predator_intent_published(predator: Node, plan: Resource)
signal rest_action_taken(action: StringName)
signal run_started(class_data: Resource, seed: int)
signal run_ended(success: bool)
