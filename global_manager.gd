extends Node

var APPLE_SCENE = preload("res://apple.tscn")
var SNAKE_SCENE = preload("res://snake.tscn")

var score: int = 0
var apples: Array[Vector2] = []
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

func _on_snake_move_to(pos: Vector2) -> void:
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

	var apple = Vector2(randi_range(0, int(Global.size.x - 1)), randi_range(0, int(Global.size.y - 1)))
	apples.append(apple)
	print("Spawn apple at: ", apple)

	var apple_node: Node2D = APPLE_SCENE.instantiate()
	apple_node.position = apple * Global.CELL_SIZE
	add_child(apple_node)
