extends GutTest


func test_no_duplicates_in_all() -> void:
	var seen: Dictionary = {}
	for value in CardFamilies.ALL:
		assert_false(seen.has(value), "duplicate in ALL: %s" % String(value))
		seen[value] = true


func test_mammal_constant_is_mammal() -> void:
	assert_eq(CardFamilies.MAMMAL, &"mammal", "MAMMAL is &\"mammal\"")


func test_bird_constant_is_bird() -> void:
	assert_eq(CardFamilies.BIRD, &"bird", "BIRD is &\"bird\"")


func test_herptile_constant_is_herptile() -> void:
	assert_eq(CardFamilies.HERPTILE, &"herptile", "HERPTILE is &\"herptile\"")


func test_invertebrate_constant_is_invertebrate() -> void:
	assert_eq(CardFamilies.INVERTEBRATE, &"invertebrate", "INVERTEBRATE is &\"invertebrate\"")


func test_none_constant_is_none() -> void:
	assert_eq(CardFamilies.NONE, &"none", "NONE is &\"none\"")


func test_all_contains_five_families() -> void:
	assert_eq(CardFamilies.ALL.size(), 5, "ALL has 5 families (4 real + none)")
