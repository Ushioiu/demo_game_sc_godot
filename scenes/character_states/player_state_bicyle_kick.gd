class_name PlayerStateBicyleKick extends PlayerState

const BICYCLE_KICK_POWER := 1.5

func _ready() -> void:
	air_connect_min_height = 5
	air_connect_max_height = 10

func _enter_tree() -> void:
	animation_player.play("bicycle_kick")
	ball_detection_area.body_entered.connect(on_ball_entered)

func on_ball_entered(connect_ball: Ball) -> void:
	if connect_ball.can_air_connect(air_connect_min_height, air_connect_max_height):
		var target_position := target_goal.get_random_target_position()
		var direction := player.position.direction_to(target_position)
		connect_ball.ball_shot(direction * player.power * BICYCLE_KICK_POWER)

func on_animation_complete() -> void:
	transition_state(Player.State.RECOVERING)