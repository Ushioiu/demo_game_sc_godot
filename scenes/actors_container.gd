class_name ActorsContainer
extends Node2D

const DURATION_WEIGHT_CACHE := 200
const PLAYER_PREFAB := preload("res://scenes/characters.tscn")

@export var ball: Ball
@export var goal_home: Goal
@export var goal_away: Goal
@export var team_home: String
@export var team_away: String

@onready var spawns: Node2D = $Spawns

var squad_home : Array[Player] = []
var squad_away : Array[Player] = []
var time_since_last_cache_refresh := Time.get_ticks_msec()

func _ready() -> void:
	squad_home = spawn_players(team_home, goal_home)
	spawns.scale.x = -1
	squad_away = spawn_players(team_away, goal_away)

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_last_cache_refresh > DURATION_WEIGHT_CACHE:
		time_since_last_cache_refresh = Time.get_ticks_msec()
		set_on_duty_weight()

func spawn_players(team_home_country: String, own_home: Goal) -> Array[Player]:
	var player_nodes: Array[Player] = []
	var players := DataLoader.get_squad(team_home_country)
	var target_goal := goal_home if own_home == goal_away else goal_away
	for i in players.size():
		var player_position := spawns.get_child(i).global_position as Vector2
		var player := spawn_player(player_position, ball, own_home, target_goal, players[i] as PlayerResource, team_home_country)
		player.name = "Player_" + player.country + "_" + player.full_name
		#  TODO 临时设置控制的角色
		# ! del-begin
		if i ==4 && own_home == goal_home:
			player.control_sheme = Player.ControlScheme.P1
		# ! del-end
		player_nodes.append(player)
		add_child(player)
	return player_nodes

func spawn_player(context_player_position: Vector2, context_ball: Ball, context_own_goal: Goal, context_target_goal: Goal, context_player_data: PlayerResource, context_country: String) -> Player:
	var player: Player = PLAYER_PREFAB.instantiate()
	player.initialize(context_player_position, context_ball, context_own_goal, context_target_goal, context_player_data, context_country)
	return player

func set_on_duty_weight() -> void:
	for squad in [squad_home, squad_away]:
		var cpu_players : Array[Player] = squad.filter(
			func(p: Player) -> bool:
				return p.control_sheme == Player.ControlScheme.CPU and p.role != Player.Role.GOALIE
		)
		cpu_players.sort_custom(
			func(p1: Player, p2: Player) -> bool:
				#  TODO 使用实时位置比较好
				return p1.spawn_position.distance_squared_to(ball.position) < p2.spawn_position.distance_squared_to(ball.position)
		)
		for i in range(cpu_players.size()):
			cpu_players[i].weight_on_duty_seteering = 1 - ease(float(i)/10.0, 0.1)
