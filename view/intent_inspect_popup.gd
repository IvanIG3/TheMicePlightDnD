class_name IntentInspectPopup
extends AcceptDialog


var _label: Label = null


func _ready() -> void:
	title = "Predator Intent"
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size = Vector2(280, 0)
	add_child(_label)


func set_plan(plan: ActionPlan, grid: GridSystem) -> void:
	if _label == null:
		return
	var lines: Array[String] = []
	lines.append("Action: %s" % String(plan.action))
	if plan.target is Vector2i:
		lines.append("Target: %s" % str(plan.target))
	if plan.card != null:
		lines.append("Card: %s" % plan.card.name)
		if plan.card.description != "":
			lines.append("%s" % plan.card.description)
	_label.text = "\n".join(lines)
