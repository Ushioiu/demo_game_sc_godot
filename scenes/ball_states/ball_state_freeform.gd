class_name BallStateFreeform extends BallState

func _ready():
	player_detection_area.body_entered.connect(on_player_enter)

func on_player_enter(body: Player) -> void:
	ball.carrier = body
	state_transition_requested.emit(Ball.State.CARRIED)