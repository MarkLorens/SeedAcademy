extends Node

## Autoloaded level database (registered as "LevelManager" in Project Settings).
## One entry per level page. Leave "scene" empty for levels that don't exist yet.
## "title" / "graphic" are texture paths; "progress" is 0-100.

# Set right before a death-restart so the reloaded level skips the intro
# dialogue. LevelSceneManager consumes (and resets) it in new_game().
var skip_next_intro := false

@export var levels: Array[Dictionary] = [
	{
		"name": "Meadow",
		"scene": "res://scenes/level_1.tscn",
		"title": "res://assets/Level List/Meadow.png",
		"graphic": "res://assets/Level List/Graphic_Meadow.png",
		"progress": 0.0,
	},
	{
		"name": "Deep Forest",
		"scene": "",
		"title": "res://assets/Level List/Deep Forest.png",
		"graphic": "res://assets/Level List/Graphic_Forest.png",
		"progress": 0.0,
	},
	{
		"name": "Mountain",
		"scene": "",
		"title": "res://assets/Level List/Meadow.png",
		"graphic": "res://assets/Level List/Graphic_Mountain.png",
		"progress": 0.0,
	},
]

func get_level(index: int) -> Dictionary:
	if index < 0 or index >= levels.size():
		return {}
	return levels[index]

func set_progress(index: int, pct: float) -> void:
	if index < 0 or index >= levels.size():
		return
	levels[index]["progress"] = clampf(pct, 0.0, 100.0)

## Progress (0-100) for the level whose "scene" matches scene_path,
## or -1.0 when the scene isn't in the database.
func get_progress_for_scene(scene_path: String) -> float:
	if scene_path.is_empty():
		return -1.0
	for level in levels:
		if str(level.get("scene", "")) == scene_path:
			return float(level.get("progress", 0.0))
	return -1.0
