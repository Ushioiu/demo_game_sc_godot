class_name PlayerStateMourning extends PlayerState

func _enter_tree() -> void:
	animation_player.play("mourn")
	player.velocity = Vector2.ZERO
	GameEvents.team_rest.connect(on_team_rest)

func on_team_rest() -> void:
	transition_state(Player.State.RESETTING, PlayerStateData.build().set_reset_position(player.kickoff_position))
