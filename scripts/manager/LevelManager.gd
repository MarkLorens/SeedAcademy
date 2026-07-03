extends Node

## Autoloaded level database (registered as "LevelManager" in Project Settings).
## One level_data resource per level page (see scripts/resource/level_data.gd).
## Autoload scripts can't take exported arrays from the inspector, so the
## .tres files are preloaded here.

var levels: Array[level_data] = [
	preload("res://level_tres/level_1.tres"),
	preload("res://level_tres/level_2.tres"),
	preload("res://level_tres/level_3.tres"),
]

func get_level(index: int) -> level_data:
	if index < 0 or index >= levels.size():
		return null
	return levels[index]

## Mark a level as completed: full progress, swap-ready graphic, and
## unlock the next level in the list.
func complete_level(index: int) -> void:
	var level := get_level(index)
	if level == null:
		return
	level.progress = 100
	level.completed = true

	var next := get_level(index + 1)
	if next:
		next.locked = false

func complete_level_for_scene(scene_path: String) -> void:
	complete_level(index_for_scene(scene_path))

## Record pct (0-100) for the level whose scene matches scene_path,
func save_progress_for_scene(scene_path: String, pct: float) -> void:
	var level := get_level(index_for_scene(scene_path))
	if level:
		level.progress = maxi(level.progress, clampi(int(pct), 0, 100))

## Progress (0-100) for the level whose scene matches scene_path,
func get_progress_for_scene(scene_path: String) -> float:
	var level := get_level(index_for_scene(scene_path))
	return float(level.progress) if level else -1.0

## Index of the level whose scene_path matches, or -1. Handles level_data
func index_for_scene(scene_path: String) -> int:
	if scene_path.is_empty():
		return -1
	for i in levels.size():
		if _scene_res_path(levels[i]) == scene_path:
			return i
	return -1

func _scene_res_path(level: level_data) -> String:
	var path := level.scene_path
	if path.begins_with("uid://"):
		var id := ResourceUID.text_to_id(path)
		if ResourceUID.has_id(id):
			return ResourceUID.get_id_path(id)
	return path
