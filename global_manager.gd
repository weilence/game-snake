extends Node

var APPLE_SCENE = preload("res://apple.tscn")

var score: int = 0
var apples: Array[Vector2] = []
signal score_changed(new_score: int)
signal grow_snake()

func _ready():
	start_game()

func start_game() -> void:
	score = 0
	apples.clear()
	emit_signal("score_changed", score)
	$AppleSpawnTimer.start()

func game_over() -> void:
	$AppleSpawnTimer.stop()
	print("Game Over! Final Score: ", score)
	get_tree().quit()

func _on_snake_move_to(pos: Vector2) -> void:
	if pos.x < 0 || pos.x >= Global.size.x || pos.y < 0 || pos.y >= Global.size.y:
		game_over()

	var apple_index = apples.find(pos)
	if apple_index != -1:
		apples.remove_at(apple_index)
		var apple_node: Apple = get_tree().get_nodes_in_group("apple")[apple_index]
		score += apple_node.score
		apple_node.queue_free()
		emit_signal("score_changed", score)
		emit_signal("grow_snake")


func _on_apple_spawn_timer_timeout() -> void:
	if apples.size() >= Global.MAX_APPLE_COUNT:
		return

	var apple = Vector2(randi_range(0, int(Global.size.x - 1)), randi_range(0, int(Global.size.y - 1)))
	apples.append(apple)
	print("Spawn apple at: ", apple)

	var apple_node: Node2D = APPLE_SCENE.instantiate()
	apple_node.position = apple * Global.CELL_SIZE
	add_child(apple_node)
