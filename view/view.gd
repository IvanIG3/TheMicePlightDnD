class_name View
extends Node

var _model: Node = null
var _disposed: bool = false
var _connections: Array[Dictionary] = []


func initialize(model: Node) -> void:
	assert(_model == null, "View.initialize: already initialized")
	assert(not _disposed, "View.initialize: already disposed")
	_model = model
	_subscribe()
	_replay_state_from(_model)


func dispose() -> void:
	if _disposed:
		return
	for conn in _connections:
		var target: Object = conn["target"]
		var signal_name: StringName = conn["signal"]
		var callable: Callable = conn["callable"]
		if is_instance_valid(target) and target.has_signal(signal_name) and target.is_connected(signal_name, callable):
			target.disconnect(signal_name, callable)
	_connections.clear()
	_disposed = true


func _subscribe() -> void:
	pass


func _replay_state_from(_target_model: Node) -> void:
	pass


func _connect(signal_name: StringName, callable: Callable) -> void:
	_connect_to(_model, signal_name, callable)


func _connect_to(target: Object, signal_name: StringName, callable: Callable) -> void:
	assert(target != null, "View._connect_to: target is null")
	target.connect(signal_name, callable)
	_connections.append({"target": target, "signal": signal_name, "callable": callable})
