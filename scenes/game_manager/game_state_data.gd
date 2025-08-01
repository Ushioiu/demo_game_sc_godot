class_name GameStateData

var country_on_scored: String

static func build() -> GameStateData:
	return GameStateData.new()

func set_country_on_scored(country: String) -> GameStateData:
	country_on_scored = country
	return self
