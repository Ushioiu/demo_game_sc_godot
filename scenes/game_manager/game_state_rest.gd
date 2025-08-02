class_name GameStateRest extends GameState

var players: Array = []

func _enter_tree() -> void:
	GameEvents.team_rest.emit()
	GameEvents.kickoff_ready.connect(on_kickoff_ready)
	# players = get_tree().get_nodes_in_group("players")

func on_kickoff_ready() -> void:
	transition_state(GameManager.State.KICKOFF, state_data)

# func _process(_delta: float) -> void:
# 	for p : Player in players:
# 		if not p.is_ready_for_kickoff():
# 			print(str(p.current_state))
# 			return
# 	transition_state(GameManager.State.KICKOFF)