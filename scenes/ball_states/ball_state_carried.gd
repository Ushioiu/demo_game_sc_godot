class_name BallStateCarried 
extends BallState

const OFFSET_FROM_PLAYER := Vector2(10, 4)
const DRIBBLE_FREQUENCY: float = 10.0
const DRIBBLE_INTENSITY: float = 3.0

var dribble_time := 0.0

func _enter_tree() -> void:
	assert(carrier != null)

func _process(delta: float):
	var vx := 0.0
	dribble_time += delta

	if carrier.velocity != Vector2.ZERO:
		if carrier.velocity.x != 0:
			vx = cos(dribble_time * DRIBBLE_FREQUENCY) * DRIBBLE_INTENSITY
		if carrier.heading == Vector2.RIGHT:
			animation_player.play("roll")
			animation_player.advance(0)
		else:
			animation_player.play_backwards("roll")
			animation_player.advance(0)
	else :
		animation_player.play("idle")

	ball.position = carrier.position + Vector2(vx + carrier.heading.x * OFFSET_FROM_PLAYER.x, OFFSET_FROM_PLAYER.y)
