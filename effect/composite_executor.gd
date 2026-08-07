class_name CompositeExecutor
extends EffectExecutor


func execute(ctx: EffectContext) -> void:
	if data is CompositeEffectData:
		for inner_effect in data.effects:
			var inner_executor: RefCounted = Registry.create_effect_executor(inner_effect)
			inner_executor.data = inner_effect
			inner_executor.execute(ctx)
	else:
		push_error("CompositeExecutor.data must be CompositeEffectData")
