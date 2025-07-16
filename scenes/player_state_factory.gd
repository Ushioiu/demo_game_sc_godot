class_name PlayerStateFactory

var states: Dictionary = {
	Player.State.MOVING: PlayerStateMoving,
	Player.State.TACKLING: PlayerStateTackling,
	Player.State.RECOVERING: PlayerStateRecovering
}

func get_fresh_state(state: Player.State) -> PlayerState:
	assert(state in states.keys(), "state not found")
	return states[state].new()
