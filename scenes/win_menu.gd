extends Node2D

signal main_menu

func _on_main_menu_button_pressed():
	main_menu.emit()
