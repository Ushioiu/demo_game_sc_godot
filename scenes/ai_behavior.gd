class_name AIBehavior
extends Node

const DURATION_AI_TICK_FREQUENCY := 200

var ball : Ball = null
var player : Player = null
var time_since_last_ai_tick : int

func _ready() -> void:
	time_since_last_ai_tick = Time.get_ticks_msec() + randi_range(0, DURATION_AI_TICK_FREQUENCY)

func set_up(context_ball : Ball, context_player : Player) -> void:
	ball = context_ball
	player = context_player

func process_ai() -> void:
	if Time.get_ticks_msec() - time_since_last_ai_tick > DURATION_AI_TICK_FREQUENCY:
		time_since_last_ai_tick = Time.get_ticks_msec()
		preform_ai_movent()
		preform_ai_decisions()

func preform_ai_movent() -> void:
	# var total_steering_force = Vector2.ZERO
	# total_steering_force += get_onduty_steering_force()
	# total_steering_force = total_steering_force.limit_length(1.0)
	player.velocity = player.speed * get_onduty_steering_force().limit_length(1.0)

func preform_ai_decisions() -> void:
	pass

func get_onduty_steering_force() -> Vector2:
	return player.weight_on_duty_seteering * player.position.direction_to(ball.position)
