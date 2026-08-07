extends Node


const _THEME_DIRS: Array[String] = [
	"res://attribute/",
	"res://health/",
	"res://stats/",
	"res://dice/",
	"res://effect/",
	"res://card/",
]


const MoveExecutorScript := preload("res://executor/move_executor.gd")
const DamageExecutorScript := preload("res://effect/damage_executor.gd")
const HealExecutorScript := preload("res://effect/heal_executor.gd")
const CompositeExecutorScript := preload("res://effect/composite_executor.gd")


var effect_executors: Dictionary[StringName, Script] = {}
var action_executors: Dictionary[StringName, Script] = {}
var status_classes: Dictionary[StringName, Script] = {}
var data_index: Dictionary[StringName, Resource] = {}


func _ready() -> void:
	_scan_themes()
	register_effect_executor(&"damage", DamageExecutorScript)
	register_effect_executor(&"heal", HealExecutorScript)
	register_effect_executor(&"composite", CompositeExecutorScript)
	_assert_effect_data_complete()
	register_action_executor(&"move", MoveExecutorScript)


func register_effect_executor(type_id: StringName, script: Script) -> void:
	effect_executors[type_id] = script


func register_action_executor(type_id: StringName, script: Script) -> void:
	action_executors[type_id] = script


func register_status_class(id: StringName, script: Script) -> void:
	status_classes[id] = script


func index_data(resource: Resource) -> void:
	var id: StringName = _extract_id(resource)
	if id == &"":
		return
	data_index[id] = resource


func create_effect_executor(data: Resource) -> RefCounted:
	assert(effect_executors.has(data.type_id), "Registry.create_effect_executor: no executor for type_id=%s" % data.type_id)
	return effect_executors[data.type_id].new()


func create_action_executor(data: Resource) -> RefCounted:
	assert(action_executors.has(data.type_id), "Registry.create_action_executor: no executor for type_id=%s" % data.type_id)
	return action_executors[data.type_id].new()


func get_data(id: StringName) -> Resource:
	return data_index.get(id, null)


func _extract_id(resource: Resource) -> StringName:
	if "id" in resource and resource.id is StringName and resource.id != &"":
		return resource.id
	if resource.resource_path != "":
		return StringName(resource.resource_path.get_file().get_basename())
	return &""


func _scan_themes() -> void:
	for theme in _THEME_DIRS:
		_scan_directory(theme)


func _scan_directory(dir_path: String) -> void:
	var entries: PackedStringArray = ResourceLoader.list_directory(dir_path)
	for entry in entries:
		var full_path: String = dir_path.path_join(entry)
		if full_path.ends_with("/"):
			if full_path.trim_suffix("/").get_file() == "tests":
				continue
			_scan_directory(full_path)
		elif full_path.ends_with(".tres") or full_path.ends_with(".res"):
			_index_file(full_path)


func _index_file(path: String) -> void:
	var resource: Resource = load(path)
	if resource == null:
		return
	index_data(resource)


func _assert_effect_data_complete() -> void:
	for id in data_index:
		var resource: Resource = data_index[id]
		if "type_id" in resource:
			var type_id_value: Variant = resource.type_id
			if type_id_value is StringName and type_id_value != &"" and not effect_executors.has(type_id_value):
				assert(false, "Registry: resource at %s has type_id=%s but no executor is registered" % [resource.resource_path, type_id_value])
