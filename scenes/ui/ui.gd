class_name UI
extends CanvasLayer

@onready var player_label: Label = $UIContainer/ColorRect/HBoxContainer/PlayerLabel
@onready var score_label: Label = $UIContainer/ColorRect/HBoxContainer/ScoreLabel
@onready var time_label: Label = $UIContainer/ColorRect/HBoxContainer/TimeLabel
@onready var flag_textures : Array[TextureRect] = [%TextureRectHomeFlag, %TextureRectAwayFlag]
@onready var goal_score_label: Label = $UIContainer/GoalScoreLabel
@onready var score_info_label: Label = $UIContainer/ScoreInfoLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var last_ball_carrier: String = ""

func _ready() -> void:
	update_score()
	update_flags()
	update_clock()
	player_label.text = ""
	GameEvents.ball_possessed.connect(on_ball_possessed)
	GameEvents.ball_released.connect(on_ball_released)
	GameEvents.score_changed.connect(on_score_changed)
	GameEvents.team_rest.connect(on_team_rest)
	GameEvents.game_over.connect(on_game_over)

func _process(_delta: float) -> void:
	update_clock()

func update_score() -> void:
	score_label.text = ScoreHelper.get_score_text(GameManager.score)

func update_flags() -> void:
	for i in flag_textures.size():
		flag_textures[i].texture = FlagHelper.get_texture(GameManager.countries[i])

func update_clock() -> void:
	if GameManager.time_left < 0:
		time_label.modulate = Color.YELLOW
	time_label.text = TimeHelper.get_time_text(GameManager.time_left)

func on_ball_possessed(player_name: String) -> void:
	player_label.text = player_name
	last_ball_carrier = player_name

func on_ball_released() -> void:
	player_label.text = ""

func on_score_changed() -> void:
	update_score()
	if not GameManager.is_time_up():
		goal_score_label.text = "%s SCORED!" % last_ball_carrier
		score_info_label.text = ScoreHelper.get_current_score_info(GameManager.countries, GameManager.score)
		animation_player.play("goal_appear")

func on_team_rest() -> void:
	if GameManager.has_someone_scored():
		animation_player.play("goal_hide")

func on_game_over(_country_winner: String) -> void:
	score_info_label.text = ScoreHelper.get_final_score_info(GameManager.countries, GameManager.score)
	animation_player.play("game_over")
