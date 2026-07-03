extends Control

## About / credits page. Reached from the main menu's About button and
## after the ending cinematic finishes (see ending_scene.gd).

# Where the home button returns to.
const MAIN_MENU := "res://ui/Menu/main_menu.tscn"

func _ready() -> void:
	AudioManager.play_credit_music()
	AudioManager.wire_buttons(self)

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)
