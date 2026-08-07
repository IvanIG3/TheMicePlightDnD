extends GutTest


const ActionBudgetComponentScript := preload("res://character/action_budget_component.gd")


var _comp: ActionBudgetComponent


func before_each() -> void:
	_comp = ActionBudgetComponentScript.new()
	add_child_autofree(_comp)


func test_can_perform_returns_true_initially() -> void:
	assert_true(_comp.can_perform(&"move"), "fresh component can perform any action")


func test_spend_returns_true_and_blocks_subsequent() -> void:
	assert_true(_comp.spend(&"move"), "first spend returns true")
	assert_false(_comp.can_perform(&"move"), "can_perform is false after spend")
	assert_false(_comp.spend(&"move"), "second spend returns false")


func test_reset_clears_spend() -> void:
	_comp.spend(&"move")
	_comp.reset()
	assert_true(_comp.can_perform(&"move"), "can_perform is true after reset")


func test_independent_action_types() -> void:
	_comp.spend(&"move")
	assert_true(_comp.can_perform(&"attack"), "attack is independent of move")
	assert_true(_comp.can_perform(&"wait"), "wait is independent of move")


func test_spend_different_types_both_succeed() -> void:
	assert_true(_comp.spend(&"move"), "spend move returns true")
	assert_true(_comp.spend(&"attack"), "spend attack returns true")
	assert_false(_comp.can_perform(&"move"), "move is now blocked")
	assert_false(_comp.can_perform(&"attack"), "attack is now blocked")


func test_reset_then_can_spend_again() -> void:
	_comp.spend(&"move")
	_comp.reset()
	assert_true(_comp.spend(&"move"), "spend after reset returns true")
