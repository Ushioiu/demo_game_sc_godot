class_name Ball
extends AnimatableBody2D

@onready var player_detection_area: Area2D = $PlayerDetectionArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ball_sprite: Sprite2D = $BallSprite

enum State {CARRIED, FREEFORM, SHOT}

var carrier: Player = null
var current_state: BallState = null
var state_factory := BallStateFactory.new()
var velocity := Vector2.ZERO
var height := 0.0

func _ready():
	switch_state(State.FREEFORM)

func _process(_delta: float) -> void:
	ball_sprite.position = Vector2.UP * height

func switch_state(state: Ball.State) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, player_detection_area, carrier, animation_player, ball_sprite)
	current_state.state_transition_requested.connect(switch_state)
	current_state.name = "BallStateMachine" + str(state)
	call_deferred("add_child", current_state)
	
func ball_shot(shot_velocity: Vector2) -> void:
	velocity = shot_velocity
	carrier = null
	switch_state(State.SHOT)
