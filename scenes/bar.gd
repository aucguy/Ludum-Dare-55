@tool

extends Node2D

@export var width = 8 * 8:
	set(value):
		width = value
		queue_redraw()
@export var height = 8 * 2:
	set(value):
		height = value
		queue_redraw()
@export var fill_color = Color(1, 0, 0):
	set(value):
		fill_color = value
		queue_redraw()
@export var outline_color = Color(0, 0, 0):
	set(value):
		outline_color = value
		queue_redraw()
@export var outline_width = 4:
	set(value):
		outline_width = value
		queue_redraw()
@export var amount: int:
	set(value):
		amount = value
		queue_redraw()
@export var max_amount: int = 100:
	set(value):
		max_amount = value
		queue_redraw()

func _ready():
	queue_redraw()

func _draw():
	var left = -width / 2
	var top =  -height / 2
	var filled_width = width * amount / max_amount
	var rect = Rect2(left, top, filled_width, height)
	draw_rect(rect, fill_color, true)
	rect = Rect2(left, top, width, height)
	draw_rect(rect, outline_color, false, outline_width)

func set_amount(amount):
	self.amount = amount
	queue_redraw()
