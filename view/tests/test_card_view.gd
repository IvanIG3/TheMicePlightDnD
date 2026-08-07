extends GutTest


const CardViewPath := "res://view/card_view.gd"
const CardDataPath := "res://card/card_data.gd"


func test_set_data_populates_labels() -> void:
	var card_view_script: GDScript = load(CardViewPath)
	assert_not_null(card_view_script, "CardView script must exist at " + CardViewPath)
	var view: Control = card_view_script.new()
	var name_label: Label = Label.new()
	name_label.name = "name_label"
	var energy_label: Label = Label.new()
	energy_label.name = "energy_cost_label"
	var desc_label: RichTextLabel = RichTextLabel.new()
	desc_label.name = "description_label"
	var disabled: ColorRect = ColorRect.new()
	disabled.name = "disabled_overlay"
	var button: Button = Button.new()
	button.name = "button"
	view.add_child(name_label)
	view.add_child(energy_label)
	view.add_child(desc_label)
	view.add_child(disabled)
	view.add_child(button)
	view.name_label = name_label
	view.energy_cost_label = energy_label
	view.description_label = desc_label
	view.disabled_overlay = disabled
	view.button = button
	add_child_autofree(view)
	var card_data_script: GDScript = load(CardDataPath)
	assert_not_null(card_data_script, "CardData script must exist at " + CardDataPath)
	var card: Resource = card_data_script.new()
	card.name = "Test Card"
	card.energy_cost = 3
	card.description = "A test card"
	view.set_data(card)
	assert_eq(name_label.text, "Test Card", "name label updated")
	assert_eq(energy_label.text, "3", "energy cost label updated")
	assert_eq(desc_label.text, "A test card", "description label updated")


func test_set_playable_toggles_disabled_overlay_and_button() -> void:
	var card_view_script: GDScript = load(CardViewPath)
	assert_not_null(card_view_script, "CardView script must exist at " + CardViewPath)
	var view: Control = card_view_script.new()
	var disabled: ColorRect = ColorRect.new()
	disabled.name = "disabled_overlay"
	var button: Button = Button.new()
	button.name = "button"
	view.add_child(disabled)
	view.add_child(button)
	view.disabled_overlay = disabled
	view.button = button
	add_child_autofree(view)
	view.set_playable(true)
	assert_false(disabled.visible, "overlay hidden when playable")
	assert_false(button.disabled, "button enabled when playable")
	view.set_playable(false)
	assert_true(disabled.visible, "overlay shown when not playable")
	assert_true(button.disabled, "button disabled when not playable")


func test_set_selected_toggles_modulate() -> void:
	var card_view_script: GDScript = load(CardViewPath)
	assert_not_null(card_view_script, "CardView script must exist at " + CardViewPath)
	var view: Control = card_view_script.new()
	add_child_autofree(view)
	view.set_selected(false)
	assert_eq(view.modulate, Color(1, 1, 1), "unselected: normal color")
	view.set_selected(true)
	assert_eq(view.modulate, Color(1.5, 1.5, 1.5), "selected: brighter color")
