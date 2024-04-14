extends Node2D

var current_scene = "main_menu"

func _ready():
	change_scene("main_menu")
	print($Game.visible)
	
func _process(delta):
	if $Game.visible and Input.is_action_just_pressed("pause_menu"):
		if $PauseMenu.visible:
			hide_pause_menu()
		else:
			show_pause_menu()

func show_pause_menu():
	$PauseMenu.show()
	$Game.pause()

func hide_pause_menu():
	$PauseMenu.hide()
	$Game.unpause()

func change_scene(name):
	current_scene = name
	$Game.disable()
	$MainMenu.hide()
	$LevelSelectMenu.hide()
	$PauseMenu.hide()
	if name == "main_menu":
		$MainMenu.show()
	elif name == "game":
		$Game.enable()
	elif name == "level_select":
		$LevelSelectMenu.show()

func _on_main_menu_play():
	change_scene("game")
	$Game.load_level(1)

func _on_main_menu_select_level():
	change_scene("level_select")

func _on_level_select_menu_back():
	change_scene("main_menu")

func _on_level_select_menu_select_level(level_no):
	change_scene("game")
	$Game.load_level(level_no)

func _on_pause_menu_game():
	hide_pause_menu()

func _on_pause_menu_main_menu():
	change_scene("main_menu")
