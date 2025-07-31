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

	if KeyUtils.is_action_just_pressed(player.control_sheme, KeyUtils.Action.PASS):
		if player.has_ball():
			transition_state(Player.State.PASSING)
		elif can_teammate_pass_ball():
			ball.carrier.get_pass_request(player)
		else :
			player.swap_requested.emit(player)
	elif KeyUtils.is_action_just_pressed(player.control_sheme, KeyUtils.Action.SHOOT):
		if player.has_ball():
			transition_state(Player.State.PREPPING_SHOT)
		elif ball.can_air_interact():
			if player.velocity == Vector2.ZERO:
				if player.is_facing_target_goal():
					transition_state(Player.State.VOLLEY_KICK)
				else:
					transition_state(Player.State.BICYLE_KICK)
			else:
				transition_state(Player.State.HEADER)
		elif player.velocity != Vector2.ZERO:
			state_transition_requested.emit(Player.State.TACKLING)

func can_carry_ball() -> bool:
	return player.role != Player.Role.GOALIE

func can_pass() -> bool:
	return true

func can_teammate_pass_ball() -> bool:
	return ball.carrier != null and ball.carrier.country == player.country and ball.carrier.control_sheme == Player.ControlScheme.CPU