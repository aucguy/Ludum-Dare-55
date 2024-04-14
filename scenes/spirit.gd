extends Node2D

@export var projectile_scene: PackedScene

var constants = load("res://constants.gd")

var team = "light"
var type = "archer"
var max_health = 0
var health = 0
var last_attack = -100

const HEALTH_LEFT = 8 * -4
const HEALTH_TOP = 8 * -8
const HEALTH_WIDTH = 8 * 8
const HEALTH_HEIGHT = 8 * 2
const HEALTH_FILL_COLOR = Color(1, 0, 0)
const HEALTH_OUTLINE_COLOR = Color(0, 0, 0)
const HEALTH_OUTLINE_WIDTH = 4

signal die

func init(team, type, position, turn):
	self.team = team
	self.type = type
	self.position = position
	last_attack = turn
	
	if type == "archer":
		$Sprite2D.modulate.g = 0.25
		$Sprite2D.modulate.b = 0.25
		max_health = constants.ARCHER_HEALTH
	elif type == "mage":
		$Sprite2D.modulate.r = 0.25
		$Sprite2D.modulate.b = 0.25
		max_health = constants.MAGE_HEALTH
	elif type == "defender":
		$Sprite2D.modulate.r = 0.25
		$Sprite2D.modulate.g = 0.25
		max_health = constants.MAGE_HEALTH
	elif type == "elder":
		max_health = constants.MAGE_HEALTH
		
	if team == "dark":
		$Sprite2D.modulate.r *= 0.75
		$Sprite2D.modulate.g *= 0.75
		$Sprite2D.modulate.b *= 0.75
	
	health = max_health
	$Bar.max_amount = max_health
	$Bar.set_amount(health)

#func _draw():
#	var width = HEALTH_WIDTH * health / max_health
#	var rect = Rect2(HEALTH_LEFT, HEALTH_TOP, width, HEALTH_HEIGHT)
#	draw_rect(rect, HEALTH_FILL_COLOR, true)
#	rect = Rect2(HEALTH_LEFT, HEALTH_TOP, HEALTH_WIDTH, HEALTH_HEIGHT)
#	draw_rect(rect, HEALTH_OUTLINE_COLOR, false, HEALTH_OUTLINE_WIDTH)
	
func increment_health(amount):
	health += amount
	if health <= 0:
		health = 0
		die.emit()
	elif health > max_health:
		health = max_health
	$Bar.set_amount(health)

func attack(level, location, turn_count):
	var attack_interval = 1
	if type == "archer":
		attack_interval = constants.ARCHER_ATTACK_INTERVAL
	elif type == "mage":
		attack_interval = constants.MAGE_ATTACK_INTERVAL
	
	if last_attack + attack_interval > turn_count:
		return
	
	var tilemap = level.get_tilemap()
	var targets = tiles_in_range(tilemap, location, 2)
	targets = filter_valid_targets(level, targets)
	if targets.size() != null:
		last_attack = turn_count
		if type == "archer":
			attack_archer(level, targets)
		elif type == "mage":
			attack_mage(level, targets)

func attack_archer(level, targets):
	if targets.size() != 0:
		attack_enemy(level, targets.pick_random())

func attack_mage(level, targets):
	for target in targets:
		attack_enemy(level, target)
		
func attack_enemy(level, target_location):
	var target_spirit = level.get_spirit_at(target_location)
	if target_spirit == null:
		return
		
	var damage = constants.SPIRIT_DAMAGE
	if target_spirit.team == "dark":
		damage *= constants.PLAYER_BONUS
	if in_friendly_field(level, target_location):
		damage *= 0.5
	target_spirit.increment_health(-damage)
	var projectile = projectile_scene.instantiate()
	projectile.init($Sprite2D.modulate)
	add_child(projectile)
	var tween = get_tree().create_tween()
	tween.tween_property(projectile, "global_position", target_spirit.global_position, 1)
	tween.tween_callback(projectile.queue_free)	

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

func filter_valid_targets(level, candidates):
	var result = []
	for candidate in candidates:
		var candidate_spirit = level.get_spirit_at(candidate)
		if candidate_spirit != null and candidate_spirit != self and candidate_spirit.team != team:
			result.append(candidate)
	return result

func in_friendly_field(level, location):
	for cell in tiles_in_range(level.get_tilemap(), location, 2):
		var spirit = level.get_spirit_at(cell)
		if spirit != null and spirit.team == team and spirit.type == "defender":
			return true
	return false
