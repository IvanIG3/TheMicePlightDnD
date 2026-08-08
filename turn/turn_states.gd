class_name TurnStates
extends RefCounted

const PLAYER: StringName = &"player"
const ENEMY_PLANNING: StringName = &"enemy_planning"
const ENEMY_RESOLVING: StringName = &"enemy_resolving"
const POST_TURN: StringName = &"post_turn"
const END_TURN: StringName = &"end_turn"

const ALL: Array[StringName] = [
	PLAYER,
	ENEMY_PLANNING,
	ENEMY_RESOLVING,
	POST_TURN,
	END_TURN,
]
