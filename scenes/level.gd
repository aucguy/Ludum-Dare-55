extends Node2D

@export var spirit_scene: PackedScene

const ELEMENT_LAYER = 0
const SPIRIT_SPAWN_OFFSET = Vector2(0.0, -4.0)

var level_no
var map = null
var selected_tile = null
var spirit_positions = {}

func init(level_no):
	self.level_no = level_no
	
func _ready():
	var map_scene = load("res://maps/map-" + str(level_no) + ".tscn")
	if map_scene == null:
		print("can not load level " + str(level_no))
		return
	map = map_scene.instantiate()
	add_child(map)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		var tilemap = get_tilemap()
		var position = tilemap.to_local(event.position)
		position = tilemap.local_to_map(position)
		var data = tilemap.get_cell_tile_data(ELEMENT_LAYER, position)
		if data == null or not data.get_custom_data("selectable"):
			return
		selected_tile = position
		position = tilemap.map_to_local(position)
		position = tilemap.to_global(position)
		$Outline.position = self.to_local(position)
		$Outline.visible = true

func get_tilemap():
	return map.get_node("TileMap")

func spawn_shooter():
	if spirit_scene == null:
		print('spirit scene not selected for level')
		return
	
	if not can_spawn_at(selected_tile):
		return false
	
	var spirit = spirit_scene.instantiate()
	spirit.init("light", "shooter", to_local(spirit_spawn_location(selected_tile)))
	spirit_positions[selected_tile] = spirit
	add_child(spirit)
	return true

func spirit_spawn_location(tile):
	var tilemap = get_tilemap()
	return tilemap.to_global(tilemap.map_to_local(tile) + SPIRIT_SPAWN_OFFSET)

func can_spawn_at(tile):
	if tile == null:
		return false
		
	if tile in spirit_positions:
		return false
	
	var tilemap = get_tilemap()
	var data = tilemap.get_cell_tile_data(ELEMENT_LAYER, tile)
	if data == null:
		return false
		
	var type = data.get_custom_data("type")
	if type != "tree-elder" and type != "tree-alive":
		return false
		
	return true
