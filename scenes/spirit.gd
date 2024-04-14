extends Node2D

var constants = load("res://constants.gd")

var team = "light"
var type = "archer"

const HEALTH_LEFT = 8 * -4
const HEALTH_TOP = 8 * -8
const HEALTH_WIDTH = 8 * 8
const HEALTH_HEIGHT = 8 * 2
const HEALTH_FILL_COLOR = Color(1, 0, 0)
const HEALTH_OUTLINE_COLOR = Color(0, 0, 0)
const HEALTH_OUTLINE_WIDTH = 4

var health = constants.MAXIMUM_HEALTH

signal die

func init(team, type, position):
	self.team = team
	self.type = type
	self.position = position
	
	if type == "archer":
		modulate.g = 0.25
		modulate.b = 0.25
		
	if team == "dark":
		modulate.r *= 0.75
		modulate.g *= 0.75
		modulate.b *= 0.75
	
	queue_redraw()

func _draw():
	var width = HEALTH_WIDTH * health / constants.MAXIMUM_HEALTH
	var rect = Rect2(HEALTH_LEFT, HEALTH_TOP, width, HEALTH_HEIGHT)
	draw_rect(rect, HEALTH_FILL_COLOR, true)
	rect = Rect2(HEALTH_LEFT, HEALTH_TOP, HEALTH_WIDTH, HEALTH_HEIGHT)
	draw_rect(rect, HEALTH_OUTLINE_COLOR, false, HEALTH_OUTLINE_WIDTH)
	
func increment_health(amount):
	health += amount
	if health < 0:
		health = 0
		die.emit()
	elif health > constants.MAXIMUM_HEALTH:
		health = constants.MAXIMUM_HEALTH
	queue_redraw()

func attack(level, location):
	var tilemap = level.get_tilemap()
	for target_location in tiles_in_range(tilemap, location, 2):
		var target_spirit = level.get_spirit_at(target_location)
		if target_spirit != null and target_spirit != self and target_spirit.team != team:
			target_spirit.increment_health(-10)
			
func tiles_in_range(tilemap, center, radius):
	var tiles = [center]
	var index = 0
	var iteration = 0
	
	while iteration < radius:
		var size = tiles.size()
		while index < size:
			for neighbor in tilemap.get_surrounding_cells(tiles[index]):
				if neighbor not in tiles:
					tiles.append(neighbor)
			index += 1
		iteration += 1
	return tiles
