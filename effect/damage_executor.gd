class_name DamageExecutor
extends EffectExecutor


const DEFAULT_TOUGHNESS: int = 10
const DAMAGE_TYPE_PHYSICAL: StringName = &"physical"
const DAMAGE_TYPE_SPECIAL: StringName = &"special"


func execute(ctx: EffectContext) -> void:
	if data is DamageEffectData:

		var attack_roll: Dictionary = ctx.rng.dice_roll(_make_d20())
		var raw: int = attack_roll.raw
		var source_modifier: int = _get_modifier(ctx.source, data.scaling_attribute)
		var target_toughness: int = _get_toughness(ctx.target)

		if raw == 1:
			ctx.bus.damage_applied.emit(0, ctx.source, ctx.target, false)
			return

		if raw == 20:
			var crit_amount: int = data.dice.max_roll() + source_modifier
			_apply_damage(ctx.target, crit_amount, ctx.source)
			ctx.bus.damage_applied.emit(crit_amount, ctx.source, ctx.target, true)
			return

		var amount: int = data.dice.roll().total + source_modifier

		if data.damage_type == DAMAGE_TYPE_PHYSICAL:
			if raw + source_modifier < target_toughness:
				ctx.bus.damage_applied.emit(0, ctx.source, ctx.target, false)
				return
		elif data.damage_type == DAMAGE_TYPE_SPECIAL:
			var defend_raw: int = ctx.rng.dice_roll(_make_d20()).raw
			var resist_modifier: int = _get_modifier(ctx.target, data.resistance_attribute)
			if defend_raw + resist_modifier >= data.resistance_value:
				amount = floori((amount + 1) / 2.0)

		_apply_damage(ctx.target, amount, ctx.source)
		ctx.bus.damage_applied.emit(amount, ctx.source, ctx.target, false)
	
	else:
		push_error("DamageExecutor.data must be DamageEffectData")


func _make_d20() -> DiceFormula:
	var formula: DiceFormula = DiceFormula.new()
	formula.die = 20
	return formula


func _get_modifier(actor: Node, attr: StringName) -> int:
	if actor == null or attr == &"":
		return 0
	for child in actor.get_children():
		if child is AttributeComponent:
			return child.get_modifier(attr)
	return 0


func _get_toughness(target: Node) -> int:
	if target == null:
		return DEFAULT_TOUGHNESS
	for child in target.get_children():
		if child is HealthComponent:
			return child.toughness
	return DEFAULT_TOUGHNESS


func _apply_damage(target: Node, amount: int, source: Node) -> void:
	if target == null:
		return
	for child in target.get_children():
		if child is HealthComponent:
			child.apply_damage(amount, source)
			return
