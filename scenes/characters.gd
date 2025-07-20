class_name Player
extends CharacterBody2D

@export var control_sheme: ControlScheme
@export var speed: float
@export var power: float
@export var ball: Ball

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var teammate_detection_area: Area2D = $TeammateDetectionArea
@onready var control_sprite: Sprite2D = $PlayerSprite/ControlSprite
@onready var ball_detection_area: Area2D = $BallDetectionArea

const CONTROL_SHEME_MAP: Dictionary = {
	ControlScheme.CPU: preload("res://assets/art/props/cpu.png"),
	ControlScheme.P1: preload("res://assets/art/props/1p.png"),
	ControlScheme.P2: preload("res://assets/art/props/2p.png")
}

const GRAVITY := 8.0

enum ControlScheme {CPU, P1, P2}
enum State {MOVING, TACKLING, RECOVERING, PREPPING_SHOT, SHOOTING, PASSING, HEADER, VOLLEY_KICK, BICYLE_KICK}

var heading := Vector2.RIGHT
var state_factory := PlayerStateFactory.new()
var current_state : PlayerState = null
var height := 0.0
var height_velocity := 0.0

func _ready() -> void:
	switch_states(State.MOVING)
	set_control_texture()

func _process(delta: float) -> void:
	flip_sprites()
	set_sprite_visibility()
	process_gravity(delta)
	move_and_slide()

func switch_states(state: State, state_data: PlayerStateData = null) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, animation_player, state_data, ball, teammate_detection_area, ball_detection_area)
	current_state.state_transition_requested.connect(switch_states)
	current_state.name = "PlayerStateMachine" + str(state)
	call_deferred("add_child", current_state)

func set_movement_animation() -> void:
	if velocity.length() > 0:
		animation_player.play("run")
	else:
		animation_player.play("idle")

func process_gravity(delta: float) -> void:
	if height > 0:
		height_velocity -= GRAVITY * delta
		height += height_velocity * delta
		if height < 0:
			height = 0
	player_sprite.position = Vector2.UP * height

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

func set_control_texture() -> void:
	control_sprite.texture = CONTROL_SHEME_MAP[control_sheme]

func set_sprite_visibility() -> void:
	control_sprite.visible = control_sheme != ControlScheme.CPU or has_ball()

func on_animation_complete() -> void:
	if current_state != null:
		current_state.on_animation_complete()
