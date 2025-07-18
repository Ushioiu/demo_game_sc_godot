class_name PlayerStatePreppingShot extends PlayerState

const DURATION_MAX_BONSU := 1000.0
const EASE_REWARD_FACTOR := 2.0

var shot_direction := Vector2.ZERO
var time_start_shot := Time.get_ticks_msec()

func _enter_tree() -> void:
	time_start_shot = Time.get_ticks_msec()
	player.velocity = Vector2.ZERO
	animation_player.play("prep_kick")
	shot_direction = player.heading

func _process(delta) -> void:
	shot_direction += KeyUtils.get_input_vector(player.control_sheme) * delta
	if KeyUtils.is_action_just_released(player.control_sheme, KeyUtils.Action.SHOOT):
		var duration_press := clampf(Time.get_ticks_msec() - time_start_shot, 0.0, DURATION_MAX_BONSU)
		var ease_time = duration_press / DURATION_MAX_BONSU
		var bouns := ease(ease_time, EASE_REWARD_FACTOR)
		var shot_power := player.power * (1 + bouns)
		shot_direction = shot_direction.normalized()
		# print(shot_direction, shot_power)
		var next_state_data = PlayerStateData \
								.build() \
								.set_shot_direction(shot_direction) \
								.set_shot_power(shot_power)
		transition_state(Player.State.SHOOTING, next_state_data)
