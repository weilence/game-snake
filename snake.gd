extends Node2D
class_name Snake

signal move_to(new_position: Vector2)
signal die()

var SEGMENT_SCENE = preload("res://snake_segment.tscn")

@onready var head = Global.size / 2
@onready var bodys = [head + Vector2i.LEFT]

var direction = Vector2i.RIGHT
var move_direction = Vector2i.RIGHT
var timer = 0.0
@export var move_interval = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Snake ready at position: ", head, " with body: ", bodys)
	$SnakeHead.position = head * Global.CELL_SIZE
	var segments = $SnakeBody.get_children()
	for i in range(segments.size()):
		segments[i].position = bodys[i] * Global.CELL_SIZE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_direction = get_move_direction()

	timer += delta
	if move_direction != Vector2i.ZERO && timer >= move_interval:
		direction = move_direction

		var new_head = (head + direction + Global.size) % Global.size
		if bodys.has(new_head):
			emit_signal("die")
		emit_signal("move_to", new_head)

		# 处理逻辑位置 
		for i in range(bodys.size() - 1, -1, -1):
			bodys[i] = cross_boundary(bodys[i], bodys[i - 1] if i > 0 else head, $SnakeBody.get_child(i))
		head = cross_boundary(head, new_head, $SnakeHead)
		timer = 0.0

	$SnakeHead.position = ($SnakeHead.position as Vector2).move_toward(head * Global.CELL_SIZE, Global.CELL_SIZE * delta / move_interval)
	var segments = $SnakeBody.get_children()
	for i in range(0, segments.size()):
		var segment = segments[i]
		segment.position = (segment.position as Vector2).move_toward(bodys[i] * Global.CELL_SIZE, Global.CELL_SIZE * delta / move_interval)

func get_move_direction() -> Vector2i:
	if Input.is_action_pressed("ui_right") && direction != Vector2i.LEFT:
		return Vector2i.RIGHT
	elif Input.is_action_pressed("ui_left") && direction != Vector2i.RIGHT:
		return Vector2i.LEFT
	elif Input.is_action_pressed("ui_up") && direction != Vector2i.DOWN:
		return Vector2i.UP
	elif Input.is_action_pressed("ui_down") && direction != Vector2i.UP:
		return Vector2i.DOWN
	else:
		return move_direction

func _on_game_manager_score_changed(new_score: int) -> void:
	move_interval = max(0.05, 0.2 - new_score * 0.01)

func grow() -> void:
	var index = bodys.size() - 1
	
	var new_segment = SEGMENT_SCENE.instantiate()
	new_segment.position = $SnakeBody.get_children()[index].position

	bodys.append(bodys[index])
	$SnakeBody.add_child(new_segment)

func vectori_to_vector2(vec: Vector2i) -> Vector2:
	return Vector2(vec.x, vec.y)

func cross_boundary(old_pos: Vector2i, new_pos: Vector2i, node: Node) -> Vector2i:
	if old_pos.x == Global.size.x - 1 && new_pos.x == 0:
		create_cross_boundary_animation(node, Vector2.RIGHT)
		node.position.x = - Global.CELL_SIZE
	elif old_pos.x == 0 && new_pos.x == Global.size.x - 1:
		create_cross_boundary_animation(node, Vector2.LEFT)
		node.position.x = Global.size.x * Global.CELL_SIZE
	elif old_pos.y == Global.size.y - 1 && new_pos.y == 0:
		create_cross_boundary_animation(node, Vector2.DOWN)
		node.position.y = - Global.CELL_SIZE
	elif old_pos.y == 0 && new_pos.y == Global.size.y - 1:
		create_cross_boundary_animation(node, Vector2.UP)
		node.position.y = Global.size.y * Global.CELL_SIZE

	return new_pos

func create_cross_boundary_animation(node: Node, dir: Vector2) -> void:
	var copy_node = node.duplicate()
	var tween = copy_node.create_tween()
	tween.tween_property(copy_node, "position", copy_node.position + dir * Global.CELL_SIZE, move_interval)
	tween.tween_callback(copy_node.queue_free)
	$SnakeBodyCopy.add_child(copy_node)