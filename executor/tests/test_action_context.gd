extends GutTest


const ActionContextScript := preload("res://executor/action_context.gd")
const GridSystemScript := preload("res://world/grid_system.gd")


func test_fields_default_to_null() -> void:
	var ctx: ActionContext = ActionContextScript.new()
	assert_null(ctx.actor, "actor defaults to null")
	assert_null(ctx.grid, "grid defaults to null")
	assert_null(ctx.rng, "rng defaults to null")
	assert_null(ctx.bus, "bus defaults to null")


func test_fields_are_assignable() -> void:
	var ctx: ActionContext = ActionContextScript.new()
	var actor: Node = Node.new()
	var grid: GridSystem = GridSystemScript.new()
	var rng: Node = Node.new()
	var bus: Node = Node.new()
	ctx.actor = actor
	ctx.grid = grid
	ctx.rng = rng
	ctx.bus = bus
	assert_eq(ctx.actor, actor, "actor stored")
	assert_eq(ctx.grid, grid, "grid stored")
	assert_eq(ctx.rng, rng, "rng stored")
	assert_eq(ctx.bus, bus, "bus stored")
	actor.free()
	grid.free()
	rng.free()
	bus.free()
