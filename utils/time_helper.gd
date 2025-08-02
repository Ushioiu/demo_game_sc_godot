class_name TimeHelper

static func get_time_text(time_left: float) -> String:
	if time_left < 0:
		return "GAME OVER"
	else:
		var minutes := int(time_left / 60.0)
		var sec := time_left - minutes * 60.0
		return "%02d : %02d" % [minutes, sec]