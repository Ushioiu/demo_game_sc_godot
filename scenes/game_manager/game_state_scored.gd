class_name GameStateScored extends GameState

const DURATION_CELEBRATION := 3000

var time_since_celebration := Time.get_ticks_msec()

func _enter_tree() -> void:
	var idx_country_scoring := 1 if state_data.country_on_scored == GameManager.countries[0] else 0
	manager.score[idx_country_scoring] += 1
	GameEvents.score_changed.emit()
	time_since_celebration = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_celebration > DURATION_CELEBRATION:
		transition_state(GameManager.State.RESET, state_data)