extends Node2D

@export var spirit_scene: PackedScene

var constants = load("res://constants.gd")

const SPIRIT_SPAWN_OFFSET = Vector2(0.0, -4.0)
const DARKNESS_SOURCE_ID = 0
const DARKNESS_ATLAS_LOC = Vector2i(0, 0)
const FIELD_SOURCE_ID = 1
const FIELD_ATLAS_LOC = Vector2i(0, 0)
const ELEMENTS_SOURCE_ID = 7
const TREE_DEAD_ATLAS_LOC = Vector2i(5, 0)

var level_no
var map = null
var selected_tile = null
var spirit_positions = {}
var spirits_to_delete = []
var elements_layer = 0
var darkness_layer = 0
var field_layer = 0

signal spirit_attacked

func init(level_no, turn_count):
	self.level_no = level_no
	var map_scene = load("res://maps/map-" + str(level_no) + ".tscn")
	if map_scene == null:
		print("can not load level " + str(level_no))
		return
	map = map_scene.instantiate()
	add_child(map)
	
	var tilemap = get_tilemap()
	for layer_no in range(tilemap.get_layers_count()):
		if tilemap.get_layer_name(layer_no) == "elements":
			elements_layer = layer_no
	
	tilemap.add_layer(-1)
	field_layer = tilemap.get_layers_count() - 1
	
	tilemap.add_layer(-1)
	darkness_layer = tilemap.get_layers_count() - 1
	
	var used_rect = tilemap.get_used_rect()
	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var location = Vector2i(x, y)
			var data = tilemap.get_cell_tile_data(elements_layer, location)
			if data != null:
				var type = data.get_custom_data("type")
				if type == "void":
					tilemap.set_cell(darkness_layer, location, DARKNESS_SOURCE_ID, DARKNESS_ATLAS_LOC)
				if type == "tree-elder" or type == "tree-alive":
					spawn_spirit("dark", "archer", location, turn_count, true)

func _process(delta):
	if Input.is_action_just_pressed("select"):
		var tilemap = get_tilemap()
		var position = tilemap.get_local_mouse_position()
		position = tilemap.local_to_map(position)
		var data = tilemap.get_cell_tile_data(elements_layer, position)
		if data == null or not data.get_custom_data("selectable"):
			return
		selected_tile = position
		position = tilemap.map_to_local(position)
		position = tilemap.to_global(position)
		$Outline.position = to_local(position)
		$Outline.visible = true

func before_turn():
	spirits_to_delete = []

func after_turn():
	for spirit in spirits_to_delete:
		spirit_positions.erase(spirit)
	
	spirits_to_delete = []

func get_tilemap():
	return map.get_node("TileMap")

func spawn_spirit(team, type, location, turn, initial_spawn=false):
	if spirit_scene == null:
		print('spirit scene not selected for level')
		return
	
	if not can_spawn_at(team, type, location, initial_spawn):
		return false
	
	var spirit = spirit_scene.instantiate()
	spirit.init(team, type, to_local(spirit_spawn_location(location)), turn)
	spirit_positions[location] = spirit
	spirit.connect("die", func(): despawn_spirit(location, spirit))
	spirit.connect("attacked", func(): spirit_attacked.emit(spirit))
	add_child(spirit)
	
	update_field_tiles()
	
	return true

func despawn_spirit(location, spirit):
	spirits_to_delete.append(location)
	spirit.queue_free()
	update_field_tiles()

func spirit_spawn_location(tile):
	var tilemap = get_tilemap()
	return tilemap.to_global(tilemap.map_to_local(tile) + SPIRIT_SPAWN_OFFSET)

func get_spirit_at(location):
	if location in spirit_positions:
		return spirit_positions[location]
	else:
		return null

func can_spawn_at(team, type, tile, initial_spawn):
	if tile == null:
		return false
		
	if tile in spirit_positions:
		return false
	
	var tilemap = get_tilemap()
	var data = tilemap.get_cell_tile_data(elements_layer, tile)
	if data == null:
		return false
		
	var tile_type = data.get_custom_data("type")
	if team == "light":
		if type == "elder":
			if tile_type != "tree-elder":
				return false
		else:
			if tile_type != "tree-alive" and tile_type != "portal":
				return false
	else:
		assert(team == "dark")
		if tile_type != "tree-dead" and not initial_spawn:
			return false
		
	return true

func attack(turn_count):
	for location in spirit_positions:
		var spirit = spirit_positions[location]
		spirit.attack(self, location, turn_count)
	
func spawn_enemies(turn):
	var tilemap = get_tilemap()
	var used_rect = tilemap.get_used_rect()
	var new_darkness = []
	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var location = Vector2i(x, y)
			var data = tilemap.get_cell_tile_data(elements_layer, location)
			if data != null and data.get_custom_data("type") == "tree-dead":
				spawn_spirit("dark", "archer", location, turn)

func spread_dark():
	var tilemap = get_tilemap()
	var used_rect = tilemap.get_used_rect()
	var new_darkness = []
	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var location = Vector2i(x, y)
			var data = tilemap.get_cell_tile_data(darkness_layer, location)
			if data != null and data.get_custom_data("type") == "darkness":
				for cell in tilemap.get_surrounding_cells(location):
					if cell not in new_darkness:
						new_darkness.append(cell)
	
	for cell in new_darkness:
		var data = tilemap.get_cell_tile_data(elements_layer, cell)
		if data == null:
			continue
		tilemap.set_cell(darkness_layer, cell, DARKNESS_SOURCE_ID, DARKNESS_ATLAS_LOC)
		var type = data.get_custom_data("type")
		if type == "tree-alive" or type == "tree-elder":
			tilemap.set_cell(elements_layer, cell, ELEMENTS_SOURCE_ID, TREE_DEAD_ATLAS_LOC)

func update_field_tiles():
	var tilemap = get_tilemap()
	var used_rect = tilemap.get_used_rect()
	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var location = Vector2i(x, y)
			tilemap.set_cell(field_layer, location, -1)

	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var location = Vector2i(x, y)
			if location in spirit_positions:
				var spirit = spirit_positions[location]
				if spirit.type == "defender":
					for cell in spirit.tiles_in_range(tilemap, location, 2):
						tilemap.set_cell(field_layer, cell, FIELD_SOURCE_ID, FIELD_ATLAS_LOC)

func earned_mana():
	var result = 0
	var tilemap = get_tilemap()
	for spirit_location in spirit_positions:
		var spirit = spirit_positions[spirit_location]
		if spirit.type == "elder" and spirit.team == "light":
			result += 5
	return result

func hurt_in_darkness():
	var tilemap = get_tilemap()
	var used_rect = tilemap.get_used_rect()
	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var location = Vector2i(x, y)
			var data = tilemap.get_cell_tile_data(darkness_layer, location)
			if data != null and data.get_custom_data("type") == "darkness" and location in spirit_positions:
				var spirit = spirit_positions[location]
				if spirit.team == "light":
					spirit.increment_health(-constants.DARKNESS_DAMAGE)
