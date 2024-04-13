extends Node2D

@export var spirit_scene: PackedScene

const SPIRIT_SPAWN_OFFSET = Vector2(0.0, -4.0)
const DARKNESS_SOURCE_ID = 0
const DARKNESS_ATLAS_LOC = Vector2i(0, 0)
const ELEMENTS_SOURCE_ID = 7
const TREE_DEAD_ATLAS_LOC = Vector2i(5, 0)

var level_no
var map = null
var selected_tile = null
var spirit_positions = {}
var elements_layer = 0
var darkness_layer = 0

func init(level_no):
	self.level_no = level_no
	
func _ready():
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
	darkness_layer = tilemap.get_layers_count() - 1
	
	var used_rect = tilemap.get_used_rect()
	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var location = Vector2i(x, y)
			var data = tilemap.get_cell_tile_data(elements_layer, location)
			if data != null and data.get_custom_data("type") == "void":
				tilemap.set_cell(darkness_layer, location, DARKNESS_SOURCE_ID, DARKNESS_ATLAS_LOC)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		var tilemap = get_tilemap()
		var position = tilemap.to_local(event.position)
		position = tilemap.local_to_map(position)
		var data = tilemap.get_cell_tile_data(elements_layer, position)
		if data == null or not data.get_custom_data("selectable"):
			return
		selected_tile = position
		position = tilemap.map_to_local(position)
		position = tilemap.to_global(position)
		$Outline.position = self.to_local(position)
		$Outline.visible = true

func get_tilemap():
	return map.get_node("TileMap")

func spawn_spirit(team, type, location):
	if spirit_scene == null:
		print('spirit scene not selected for level')
		return
	
	if not can_spawn_at(team, location):
		return false
	
	var spirit = spirit_scene.instantiate()
	spirit.init(team, type, to_local(spirit_spawn_location(location)))
	spirit_positions[location] = spirit
	add_child(spirit)
	return true

func spirit_spawn_location(tile):
	var tilemap = get_tilemap()
	return tilemap.to_global(tilemap.map_to_local(tile) + SPIRIT_SPAWN_OFFSET)

func can_spawn_at(team, tile):
	if tile == null:
		return false
		
	if tile in spirit_positions:
		return false
	
	var tilemap = get_tilemap()
	var data = tilemap.get_cell_tile_data(elements_layer, tile)
	if data == null:
		return false
		
	var type = data.get_custom_data("type")
	if team == "light":
		if type != "tree-elder" and type != "tree-alive":
			return false
	else:
		assert(team == "dark")
		if type != "tree-dead":
			return false
		
	return true
	
func spawn_enemies():
	var tilemap = get_tilemap()
	var used_rect = tilemap.get_used_rect()
	var new_darkness = []
	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var location = Vector2i(x, y)
			var data = tilemap.get_cell_tile_data(elements_layer, location)
			if data != null and data.get_custom_data("type") == "tree-dead":
				spawn_spirit("dark", "shooter", location)

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
