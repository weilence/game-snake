extends Node

var APPLE_SCENE = preload("res://apple.tscn")
var SNAKE_SCENE = preload("res://snake.tscn")

var score: int = 0
var apples: Array[Vector2i] = []
signal score_changed(new_score: int)
signal game_over

func start_game() -> void:
	score = 0
	apples.clear()
	emit_signal("score_changed", score)
	$AppleSpawnTimer.start()
	create_snake()

func stop_game() -> void:
	$Snake.queue_free()
	$AppleSpawnTimer.stop()
	for apple_node in get_tree().get_nodes_in_group("apple"):
		apple_node.queue_free()
	apples.clear()
	emit_signal("game_over")
	print("Game Over! Final Score: ", score)

func create_snake() -> void:
	var snake_node: Snake = SNAKE_SCENE.instantiate()
	snake_node.connect("move_to", _on_snake_move_to)
	snake_node.connect("die", stop_game)
	connect("score_changed", snake_node._on_game_manager_score_changed)
	add_child(snake_node)

func _on_snake_move_to(pos: Vector2i) -> void:
	var apple_index = apples.find(pos)
	if apple_index != -1:
		apples.remove_at(apple_index)
		var apple_node: Apple = get_tree().get_nodes_in_group("apple")[apple_index]
		score += apple_node.score
		apple_node.queue_free()
		emit_signal("score_changed", score)
		$Snake.grow()


func _on_apple_spawn_timer_timeout() -> void:
	if apples.size() >= Global.MAX_APPLE_COUNT:
		return

	var position = get_random_food_position(Global.size.x, Global.size.y)
	if position == null:
		print("No available position to spawn apple.")
		return

	var apple = Vector2i(randi_range(0, Global.size.x - 1), randi_range(0, Global.size.y - 1))
	apples.append(apple)
	print("Spawn apple at: ", apple)

	var apple_node: Node2D = APPLE_SCENE.instantiate()
	apple_node.position = apple * Global.CELL_SIZE
	add_child(apple_node)

func get_random_food_position(rows: int, cols: int) -> Variant:
	var snake: Snake = $Snake
	var dict: Dictionary = {
		snake.head: true,
	}
	for body in snake.bodys:
		dict[body] = true
	for apple in apples:
		dict[apple] = true

	# 遍历所有格子
	var available: Array[Vector2i] = []
	for x in range(rows):
		for y in range(cols):
			var pos = Vector2i(x, y)
			if pos not in dict:
				available.append(pos)
	
	# 如果没有空位，就返回 null（比如蛇占满全图）
	if available.is_empty():
		return null
	
	# 从空位中随机选一个
	return available.pick_random()
