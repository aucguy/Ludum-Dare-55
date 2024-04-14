extends Node2D

var constants = load("res://constants.gd")
var level_scene = preload("res://scenes/level.tscn")
var level = null

var last_dark_spread = 0

func _ready():
	level = level_scene.instantiate()
	level.init(1)
	add_child(level)

func _process(delta):
	if Input.is_action_pressed("left"):
		$Camera2D.position.x -= delta * constants.MOVE_SPEED
	if Input.is_action_pressed("right"):
		$Camera2D.position.x += delta * constants.MOVE_SPEED
	if Input.is_action_pressed("up"):
		$Camera2D.position.y -= delta * constants.MOVE_SPEED
	if Input.is_action_pressed("down"):
		$Camera2D.position.y += delta * constants.MOVE_SPEED
	if Input.is_action_pressed("zoom_in"):
		$Camera2D.zoom.x += delta * constants.ZOOM_SPEED
		$Camera2D.zoom.y += delta * constants.ZOOM_SPEED
		if $Camera2D.zoom.x > constants.ZOOM_MAX:
			$Camera2D.zoom.x = constants.ZOOM_MAX
			$Camera2D.zoom.y = constants.ZOOM_MAX
	if Input.is_action_pressed("zoom_out"):
		$Camera2D.zoom.x -= delta * constants.ZOOM_SPEED
		$Camera2D.zoom.y -= delta * constants.ZOOM_SPEED
		if $Camera2D.zoom.x < constants.ZOOM_MIN:
			$Camera2D.zoom.x = constants.ZOOM_MIN
			$Camera2D.zoom.y = constants.ZOOM_MIN

func _on_hud_next_turn():
	$Hud.turn_count += 1
	var turn_count = $Hud.turn_count
	
	level.attack()
	level.spawn_enemies()
	
	if turn_count >= last_dark_spread + constants.DARK_SPREAD_INTERVAL:
		level.spread_dark()
		last_dark_spread = turn_count
	
	$Hud.sync_display()

func _on_hud_spawn_archer():
	if level != null and level.selected_tile != null:
		if level.spawn_spirit("light", "archer", level.selected_tile):
			$Hud.increment_mana(-constants.SHOOTER_COST)
