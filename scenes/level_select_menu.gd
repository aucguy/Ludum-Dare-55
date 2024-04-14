extends Node2D

signal select_level
signal back


func _on_level_1_button_pressed():
	select_level.emit(1)

func _on_level_2_button_pressed():
	select_level.emit(2)

func _on_level_3_button_pressed():
	select_level.emit(3)

func _on_back_button_pressed():
	back.emit()
