class_name StatsBaseData
extends Resource

# Minimal class-bases placeholder Resource. Phase 1 ships this two-field
# Resource so StatsComponent can compute derived stats (max_hp, max_energy)
# without depending on the full MouseClassData / PredatorData composition
# (Phase 2+).
#
# When the real class-data Resources land, this is a thin shim: the new
# Resource will either extend this one or replace it via the same
# StatsComponent.init() interface.

@export var max_hp_base: int = 10
@export var max_energy_base: int = 3
