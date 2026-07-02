extends Control

# Scene to open when the player presses Play.
const LEVEL_SELECT := "res://ui/Menu/level_select.tscn"
const STATS_MENU := "res://ui/Menu/StatsMenu.tscn"

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_SELECT)

func _on_stats_pressed() -> void:
	get_tree().change_scene_to_file(STATS_MENU)

func _on_about_pressed() -> void:
	# TODO: hook up the about screen.
	print("About (TODO)")
