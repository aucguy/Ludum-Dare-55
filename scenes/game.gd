extends Node2D

var constants = load("res://constants.gd")
var level_scene = preload("res://scenes/level.tscn")
var level = null

var last_dark_spread = 0
var level_no = 0

signal win

func load_level(level_no):
	self.level_no = level_no
	last_dark_spread = 0
	$Hud.reset()
	if level != null:
		level.queue_free()
		level = null
	level = level_scene.instantiate()
	level.init(level_no, $Hud.turn_count)
	level.connect("spirit_attacked", func(spirit): spirit_attacked(spirit))
	add_child(level)
	process_mode = Node.PROCESS_MODE_INHERIT
	$Music.play()
	var map_data = level.map.get_node("MapData")
	if map_data != null:
		$Camera2D.position = map_data.initial_position
		$Camera2D.zoom.x = map_data.initial_zoom
		$Camera2D.zoom.y = map_data.initial_zoom
	else:
		$Camera2D.position = Vector2i.ZERO
		$Camera2D.zoom.x = 0
		$Camera2D.zoom.y = 0

func _process(delta):
	var coeff = $Camera2D.zoom.y
	if Input.is_action_pressed("left"):
		$Camera2D.position.x -= $Camera2D.zoom.y * constants.MOVE_SPEED
	if Input.is_action_pressed("right"):
		$Camera2D.position.x += $Camera2D.zoom.y * constants.MOVE_SPEED
	if Input.is_action_pressed("up"):
		$Camera2D.position.y -= $Camera2D.zoom.y * constants.MOVE_SPEED
	if Input.is_action_pressed("down"):
		$Camera2D.position.y += $Camera2D.zoom.y * constants.MOVE_SPEED
	if Input.is_action_pressed("zoom_in"):
		$Camera2D.zoom.x += $Camera2D.zoom.y * delta * constants.ZOOM_SPEED
		$Camera2D.zoom.y += $Camera2D.zoom.y * delta * constants.ZOOM_SPEED
		if $Camera2D.zoom.x > constants.ZOOM_MAX:
			$Camera2D.zoom.x = constants.ZOOM_MAX
			$Camera2D.zoom.y = constants.ZOOM_MAX
	if Input.is_action_pressed("zoom_out"):
		$Camera2D.zoom.x -= $Camera2D.zoom.y * delta * constants.ZOOM_SPEED
		$Camera2D.zoom.y -= $Camera2D.zoom.y * delta * constants.ZOOM_SPEED
		if $Camera2D.zoom.x < constants.ZOOM_MIN:
			$Camera2D.zoom.x = constants.ZOOM_MIN
			$Camera2D.zoom.y = constants.ZOOM_MIN
	if Input.is_action_just_pressed("print_camera"):
		print("camera data: x = " + str($Camera2D.position.x) + ", y = " + str($Camera2D.position.y) + ", zoom = " + str($Camera2D.zoom.x))

	if level != null and $Hud.selected_spirit != null:
		var cost
		if $Hud.selected_spirit == "archer":
			cost = constants.ARCHER_COST
		if $Hud.selected_spirit == "mage":
			cost = constants.MAGE_COST
		if $Hud.selected_spirit == "defender":
			cost = constants.DEFENDER_COST
		if $Hud.selected_spirit == "elder":
			cost = constants.ELDER_COST
		if $Hud.current_mana >= cost and level.place_spirits($Hud.turn_count):
			$Hud.increment_mana(-cost)
			$SpawnSound.play()

func disable():
	hide()
	$Camera2D.enabled = false
	$Hud.hide()
	
func enable():
	show()
	$Camera2D.enabled = true
	$Hud.show()
	
func pause():
	process_mode = Node.PROCESS_MODE_DISABLED
	
func unpause():
	process_mode = Node.PROCESS_MODE_INHERIT

func _on_hud_next_turn():
	$Hud.turn_count += 1
	var turn_count = $Hud.turn_count
	
	level.before_turn()
	level.attack(turn_count)
	level.spawn_enemies(turn_count)
	level.hurt_in_darkness()
	
	if turn_count >= last_dark_spread + constants.DARK_SPREAD_INTERVAL:
		level.spread_dark()
		last_dark_spread = turn_count
	
	$Hud.increment_mana(level.earned_mana())
	$Hud.sync_display()
	level.after_turn()
	$SpawnSound.play()

func spirit_attacked(spirit):
	if not $AttackSound.playing:
		$AttackSound.play()
	if spirit.health > 0:
		if not $DeathSound.playing:
			$DeathSound.play()

func _on_hud_start_portal():
	if $Hud.current_mana >= constants.PORTAL_COST:
		$Hud.increment_mana(-constants.PORTAL_COST)
		if level_no >= constants.MAX_LEVEL:
			win.emit()
		else:
			load_level(level_no + 1)
		$PortalSound.play()

func _on_music_finished():
	$Music.play()

func _on_hud_restart_level():
	load_level(level_no)

func _on_hud_spirit_selected(selected_spirit):
	level.selected_spirit = selected_spirit
