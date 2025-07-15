class_name Player
extends CharacterBody2D

@export var control_sheme: ControlScheme
@export var speed: float
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: Sprite2D = $PlayerSprite

enum ControlScheme {CPU, P1, P2}

var heading := Vector2.RIGHT

func _process(_delta: float) -> void:
	if control_sheme == ControlScheme.CPU:
		pass # ai movement
	else :
		handle_human_movenment()
	set_movement_animation()
	set_heading()
	flip_sprites()
	move_and_slide()

func handle_human_movenment() -> void:
	var direction := KeyUtils.get_input_vector(control_sheme)
	velocity = direction * speed # 每秒像素

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
