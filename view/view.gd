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
	if _model != null:
		for conn in _connections:
			var signal_name: StringName = conn["signal"]
			var callable: Callable = conn["callable"]
			if _model.has_signal(signal_name) and _model.is_connected(signal_name, callable):
				_model.disconnect(signal_name, callable)
	_connections.clear()
	_disposed = true


func _subscribe() -> void:
	pass


func _replay_state_from(_model: Node) -> void:
	pass


func _connect(signal_name: StringName, callable: Callable) -> void:
	assert(_model != null, "View._connect: not initialized")
	_model.connect(signal_name, callable)
	_connections.append({"signal": signal_name, "callable": callable})
