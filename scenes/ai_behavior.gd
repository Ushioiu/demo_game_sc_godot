class_name AIBehavior
extends Node

const DURATION_AI_TICK_FREQUENCY := 200
const SPREAD_ASSIST_FACTOR := 0.8
const SHOT_DISTANCE := 150
const SHOT_PROBABILITY := 0.3
const TACKLE_DISTANCE := 15
const TACKLE_PROBABILITY := 0.3
const PASS_PROBABILITY := 0.5

var ball: Ball = null
var player: Player = null
var time_since_last_ai_tick: int
var opponent_detection_area: Area2D = null

func _ready() -> void:
	time_since_last_ai_tick = Time.get_ticks_msec() + randi_range(0, DURATION_AI_TICK_FREQUENCY)

func set_up(context_ball: Ball, context_player: Player, context_opponent_detection_area: Area2D) -> void:
	ball = context_ball
	player = context_player
	opponent_detection_area = context_opponent_detection_area

func process_ai() -> void:
	if Time.get_ticks_msec() - time_since_last_ai_tick > DURATION_AI_TICK_FREQUENCY:
		time_since_last_ai_tick = Time.get_ticks_msec()
		preform_ai_movent()
		preform_ai_decisions()

func preform_ai_movent() -> void:
	var total_steering_force = Vector2.ZERO
	if player.has_ball():
		total_steering_force += get_carrier_steering_force()
	elif player.role != Player.Role.GOALIE:
		total_steering_force += get_onduty_steering_force()
		if is_ball_carried_by_teammate():
			total_steering_force += get_assist_formation_steering()
	total_steering_force = total_steering_force.limit_length(1.0)
	player.velocity = player.speed * total_steering_force

func preform_ai_decisions() -> void:
	if is_ball_possessed_by_opponent() and player.position.distance_to(ball.position) < TACKLE_DISTANCE and randf() < TACKLE_PROBABILITY:
		player.switch_states(Player.State.TACKLING)
	if player == ball.carrier:
		var target := player.target_goal.get_center_target_position()
		if player.position.distance_to(target) < SHOT_DISTANCE and randf() < SHOT_PROBABILITY:
			face_towards_target_goal()
			var shot_direction := player.position.direction_to(player.target_goal.get_random_target_position())
			var data := PlayerStateData.build().set_shot_power(player.power).set_shot_direction(shot_direction)
			player.switch_states(Player.State.SHOOTING, data)
		elif has_opponents_nearby() and randf() < PASS_PROBABILITY:
			player.switch_states(Player.State.PASSING)

func get_onduty_steering_force() -> Vector2:
	return player.weight_on_duty_seteering * player.position.direction_to(ball.position)

func get_carrier_steering_force() -> Vector2:
	var target := player.target_goal.get_center_target_position()
	var direction := player.position.direction_to(target)
	var weight := get_bicircular_weight(player.position, target, 100.0, 0.0, 150.0, 1.0)
	return direction * weight

func get_assist_formation_steering() -> Vector2:
	var spawn_difference := ball.carrier.spawn_position - player.spawn_position
	var assist_destination := ball.carrier.position - spawn_difference * SPREAD_ASSIST_FACTOR
	var direction := player.position.direction_to(assist_destination)
	var weight := get_bicircular_weight(player.position, assist_destination, 30.0, 0.2, 60.0, 1.0)
	return direction * weight

func get_bicircular_weight(player_position: Vector2, center_target: Vector2, inner_circle_radius: float, inner_circle_weight: float, \
							outer_circle_radius: float, outer_circle_weight: float) -> float:
	var distance_to_center = player_position.distance_to(center_target)
	if distance_to_center > outer_circle_radius:
		return outer_circle_weight
	elif distance_to_center < inner_circle_radius:
		return inner_circle_weight
	else:
		var distance_to_inner_radius: float = distance_to_center - inner_circle_radius
		var close_range_distance := outer_circle_radius - inner_circle_radius
		return lerpf(inner_circle_weight, outer_circle_weight, distance_to_inner_radius / close_range_distance)

func is_ball_carried_by_teammate() -> bool:
	return player != ball.carrier and ball.carrier != null and ball.carrier.country == player.country

func face_towards_target_goal() -> void:
	if not player.is_facing_target_goal():
		player.heading *= -1

func is_ball_possessed_by_opponent() -> bool:
	return ball.carrier != null and ball.carrier.country != player.country

func has_opponents_nearby() -> bool:
	var players := opponent_detection_area.get_overlapping_bodies()
	return players.find_custom(func(p: Player): return p.country != player.country) > -1