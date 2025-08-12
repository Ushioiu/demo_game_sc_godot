class_name GameStateInPlay extends GameState

func _enter_tree() -> void:
	GameEvents.team_scored.connect(on_team_scored)

func _process(delta: float) -> void:
	manager.time_left -= delta
	if manager.is_time_up():
		if manager.current_match.is_tied():
			transition_state(GameManager.State.OVERTIME)
		else:
			transition_state(GameManager.State.GAMEOVER)

func on_team_scored(country_on_scored: String) -> void:
	transition_state(GameManager.State.SCORED, GameStateData.build().set_country_on_scored(country_on_scored))
