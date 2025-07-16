class_name PlayerStateTackling
extends PlayerState

const DURATION_TACKLE := 200

var time_start_tackle := Time.get_ticks_msec()

func _enter_tree() -> void:
	animation_player.play("tackle")

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - DURATION_TACKLE > time_start_tackle:
		state_transition_requested.emit(Player.State.MOVING)
