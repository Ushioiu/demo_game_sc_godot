class_name ScreenFactory

var screens: Dictionary

func _init() -> void:
	screens = {
		SoccerGame.ScreenType.IN_GAME: preload("res://scenes/world.tscn"),
		SoccerGame.ScreenType.MAIN_MENU: preload("res://scenes/screens/main_menu/main_menu_screen.tscn"),
		SoccerGame.ScreenType.TEAM_SELECTION: preload("res://scenes/screens/team_selection/team_selection.tscn"),
		SoccerGame.ScreenType.TOURNAMENT: preload("res://scenes/screens/tournament/tournament_screen.tscn")
	}

func get_fresh_screen(screen: SoccerGame.ScreenType) -> Screen:
	assert(screens.has(screen), "Screen type not found: " + str(screen))
	return screens[screen].instantiate()
