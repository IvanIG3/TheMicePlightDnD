class_name FactionComponent
extends Node

@export var faction: StringName = FactionIds.FACTION_NEUTRAL


func is_hostile_to(other: FactionComponent) -> bool:
	if faction == other.faction:
		return false
	if faction == FactionIds.FACTION_MOUSE and other.faction == FactionIds.FACTION_PREDATOR:
		return true
	if faction == FactionIds.FACTION_PREDATOR and other.faction == FactionIds.FACTION_MOUSE:
		return true
	return false
