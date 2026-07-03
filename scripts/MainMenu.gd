extends Control

# Scene to open when the player presses Play.
const LEVEL_SELECT := "res://ui/Menu/level_select.tscn"
const STATS_MENU := "res://ui/Menu/StatsMenu.tscn"
const ABOUT_MENU := "res://ui/Menu/about.tscn"

func _ready() -> void:
	AudioManager.play_menu_music()
	AudioManager.wire_buttons(self)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_SELECT)

func _on_stats_pressed() -> void:
	get_tree().change_scene_to_file(STATS_MENU)

func _on_about_pressed() -> void:
	get_tree().change_scene_to_file(ABOUT_MENU)
