extends CanvasLayer

const constants = preload("res://constants.gd")

@onready var current_mana = constants.INITIAL_MANA
@onready var turn_count = 0

signal next_turn
signal spawn_archer
signal spawn_mage
signal spawn_defender
signal spawn_elder
signal start_portal

func _ready():
	sync_display()

func sync_display():
	$TurnCount.text = str(turn_count)
	$ManaLabel.text = "MANA:" + str(current_mana) + "/" + str(constants.MAXIMUM_MANA)

func increment_mana(amount):
	current_mana += amount
	if current_mana < 0:
		current_mana = amount
	elif current_mana > constants.MAXIMUM_MANA:
		current_mana = constants.MAXIMUM_MANA
	sync_display()
	
func reset():
	current_mana = constants.INITIAL_MANA
	turn_count = 0
	sync_display()

func _on_spawn_archer_pressed():
	spawn_archer.emit()

func _on_next_turn_pressed():
	next_turn.emit()

func _on_spawn_mage_pressed():
	spawn_mage.emit()

func _on_spawn_defender_pressed():
	spawn_defender.emit()

func _on_spawn_elder_pressed():
	spawn_elder.emit()

func _on_portal_button_pressed():
	start_portal.emit()
