class_name PlayerStateHeader extends PlayerState

const BONUS_POWER := 1.3
const HEIGHT_START := 0.1
const HEIGHT_VELOCITY := 1.5

func _enter_tree() -> void:
	animation_player.play("header")
	player.height = HEIGHT_START
	player.height_velocity = HEIGHT_VELOCITY
	ball_detection_area.body_entered.connect(on_ball_entered)
	
func _process(_delta: float) -> void:
	if player.height == 0:
		transition_state(Player.State.RECOVERING)

func on_ball_entered(connect_ball: Ball) -> void:
	if connect_ball.can_air_connect():
		connect_ball.ball_shot(player.velocity.normalized() * player.power * BONUS_POWER)
