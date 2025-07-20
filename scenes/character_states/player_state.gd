class_name PlayerState
extends Node

signal state_transition_requested(next_state: Player.State, state_data: PlayerStateData)

var player: Player = null
var animation_player: AnimationPlayer = null
var state_data: PlayerStateData = null
var ball: Ball = null
var teammate_detection_area: Area2D = null
var ball_detection_area: Area2D = null

func setup(context_player: Player, player_animation_player: AnimationPlayer, context_state_data: PlayerStateData, \
		context_ball: Ball, context_teammate_detection_area: Area2D, context_ball_detection_area: Area2D) -> void:
	player = context_player
	animation_player = player_animation_player
	state_data = context_state_data
	ball = context_ball
	teammate_detection_area = context_teammate_detection_area
	ball_detection_area = context_ball_detection_area

func transition_state(next_state: Player.State, next_state_data: PlayerStateData = null) -> void:
	emit_signal("state_transition_requested", next_state, next_state_data)

func on_animation_complete() -> void:
	pass
