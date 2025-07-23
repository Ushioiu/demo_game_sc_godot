class_name PlayerStateFactory

var states: Dictionary = {
	Player.State.MOVING: PlayerStateMoving,
	Player.State.TACKLING: PlayerStateTackling,
	Player.State.RECOVERING: PlayerStateRecovering,
	Player.State.PREPPING_SHOT: PlayerStatePreppingShot,
	Player.State.SHOOTING: PlayerStateShooting,
	Player.State.PASSING: PlayerStatePassing,
	Player.State.HEADER: PlayerStateHeader,
	Player.State.VOLLEY_KICK: PlayerStateVolleyKick,
	Player.State.BICYLE_KICK: PlayerStateBicyleKick,
	Player.State.CHEST_CONTROL: PlayerStateChestControl,
	Player.State.HURT: PlayerStateHurt,
	Player.State.DIVING: PlayerStateDiving,
}

func get_fresh_state(state: Player.State) -> PlayerState:
	assert(state in states.keys(), "state not found")
	return states[state].new()
