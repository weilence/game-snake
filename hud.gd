extends CanvasLayer

signal start_game

func _on_game_manager_score_changed(new_score: int) -> void:
	$ScoreContainer/ScoreValueLabel.text = str(new_score)


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	$ScoreContainer.show()
	emit_signal("start_game")


func _on_game_manager_game_over() -> void:
	$StartButton.show()
	$ScoreContainer.hide()
