class_name ActorUtils
extends RefCounted


## Static helpers for locating components on an actor by class.
## The codebase convention is to add components as direct children of the actor,
## and to look them up with a `for child in actor.get_children(): is T` walk.


static func find_component(actor: Node, T) -> Node:
	assert(actor != null, "ActorUtils.find_component: actor is null")
	for child in actor.get_children():
		if is_instance_of(child, T):
			return child
	return null


static func chebyshev(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


static func is_dead(actor: Node) -> bool:
	assert(actor != null, "ActorUtils.is_dead: actor is null")
	var health: HealthComponent = find_component(actor, HealthComponent)
	if health == null:
		return false
	return health.is_dead()
