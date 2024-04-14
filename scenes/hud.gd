extends CanvasLayer

const constants = preload("res://constants.gd")

@onready var current_mana = constants.maximum_mana
@onready var turn_count = 0

signal next_turn
signal spawn_archer

func _ready():
	sync_display()

func sync_display():
	$TurnCount.text = "Turns: " + str(turn_count)
	$ManaLabel.text = str(current_mana) + " / " + str(constants.maximum_mana)

func increment_mana(amount):
	current_mana += amount
	if current_mana < 0:
		current_mana = amount
	elif current_mana > constants.maximum_mana:
		current_mana = constants.maximum_mana
	sync_display()

func _on_spawn_archer_pressed():
	spawn_archer.emit()

func _on_next_turn_pressed():
	next_turn.emit()
