class_name PlayerState
extends Node


@warning_ignore("unused_signal")
signal state_transition_requested(next_state: Player.State)

var player: Player = null
var animation_player: AnimationPlayer = null

func setup(context_player: Player, player_animation_player: AnimationPlayer) -> void:
	player = context_player
	animation_player = player_animation_player
