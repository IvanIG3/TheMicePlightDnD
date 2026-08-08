extends PredatorAIBrain


## Test fixture: counts how often plan_turn is called per state.
## Verifies the brain is only called during ENEMY_PLANNING, never during
## ENEMY_RESOLVING (the locked design).


var call_count: Dictionary = {
	TurnStates.ENEMY_PLANNING: 0,
	TurnStates.ENEMY_RESOLVING: 0,
}


func plan_turn(state: StringName) -> void:
	if call_count.has(state):
		call_count[state] += 1
	super.plan_turn(state)
