class_name PlayerStateMoving
extends PlayerState

func _process(_delta: float) -> void:
	if player.control_sheme == Player.ControlScheme.CPU:
		pass # ai movement
	else :
		handle_human_movenment()
	player.set_movement_animation()
	player.set_heading()

func handle_human_movenment() -> void:
	var direction := KeyUtils.get_input_vector(player.control_sheme)
	player.velocity = direction * player.speed # 每秒像素
	
	if player.velocity != Vector2.ZERO and \
	KeyUtils.is_action_just_pressed(player.control_sheme, KeyUtils.Action.SHOOT):
		state_transition_requested.emit(Player.State.TACKLING)
