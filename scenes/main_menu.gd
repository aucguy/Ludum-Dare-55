extends Node2D

signal play
signal select_level

func _on_play_button_pressed():
	play.emit()

func _on_level_select_button_pressed():
	select_level.emit()
