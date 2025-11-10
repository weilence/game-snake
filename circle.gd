extends Node2D

@export var circle_color: Color = Color(0, 0, 0)
var radius = int(Global.CELL_SIZE / 2.0)

func _draw():
	draw_circle(Vector2(radius, radius), radius, circle_color)
