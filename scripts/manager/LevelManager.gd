extends Node

## Autoloaded level database (registered as "LevelManager" in Project Settings).
## One entry per level page. Leave "scene" empty for levels that don't exist yet.
## "title" / "graphic" are texture paths; "progress" is 0-100.

var levels: Array[Dictionary] = [
	{
		"name": "Deep Forest",
		"scene": "res://scenes/level_1.tscn",
		"title": "res://assets/menu/DeepForest.png",
		"graphic": "res://assets/menu/DeepForestGraphic2.png",
		"progress": 10.0,
	},
	{
		"name": "Level 2",
		"scene": "",
		"title": "",
		"graphic": "res://assets/menu/DeepForestGraphic1.png",
		"progress": 0.0,
	},
	{
		"name": "Level 3",
		"scene": "",
		"title": "",
		"graphic": "res://assets/menu/DeepForestGraphic1.png",
		"progress": 100.0,
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
