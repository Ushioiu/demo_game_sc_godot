class_name GameStateOvertime extends GameState

func _enter_tree() -> void:
	GameEvents.team_scored.connect(on_team_scored)

func on_team_scored(_country: String) -> void:
	manager.increase_score(state_data.country_on_scored)
	transition_state(GameManager.State.GAMEOVER)