class_name Player
extends CharacterBody2D

@export var control_sheme: ControlScheme
@export var speed: float
@export var power: float
@export var ball: Ball
@export var own_goal: Goal
@export var target_goal: Goal

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
const BALL_CONTROL_HEIGHT_MAX := 10.0
const GRAVITY := 8.0
const COUNTRIES = ["DEFAULT", "FRANCE", "ARGENTINA", "BRAZIL", "ENGLAND", "GERMANY", "ITALY", "SPAIN", "USA", "CANADA"]
const WALK_ANIN_THRESHOLD := 0.6

enum ControlScheme {CPU, P1, P2}
enum State {MOVING, TACKLING, RECOVERING, PREPPING_SHOT, SHOOTING, PASSING, HEADER, VOLLEY_KICK, BICYLE_KICK, CHEST_CONTROL}
enum Role {GOALIE, DEFENSE, MIDFIELD, OFFENSE}
enum SkinColor {LIGHT, MEDIUM, DARK}

var heading := Vector2.RIGHT
var state_factory := PlayerStateFactory.new()
var current_state : PlayerState = null
var height := 0.0
var height_velocity := 0.0
var full_name : String
var role : Role
var skin_color : SkinColor
var country: String
var ai_behavior := AIBehavior.new()
var spawn_position := Vector2.ZERO
var weight_on_duty_seteering := 0.0

func _ready() -> void:
	switch_states(State.MOVING)
	set_control_texture()
	set_shader_properies()
	set_ai_behavior()
	spawn_position = position

func _process(delta: float) -> void:
	flip_sprites()
	set_sprite_visibility()
	process_gravity(delta)
	move_and_slide()

func initialize(context_position: Vector2, context_ball: Ball, context_own_goal: Goal, context_target_goal: Goal, context_player_resource: PlayerResource, context_country: String) -> void:
	position = context_position
	ball = context_ball
	own_goal = context_own_goal
	target_goal = context_target_goal
	speed = context_player_resource.speed
	power = context_player_resource.power
	full_name = context_player_resource.full_name
	role = context_player_resource.role
	skin_color = context_player_resource.skin_color
	country = context_country
	heading = Vector2.LEFT if target_goal.position.x < position.x else Vector2.RIGHT

func set_shader_properies() -> void:
	var country_index := COUNTRIES.find(country)
	country_index = clampi(country_index, 0, COUNTRIES.size() - 1)
	player_sprite.material.set_shader_parameter("skin_color", skin_color)
	player_sprite.material.set_shader_parameter("team_color", country_index)

func switch_states(state: State, state_data: PlayerStateData = null) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, animation_player, state_data, ball, teammate_detection_area, ball_detection_area, own_goal, target_goal, ai_behavior)
	current_state.state_transition_requested.connect(switch_states)
	current_state.name = "PlayerStateMachine" + str(state)
	call_deferred("add_child", current_state)

func set_movement_animation() -> void:
	var vel_len = velocity.length()
	if vel_len < 1:
		animation_player.play("idle")
	elif vel_len < WALK_ANIN_THRESHOLD * speed:
		animation_player.play("walk")
	else:
		animation_player.play("run")

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

func control_ball() -> void:
	if ball.height > BALL_CONTROL_HEIGHT_MAX:
		switch_states(State.CHEST_CONTROL)

func set_ai_behavior() -> void:
	ai_behavior.set_up(ball, self)
	ai_behavior.name = "AI Behavior"
	add_child(ai_behavior)
