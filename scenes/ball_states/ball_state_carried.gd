class_name BallStateCarried 
extends BallState

func _ready():
	assert(carrier != null)

func _process(_delta: float):
	ball.position = carrier.position
