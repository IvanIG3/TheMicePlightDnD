class_name HealExecutor
extends EffectExecutor


func execute(ctx: EffectContext) -> void:
	if data is HealEffectData:
		var amount: int = data.dice.roll().total
		var actual_healed: int = _apply_heal(ctx.target, amount)
		ctx.bus.heal_applied.emit(actual_healed, ctx.target)
	else:
		push_error("HealExecutor.data must be HealEffectData")


func _apply_heal(target: Node, amount: int) -> int:
	if target == null:
		return 0
	for child in target.get_children():
		if child is HealthComponent:
			return child.apply_heal(amount)
	return 0
