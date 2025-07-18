class_name PlayerStateShooting extends PlayerState

func _enter_tree() -> void:
	animation_player.play("kick")