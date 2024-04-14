extends Node2D

var constants = load("res://constants.gd")
var level_scene = preload("res://scenes/level.tscn")
var level = null

var last_dark_spread = 0
var level_no = 0

func load_level(level_no):
	self.level_no = level_no
	last_dark_spread = 0
	$Hud.reset()
	level = level_scene.instantiate()
	level.init(level_no, $Hud.turn_count)
	add_child(level)
	process_mode = Node.PROCESS_MODE_INHERIT

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

func spawn_spirit(type, cost):
	if $Hud.current_mana >= cost and level.spawn_spirit("light", type, level.selected_tile, $Hud.turn_count):
		$Hud.increment_mana(-cost)

func _on_hud_spawn_archer():
	spawn_spirit("archer", constants.ARCHER_COST)

func _on_hud_spawn_mage():
	spawn_spirit("mage", constants.MAGE_COST)

func _on_hud_spawn_defender():
	spawn_spirit("defender", constants.DEFENDER_COST)

func _on_hud_spawn_elder():
	spawn_spirit("elder", constants.ELDER_COST)

func _on_hud_start_portal():
	if $Hud.current_mana > constants.PORTAL_COST:
		$Hud.increment_mana(-constants.PORTAL_COST)
		if level != null:
			level.queue_free()
			level = null
			load_level(level_no + 1)
