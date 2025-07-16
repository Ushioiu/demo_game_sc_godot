class_name PlayerStateTackling
extends PlayerState

const DURATION_FRIOR_RECOVERY := 200
const GROUND_FRICATION := 250.0

var is_tackle_complete := false
var time_finish_tackle := Time.get_ticks_msec()

func _enter_tree() -> void:
	animation_player.play("tackle")

func _physics_process(delta: float) -> void:
	if !is_tackle_complete:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, delta * GROUND_FRICATION)
		if player.velocity == Vector2.ZERO:
			is_tackle_complete = true
			time_finish_tackle = Time.get_ticks_msec()
	elif Time.get_ticks_msec() - time_finish_tackle > DURATION_FRIOR_RECOVERY:
			state_transition_requested.emit(Player.State.RECOVERING)
