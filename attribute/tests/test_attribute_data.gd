extends GutTest


const AttributeDataScript := preload("res://attribute/attribute_data.gd")


func test_field_defaults() -> void:
	var data: AttributeData = AttributeDataScript.new()
	assert_eq(data.id, &"", "id defaults to empty StringName")
	assert_eq(data.display_name, "", "display_name defaults to empty String")
	assert_eq(data.description, "", "description defaults to empty String")
	assert_eq(data.icon, null, "icon defaults to null")
	assert_eq(data.default_value, 10, "default_value defaults to 10")


func test_field_round_trip() -> void:
	var data: AttributeData = AttributeDataScript.new()
	data.id = &"strength"
	data.display_name = "Strength"
	data.description = "Physical power."
	data.default_value = 14
	assert_eq(data.id, &"strength", "id round-trip")
	assert_eq(data.display_name, "Strength", "display_name round-trip")
	assert_eq(data.description, "Physical power.", "description round-trip")
	assert_eq(data.default_value, 14, "default_value round-trip")


func test_resource_survives_as_resource() -> void:
	var data: AttributeData = AttributeDataScript.new()
	data.id = &"strength"
	var container: Dictionary = {"inner": data}
	var retrieved: Resource = container["inner"]
	assert_same(retrieved, data, "AttributeData should be reference-stable")
	assert_eq(retrieved.id, &"strength", "id preserved across the wrap")
