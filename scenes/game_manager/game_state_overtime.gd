class_name GameStateOvertime extends GameState

func _enter_tree() -> void:
	GameEvents.team_scored.connect(on_team_scored)

func on_team_scored(country: String) -> void:
	manager.increase_score(country)
	transition_state(GameManager.State.GAMEOVER)