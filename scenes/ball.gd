class_name Ball
extends AnimatableBody2D

@onready var player_detection_area: Area2D = $PlayerDetectionArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ball_sprite: Sprite2D = $BallSprite
@onready var scoring_ray_cast: RayCast2D = $ScoringRayCast

@export var friction_air: float
@export var friction_ground: float

const BOUNCINESS := 0.8
const DISTANCE_HEIGHT_PASS := 130
const TUMBLE_HEIGHT_VELOCITY := 3.0
const DURATION_TUMBLE_LOCK := 200
const DURATION_PASS_LOCK := 500

enum State {CARRIED, FREEFORM, SHOT}

var carrier: Player = null
var current_state: BallState = null
var state_factory := BallStateFactory.new()
var velocity := Vector2.ZERO
var height := 0.0
var height_velocity := 0.0

func _ready():
	switch_state(State.FREEFORM)

func _process(_delta: float) -> void:
	ball_sprite.position = Vector2.UP * height
	scoring_ray_cast.rotation = velocity.angle()

func switch_state(state: Ball.State, state_data: BallStateData = BallStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, player_detection_area, carrier, animation_player, ball_sprite, state_data)
	current_state.state_transition_requested.connect(switch_state)
	current_state.name = "BallStateMachine" + str(state)
	call_deferred("add_child", current_state)
	
func ball_shot(shot_velocity: Vector2) -> void:
	velocity = shot_velocity
	carrier = null
	switch_state(State.SHOT)

func tumble(tumble_velocity: Vector2) -> void:
	velocity = tumble_velocity
	carrier = null
	height_velocity = TUMBLE_HEIGHT_VELOCITY
	switch_state(State.FREEFORM, BallStateData.build().set_lock_duration(DURATION_TUMBLE_LOCK))

func pass_to(direction_to: Vector2) -> void:
	var pass_direction := self.position.direction_to(direction_to)
	var pass_distance := self.position.distance_to(direction_to)
	var pass_velocity := sqrt(2 * pass_distance * friction_ground)
	velocity = pass_velocity * pass_direction
	if pass_distance > DISTANCE_HEIGHT_PASS:
		height_velocity = BallState.GRAVITY * pass_distance / (2 * pass_velocity)
	carrier = null
	switch_state(State.FREEFORM, BallStateData.build().set_lock_duration(DURATION_PASS_LOCK))

func stop() -> void:
	velocity = Vector2.ZERO

func is_freeform() -> bool:
	return current_state != null and current_state is BallStateFreeform

func can_air_interact() -> bool:
	return current_state != null and current_state.can_air_interact()

func can_air_connect(air_connect_min_height: float, air_connect_max_height: float) -> bool:
	return height >= air_connect_min_height and height <= air_connect_max_height # and current_state is BallStateFreeform

func is_headed_for_scoring_area(scoring_area: Area2D) -> bool:
	if not scoring_ray_cast.is_colliding():
		return false
	return scoring_ray_cast.get_collider() == scoring_area
