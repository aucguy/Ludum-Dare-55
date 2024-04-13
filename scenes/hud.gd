extends Node2D

const constants = preload("res://constants.gd")

@onready var current_mana = constants.maximum_mana

signal spawn_shooter

func _ready():
	sync_display()

func sync_display():
	$ManaLabel.text = str(current_mana) + " / " + str(constants.maximum_mana)

func increment_mana(amount):
	current_mana += amount
	if current_mana < 0:
		current_mana = amount
	elif current_mana > constants.maximum_mana:
		current_mana = constants.maximum_mana
	sync_display()

func _on_spawn_shooter_pressed():
	spawn_shooter.emit()
