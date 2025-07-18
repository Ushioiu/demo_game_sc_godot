class_name Player
extends CharacterBody2D

@export var control_sheme: ControlScheme
@export var speed: float
@export var power: float
@export var ball: Ball

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var teammate_detection_area: Area2D = $TeammateDetectionArea

enum ControlScheme {CPU, P1, P2}
enum State {MOVING, TACKLING, RECOVERING, PREPPING_SHOT, SHOOTING, PASSING}

var heading := Vector2.RIGHT
var state_factory := PlayerStateFactory.new()
var current_state : PlayerState = null

func _ready() -> void:
	switch_states(State.MOVING)

func _physics_process(_delta: float) -> void:
	flip_sprites()
	move_and_slide()

func switch_states(state: State, state_data: PlayerStateData = null) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, animation_player, state_data, ball, teammate_detection_area)
	current_state.state_transition_requested.connect(switch_states)
	current_state.name = "PlayerStateMachine" + str(state)
	call_deferred("add_child", current_state)

func set_movement_animation() -> void:
	if velocity.length() > 0:
		animation_player.play("run")
	else:
		animation_player.play("idle")

func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT

func flip_sprites() -> void:
	#player_sprite.flip_h = true if heading == Vector2.LEFT else false
	if heading == Vector2.RIGHT:
		player_sprite.flip_h = false
	elif heading == Vector2.LEFT:
		player_sprite.flip_h = true

func has_ball() -> bool:
	return ball.carrier == self

func on_animation_complete() -> void:
	if current_state != null:
		current_state.on_animation_complete()
