extends CanvasLayer

signal game
signal main_menu

func _on_game_button_pressed():
	game.emit()

func _on_main_menu_button_pressed():
	main_menu.emit()
