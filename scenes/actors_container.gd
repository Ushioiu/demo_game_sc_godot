class_name ActorsContainer
extends Node2D

const PLAYER_PREFAB := preload("res://scenes/characters.tscn")

@export var ball: Ball
@export var goal_home: Goal
@export var goal_away: Goal
@export var team_home: String
@export var team_away: String

@onready var spawns: Node2D = $Spawns


func _ready() -> void:
	spawn_players(team_home, goal_home)
	spawns.scale.x = -1
	spawn_players(team_away, goal_away)

func spawn_players(team_home_country: String, own_home: Goal) -> void:
	var players := DataLoader.get_squad(team_home_country)
	var target_goal := goal_home if own_home == goal_away else goal_away
	for i in players.size():
		var player_position := spawns.get_child(i).global_position as Vector2
		var player := spawn_player(player_position, ball, own_home, target_goal, players[i] as PlayerResource)
		player.name = "Player_" + team_home_country + player.full_name
		#  TODO 临时设置控制的角色
		# ! del-begin
		if i ==4 && own_home == goal_home:
			player.control_sheme = Player.ControlScheme.P1
		# ! del-end
		add_child(player)
		
		
		

func spawn_player(context_player_position: Vector2, context_ball: Ball, context_own_goal: Goal, context_target_goal: Goal, context_player_data: PlayerResource) -> Player:
	var player: Player = PLAYER_PREFAB.instantiate()
	player.initialize(context_player_position, context_ball, context_own_goal, context_target_goal, context_player_data)
	return player
