extends GutTest


func test_fields_default_to_null_or_empty() -> void:
	var ctx: EffectContext = EffectContext.new()
	assert_null(ctx.source, "source defaults to null")
	assert_null(ctx.target, "target defaults to null")
	assert_null(ctx.rng, "rng defaults to null")
	assert_null(ctx.bus, "bus defaults to null")
	assert_eq(ctx.metadata, {}, "metadata defaults to empty Dictionary")


func test_fields_are_assignable() -> void:
	var ctx: EffectContext = EffectContext.new()
	var source_node: Node = Node.new()
	var target_node: Node = Node.new()
	var rng_node: Node = Node.new()
	var bus_node: Node = Node.new()
	ctx.source = source_node
	ctx.target = target_node
	ctx.rng = rng_node
	ctx.bus = bus_node
	ctx.metadata = {"element": &"fire", "potency": 3}
	assert_eq(ctx.source, source_node, "source stored")
	assert_eq(ctx.target, target_node, "target stored")
	assert_eq(ctx.rng, rng_node, "rng stored")
	assert_eq(ctx.bus, bus_node, "bus stored")
	assert_eq(ctx.metadata, {"element": &"fire", "potency": 3}, "metadata stored")
	source_node.free()
	target_node.free()
	rng_node.free()
	bus_node.free()
