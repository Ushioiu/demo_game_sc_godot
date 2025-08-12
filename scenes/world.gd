class_name World
extends Screen

@onready var game_over_timer: Timer = %GameOverTimer
@onready var actors_container: ActorsContainer = $ActorsContainer
@onready var ui: UI = $UI

func _enter_tree() -> void:
	super._enter_tree()
	GameEvents.game_over.connect(on_game_over)
	GameManager.start_game()

func _ready() -> void:
	game_over_timer.timeout.connect(on_transition)
	var player_nodes: Array[Node] = actors_container.get_children().filter(
		func(node) -> bool: return node is Player
	)
	for p_node: Player in player_nodes:
		var p_mini_colorrect := ColorRect.new()
		p_mini_colorrect.size = Vector2(2, 2)
		p_mini_colorrect.color = Color.WHITE if p_node.country == GameManager.current_match.country_home else Color.BLACK
		ui.mini_map_rect.add_child(p_mini_colorrect)
		p_node.mini_position_colorrect = p_mini_colorrect
		p_node.mini_map_rect = ui.mini_map_rect

func on_game_over(_winner_country: String) -> void:
	game_over_timer.start()

func on_transition() -> void:
	if screen_data.tournament != null and GameManager.current_match.winner == GameManager.player_setup[0]:
		screen_data.tournament.advance()
		transition_screen(SoccerGame.ScreenType.TOURNAMENT, screen_data)
	else:
		transition_screen(SoccerGame.ScreenType.MAIN_MENU)
