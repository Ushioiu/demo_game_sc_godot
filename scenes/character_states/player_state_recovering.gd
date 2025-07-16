class_name PlayerStateRecovering
extends PlayerState

const DURATION_RECOVER := 500

var time_start_recover := Time.get_ticks_msec()

func _enter_tree() -> void:
	player.velocity = Vector2.ZERO
	animation_player.play("recover")
	
func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - DURATION_RECOVER > time_start_recover:
		state_transition_requested.emit(Player.State.MOVING)
