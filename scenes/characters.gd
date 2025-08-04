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
@onready var tackle_damage_emitter_area: Area2D = $TackleDamageEmitterArea
@onready var opponent_detection_area: Area2D = $OpponentDetectionArea
@onready var permanent_damage_emit_area: Area2D = $PermanentDamageEmitArea
@onready var goalie_hands_collider: CollisionShape2D = %GoalieHandsCollider
@onready var root_patticles: Node2D = %RootParticles
@onready var run_particles: GPUParticles2D = %RunParticles

signal swap_requested(player: Player)

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
enum State {MOVING, TACKLING, RECOVERING, PREPPING_SHOT, SHOOTING, PASSING, HEADER, VOLLEY_KICK, BICYLE_KICK, \
			CHEST_CONTROL, HURT, DIVING, CELEBRATING, MOURNING, RESETTING}
enum Role {GOALIE, DEFENSE, MIDFIELD, OFFENSE}
enum SkinColor {LIGHT, MEDIUM, DARK}

var heading := Vector2.RIGHT
var state_factory := PlayerStateFactory.new()
var ai_factory := AIFactory.new()
var current_state : PlayerState = null
var current_ai_behavior : AIBehavior = null
var height := 0.0
var height_velocity := 0.0
var full_name : String
var role : Role
var skin_color : SkinColor
var country: String
var spawn_position := Vector2.ZERO
var kickoff_position := Vector2.ZERO
var weight_on_duty_seteering := 0.0

func _ready() -> void:
	set_ai_behavior()
	set_control_texture()
	set_shader_properies()
	spawn_position = position
	permanent_damage_emit_area.monitoring = role == Role.GOALIE
	goalie_hands_collider.disabled = role != Role.GOALIE
	tackle_damage_emitter_area.body_entered.connect(on_tackle_player)
	permanent_damage_emit_area.body_entered.connect(on_tackle_player)
	GameEvents.team_scored.connect(on_team_scored)
	GameEvents.game_over.connect(on_game_over)
	var initial_position := kickoff_position if country == GameManager.countries[0] else spawn_position
	switch_states(State.RESETTING, PlayerStateData.build().set_reset_position(initial_position))

func _process(delta: float) -> void:
	flip_sprites()
	set_sprite_visibility()
	process_gravity(delta)
	move_and_slide()

func initialize(context_position: Vector2, context_kickoff_position: Vector2, context_ball: Ball, context_own_goal: Goal, context_target_goal: Goal, context_player_resource: PlayerResource, context_country: String) -> void:
	position = context_position
	kickoff_position = context_kickoff_position
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
	# add_to_group("players")

func set_shader_properies() -> void:
	var country_index := COUNTRIES.find(country)
	country_index = clampi(country_index, 0, COUNTRIES.size() - 1)
	player_sprite.material.set_shader_parameter("skin_color", skin_color)
	player_sprite.material.set_shader_parameter("team_color", country_index)

func switch_states(state: State, state_data: PlayerStateData = null) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, animation_player, state_data, ball, teammate_detection_area, ball_detection_area, own_goal, target_goal, current_ai_behavior, tackle_damage_emitter_area)
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
		tackle_damage_emitter_area.scale.x = 1
		opponent_detection_area.scale.x = 1
		root_patticles.scale.x = 1
	elif heading == Vector2.LEFT:
		player_sprite.flip_h = true
		tackle_damage_emitter_area.scale.x = -1
		opponent_detection_area.scale.x = -1
		root_patticles.scale.x = -1

func has_ball() -> bool:
	return ball.carrier == self

func is_ready_for_kickoff() -> bool:
	return current_state != null and current_state.is_ready_for_kickoff()

func set_control_texture() -> void:
	control_sprite.texture = CONTROL_SHEME_MAP[control_sheme]

func set_sprite_visibility() -> void:
	control_sprite.visible = control_sheme != ControlScheme.CPU or has_ball()
	run_particles.emitting = velocity.length() == speed

func on_animation_complete() -> void:
	if current_state != null:
		current_state.on_animation_complete()

func control_ball() -> void:
	if ball.height > BALL_CONTROL_HEIGHT_MAX:
		switch_states(State.CHEST_CONTROL)

func set_control_sheme(sheme: ControlScheme) -> void:
	control_sheme = sheme
	set_control_texture()

func set_ai_behavior() -> void:
	current_ai_behavior = ai_factory.get_ai_behavior(role)
	current_ai_behavior.set_up(ball, self, opponent_detection_area, teammate_detection_area)
	current_ai_behavior.name = "AI Behavior"
	add_child(current_ai_behavior)

func is_facing_target_goal() -> bool:
	var direction_to_target_goal := position.direction_to(target_goal.position)
	return heading.dot(direction_to_target_goal) > 0

func on_tackle_player(tackle_player: Player) -> void:
	if tackle_player != self and tackle_player == ball.carrier and tackle_player.country != country:
		tackle_player.get_hurt(position.direction_to(tackle_player.position))

func get_hurt(hurt_origin: Vector2) -> void:
	var player_state_data := PlayerStateData.build().set_hurt_direction(hurt_origin)
	switch_states(State.HURT, player_state_data)

func can_carry_ball() -> bool:
	return current_state != null and current_state.can_carry_ball()

func get_pass_request(player: Player) -> void:
	if ball.carrier == self and current_state != null and current_state.can_pass():
		switch_states(State.PASSING, PlayerStateData.build().set_pass_target(player))

func face_towards_target_goal() -> void:
	if not is_facing_target_goal():
		heading *= -1

func on_team_scored(scored_country: String) -> void:
	if country == scored_country:
		switch_states(State.MOURNING)
	else:
		switch_states(State.CELEBRATING)

func on_game_over(counter_winner: String) -> void:
	if country == counter_winner:
		switch_states(State.CELEBRATING)
	else:
		switch_states(State.MOURNING)
