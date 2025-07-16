class_name BallStateFactory

var states: Dictionary = {
	Ball.State.CARRIED: BallStateCarried,
	Ball.State.FREEFORM: BallStateFreeform,
	Ball.State.SHOT: BallStateShot
}

func get_fresh_state(state: Ball.State) -> BallState:
	assert(states.has(state), "Unknown state: $state")
	return states[state].new()
