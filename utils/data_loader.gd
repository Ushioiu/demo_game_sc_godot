extends Node

var squads : Dictionary[String, Array]

func _init() -> void:
	var json_file := FileAccess.open("res://assets/json/squads.json", FileAccess.READ)
	if json_file == null:
		print("Error: Could not open squads.json")
	var json_str := json_file.get_as_text()
	var json := JSON.new()
	if json.parse(json_str) != OK:
		print(json.get_error_message())
	for team in json.data:
		var country_name := team["country"] as String
		var players := team["players"] as Array
		if !squads.has(country_name):
			squads.set(country_name, [])
		for player in players:
			var full_name := player["name"] as String
			var skin_color := player["skin"] as Player.SkinColor
			var role := player["role"] as Player.Role
			var speed := player["speed"] as float
			var power := player["power"] as float
			var player_res := PlayerResource.new(full_name, skin_color, role, speed, power)
			squads[country_name].append(player_res)
		assert(players.size() == 6)
	json_file.close()
		
func get_squad(country_name : String) -> Array:
	return squads[country_name] if squads.has(country_name) else []
