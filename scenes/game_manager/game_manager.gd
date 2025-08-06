extends Node

const DURATION_GAME_SEC := 2 * 60
const DURATION_IMPACT_PAUSE := 100

enum State {IN_PLAY, SCORED, RESET, KICKOFF, OVERTIME, GAMEOVER}

var countries: Array[String] = ["FRANCE", "USA"]
var player_setup: Array[String] = ["FRANCE", "USA"] # 对战["FRANCE", "USA"] 同一阵营["FRANCE", "FRANCE"] 单人["FRANCE", ""] 
var score : Array[int] = [0, 0]
var time_left: float
var state_factory := GameStateFactory.new()
var current_state: GameState
var time_since_paused := Time.get_ticks_msec()

func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

func _ready() -> void:
	time_left = DURATION_GAME_SEC
	GameEvents.impact_received.connect(on_impact_received)

func start_game() -> void:
	switch_state(State.RESET)

func _process(_delta: float) -> void:
	if get_tree().paused and Time.get_ticks_msec() - time_since_paused > DURATION_IMPACT_PAUSE:
		get_tree().paused = false

func switch_state(state: State, data: GameStateData = GameStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.state_transition_requested.connect(switch_state)
	current_state.setup(self, data)
	current_state.name = "GameStateMachine_" + str(state)
	call_deferred("add_child", current_state)

func is_coop() -> bool:
	return player_setup[0] == player_setup[1]

func is_single_player() -> bool:
	return player_setup[1].is_empty()

func is_game_tied() -> bool:
	return score[0] == score[1]

func is_time_up() -> bool:
	return time_left <= 0

func get_winner_country() -> String:
	assert(!is_game_tied())
	return countries[0] if score[0] > score[1] else countries[1]

func increase_score(country_on_scored: String) -> void:
	var idx_country_scoring := 1 if country_on_scored == GameManager.countries[0] else 0
	score[idx_country_scoring] += 1
	GameEvents.score_changed.emit()

func has_someone_scored() -> bool:
	return score[0] > 0 or score[1] > 0

func on_impact_received(_impact_position: Vector2, is_height_impact: bool) -> void:
	if is_height_impact:
		time_since_paused = Time.get_ticks_msec()
		get_tree().paused = true
