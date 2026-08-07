class_name CardView
extends Control


signal pressed


@export var data: CardData = null
@export var name_label: Label = null
@export var energy_cost_label: Label = null
@export var description_label: RichTextLabel = null
@export var disabled_overlay: ColorRect = null
@export var button: Button = null


func _ready() -> void:
	if name_label == null:
		name_label = get_node_or_null("%name_label") as Label
	if energy_cost_label == null:
		energy_cost_label = get_node_or_null("%energy_cost_label") as Label
	if description_label == null:
		description_label = get_node_or_null("%description_label") as RichTextLabel
	if disabled_overlay == null:
		disabled_overlay = get_node_or_null("%disabled_overlay") as ColorRect
	if button == null:
		button = get_node_or_null("%button") as Button
	if button != null and not button.pressed.is_connected(_on_button_pressed):
		button.pressed.connect(_on_button_pressed)
	_refresh()


func _on_button_pressed() -> void:
	pressed.emit()


func set_playable(playable: bool) -> void:
	if disabled_overlay != null:
		disabled_overlay.visible = not playable
	if button != null:
		button.disabled = not playable


func set_selected(selected: bool) -> void:
	if selected:
		modulate = Color(1.5, 1.5, 1.5)
	else:
		modulate = Color(1, 1, 1)


func set_data(new_data: CardData) -> void:
	data = new_data
	_refresh()


func _refresh() -> void:
	if data == null:
		return
	if name_label != null:
		name_label.text = data.name
	if energy_cost_label != null:
		energy_cost_label.text = str(data.energy_cost)
	if description_label != null:
		description_label.text = data.description
