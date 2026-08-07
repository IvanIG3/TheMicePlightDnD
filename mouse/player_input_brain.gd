class_name PlayerInputBrain
extends Node

const InputServiceAutoload: StringName = &"InputService"
const MoveExecutorScript := preload("res://executor/move_executor.gd")
const MoveDataScript := preload("res://executor/move_data.gd")
const ActionContextScript := preload("res://executor/action_context.gd")
const ActionPlanScript := preload("res://executor/action_plan.gd")

var pending_plan: ActionPlan = null
var _actor: Node = null


func bind(actor: Node) -> void:
	_actor = actor
	var input: Node = _get_input_service()
	if input != null and not input.move_intent.is_connected(_on_move_intent):
		input.move_intent.connect(_on_move_intent)


func _on_move_intent(direction: Vector2i) -> void:
	if _actor == null:
		return
	var executor: MoveExecutor = MoveExecutorScript.new()
	executor.data = _make_move_data(direction)
	var ctx: ActionContext = _make_ctx()
	pending_plan = _build_plan(direction, executor.get_affected_tiles(ctx))
	if executor.validate(ctx):
		if executor.execute(ctx):
			_spend_action_budget()


func submit_player_action(_plan: ActionPlan) -> void:
	pass


func _make_move_data(direction: Vector2i) -> MoveData:
	var move_data: MoveData = MoveDataScript.new()
	move_data.direction = direction
	return move_data


func _make_ctx() -> ActionContext:
	var ctx: ActionContext = ActionContextScript.new()
	ctx.actor = _actor
	var pos: GridPositionComponent = _get_position()
	if pos != null:
		ctx.grid = pos.grid
	return ctx


func _build_plan(direction: Vector2i, affected_tiles: Array[Vector2i]) -> ActionPlan:
	var plan: ActionPlan = ActionPlanScript.new()
	plan.action = &"move"
	var pos: GridPositionComponent = _get_position()
	if pos != null:
		plan.target = pos.cell + direction
	plan.predicted_affected_tiles = affected_tiles
	return plan


func _get_position() -> GridPositionComponent:
	if _actor == null:
		return null
	for child in _actor.get_children():
		if child is GridPositionComponent:
			return child
	return null


func _spend_action_budget() -> void:
	if _actor == null:
		return
	for child in _actor.get_children():
		if child is ActionBudgetComponent:
			child.spend(&"move")
			return


func _get_input_service() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("/root/InputService")
