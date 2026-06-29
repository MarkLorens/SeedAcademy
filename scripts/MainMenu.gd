extends Control

# Scene to open when the player presses Start.
const LEVEL_SELECT := "res://ui/Menu/level_select.tscn"

@onready var play_button: Button = $CenterContainer/VBox/PlayButton
@onready var achievements_button: Button = $BottomBar/AchievementsButton
@onready var settings_button: Button = $BottomBar/SettingsButton
@onready var screenshots_button: Button = $BottomBar/ScreenshotsButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	
	# Placeholders for now — hook these up later.
	achievements_button.pressed.connect(func(): print("Achievements (TODO)"))
	settings_button.pressed.connect(func(): print("Settings (TODO)"))
	screenshots_button.pressed.connect(func(): print("Screenshots / Moments (TODO)"))

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_SELECT)
