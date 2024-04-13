extends Node2D

var constants = load("res://constants.gd")
var level_scene = preload("res://scenes/level.tscn")
var level = null

func _ready():
	level = level_scene.instantiate()
	level.init(1)
	add_child(level)

func _on_hud_spawn_shooter():
	if level != null:
		if level.spawn_shooter():
			$Hud.increment_mana(-constants.SHOOTER_COST)
	
