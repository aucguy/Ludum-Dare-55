extends CanvasLayer

const constants = preload("res://constants.gd")

@onready var current_mana = constants.INITIAL_MANA
@onready var turn_count = 0

var selected_spirit = null

signal next_turn
signal start_portal
signal restart_level
signal spirit_selected

func _ready():
	sync_display()
	
func _process(delta):
	if Input.is_action_just_pressed("next_turn"):
		_on_next_turn_pressed()
	if Input.is_action_just_pressed("spawn_archer"):
		_on_spawn_archer_pressed()
	if Input.is_action_just_pressed("spawn_mage"):
		_on_spawn_mage_pressed()
	if Input.is_action_just_pressed("spawn_defender"):
		_on_spawn_defender_pressed()
	if Input.is_action_just_pressed("spawn_elder"):
		_on_spawn_elder_pressed()

func sync_display():
	$TurnCount.text = str(turn_count)
	$ManaLabel.text = "MANA:" + str(current_mana) + "/" + str(constants.MAXIMUM_MANA)
	$ManaBar.amount = current_mana
	$ManaBar.max_amount = constants.MAXIMUM_MANA
	$ManaBar.queue_redraw()

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
	selected_spirit = "archer"
	$Outline.position = $SpawnArcher.position
	$Outline.show()
	spirit_selected.emit(selected_spirit)

func _on_spawn_mage_pressed():
	selected_spirit = "mage"
	$Outline.position = $SpawnMage.position
	$Outline.show()
	spirit_selected.emit(selected_spirit)

func _on_spawn_defender_pressed():
	selected_spirit = "defender"
	$Outline.position = $SpawnDefender.position
	$Outline.show()
	spirit_selected.emit(selected_spirit)

func _on_spawn_elder_pressed():
	selected_spirit = "elder"
	$Outline.position = $SpawnElder.position
	$Outline.show()
	spirit_selected.emit(selected_spirit)
	
func _on_next_turn_pressed():
	next_turn.emit()

func _on_portal_button_pressed():
	start_portal.emit()

func _on_restart_button_pressed():
	restart_level.emit()
