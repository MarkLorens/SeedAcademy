extends Control

# Where the home button returns to.
const MAIN_MENU := "res://ui/Menu/main_menu.tscn"

# Stat values shown on the sticky notes. Set these from your save data later.
@export var total_jumps: int = 0
@export var total_attempts: int = 0
## Total play time in seconds, shown as MM:SS.
@export var total_time_seconds: int = 0

@onready var jumps_value: Label = $CenterContainer/Paper/VBox/NotesRow/JumpsNote/Value
@onready var attempts_value: Label = $CenterContainer/Paper/VBox/NotesRow/AttemptsNote/Value
@onready var time_value: Label = $CenterContainer/Paper/VBox/NotesRow/TimeNote/Value

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	jumps_value.text = str(total_jumps)
	attempts_value.text = str(total_attempts)
	time_value.text = "%d:%02d" % [total_time_seconds / 60, total_time_seconds % 60]

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)
