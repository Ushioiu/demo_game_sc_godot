class_name PlayerStateMoving
extends PlayerState

func _process(_delta: float) -> void:
	if player.control_sheme == Player.ControlScheme.CPU:
		ai_behavior.process_ai()
	else :
		handle_human_movenment()
	player.set_movement_animation()
	player.set_heading()

func handle_human_movenment() -> void:
	var direction := KeyUtils.get_input_vector(player.control_sheme)
	player.velocity = direction * player.speed # 每秒像素
	# 队友扫描转向
	if player.velocity != Vector2.ZERO:
		teammate_detection_area.rotation = player.velocity.angle()
	if player.has_ball():
		if player.has_ball() and KeyUtils.is_action_just_pressed(player.control_sheme, KeyUtils.Action.PASS):
			transition_state(Player.State.PASSING)
		elif player.has_ball() and KeyUtils.is_action_just_pressed(player.control_sheme, KeyUtils.Action.SHOOT):
			transition_state(Player.State.PREPPING_SHOT)
	elif ball.can_air_interact() and KeyUtils.is_action_just_pressed(player.control_sheme, KeyUtils.Action.SHOOT):
		if player.velocity == Vector2.ZERO:
			if player.is_facing_target_goal():
				transition_state(Player.State.VOLLEY_KICK)
			else:
				transition_state(Player.State.BICYLE_KICK)
		else:
			transition_state(Player.State.HEADER)
	# if player.velocity != Vector2.ZERO and \
	# KeyUtils.is_action_just_pressed(player.control_sheme, KeyUtils.Action.SHOOT):
	# 	state_transition_requested.emit(Player.State.TACKLING)


