class_name PlayerStateVolleyKick extends PlayerState

const VOLLEY_KICK_POWER := 1.2

func _ready() -> void:
	air_connect_min_height = 5
	air_connect_max_height = 10

func _enter_tree() -> void:
	animation_player.play("volley_kick")
	ball_detection_area.body_entered.connect(on_ball_entered)

func on_ball_entered(connect_ball: Ball) -> void:
	if connect_ball.can_air_connect(air_connect_min_height, air_connect_max_height):
		var target_position := target_goal.get_random_target_position()
		var direction := player.position.direction_to(target_position)
		SoundPlayer.play(SoundPlayer.Sound.POWERSHOT)
		connect_ball.ball_shot(direction * player.power * VOLLEY_KICK_POWER)

func on_animation_complete() -> void:
	transition_state(Player.State.RECOVERING)
