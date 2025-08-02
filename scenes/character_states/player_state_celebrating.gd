class_name PlayerStateCelebrating extends PlayerState

const CELEBRTAING_HEIGHT := 2.0
const AIR_FRICTION := 35.0

func _enter_tree() -> void:
	celebrate()
	GameEvents.team_rest.connect(on_team_rest)

func _process(delta: float) -> void:
	if player.height == 0:
		celebrate()
	player.velocity = player.velocity.move_toward(Vector2.ZERO, delta * AIR_FRICTION)

func celebrate() -> void:
	animation_player.play("celebrate")
	player.height = 0.1
	player.height_velocity = CELEBRTAING_HEIGHT

func on_team_rest() -> void:
	transition_state(Player.State.RESETTING, PlayerStateData.build().set_reset_position(player.spawn_position))
