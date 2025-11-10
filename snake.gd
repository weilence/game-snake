extends Node2D

signal move_to(new_position: Vector2)
signal die()

var SEGMENT_SCENE = preload("res://snake_segment.tscn")

var head = Vector2(1, 0)
var bodys: Array[Vector2] = [Vector2(0, 0)]
var direction = Vector2.RIGHT
var move_direction = Vector2.RIGHT
var timer = 0.0
var move_interval = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SnakeHead.position = head * Global.CELL_SIZE
	var segments = $SnakeBody.get_children()
	for i in range(segments.size()):
		segments[i].position = bodys[i] * Global.CELL_SIZE
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_right") && direction != Vector2.LEFT:
		move_direction = Vector2.RIGHT
	elif Input.is_action_pressed("ui_left") && direction != Vector2.RIGHT:
		move_direction = Vector2.LEFT
	elif Input.is_action_pressed("ui_up") && direction != Vector2.DOWN:
		move_direction = Vector2.UP
	elif Input.is_action_pressed("ui_down") && direction != Vector2.UP:
		move_direction = Vector2.DOWN
	
	timer += delta
	if move_direction != Vector2.ZERO && timer >= move_interval:
		direction = move_direction

		var new_head = head + direction
		if bodys.has(new_head):
			emit_signal("die")
		emit_signal("move_to", new_head)
		
		for i in range(bodys.size() - 1, 0, -1):
			bodys[i] = bodys[i - 1]
		bodys[0] = head
		head = new_head
		timer = 0.0
	
	var segments = $SnakeBody.get_children()
	$SnakeHead.position = ($SnakeHead.position as Vector2).move_toward(head * Global.CELL_SIZE, Global.CELL_SIZE * delta / move_interval)
	for i in range(0, segments.size()):
		var segment = segments[i]
		segment.position = (segment.position as Vector2).move_toward(bodys[i] * Global.CELL_SIZE, Global.CELL_SIZE * delta / move_interval)


func _on_game_manager_score_changed(new_score: int) -> void:
	move_interval = max(0.05, 0.2 - new_score * 0.01)

func _on_game_manager_grow_snake() -> void:
	var index = bodys.size() - 1
	
	var new_segment = SEGMENT_SCENE.instantiate()
	new_segment.position = $SnakeBody.get_children()[index].position

	bodys.append(bodys[index])
	$SnakeBody.add_child(new_segment)
