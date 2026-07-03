extends Control

const LEVEL_SELECT := "res://ui/Menu/level_select.tscn"

@onready var attempts_value: Label = $CenterContainer/Paper/VBox/StatsRow/AttemptsBox/Value
@onready var time_value: Label = $CenterContainer/Paper/VBox/StatsRow/TimeBox/Value

func _ready() -> void:
	self.visible = false
	# Keep working while the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	AudioManager.wire_buttons(self)

# Called by LevelSceneManager when the player reaches the end checkpoint.
func show_level_complete(attempts: int, time_seconds: int) -> void:
	attempts_value.text = "Attempts: %d" % attempts
	var mins: int = int(time_seconds / 60.0)
	var secs: int = time_seconds % 60
	time_value.text = "Time : %d:%02d" % [mins, secs]

	$"../ActionMargin".visible = false
	$"../RadialMargin".visible = false
	$"../PauseButton".visible = false

	# Fade the menu in, then pause the game once it's fully visible.
	modulate.a = 0.0
	self.visible = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.finished.connect(func(): get_tree().paused = true)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_list_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(LEVEL_SELECT)

func _on_next_pressed() -> void:
	get_tree().paused = false
	var next_scene := _next_level_scene()
	if next_scene.is_empty():
		# No next level yet — fall back to the level list.
		get_tree().change_scene_to_file(LEVEL_SELECT)
	else:
		get_tree().change_scene_to_file(next_scene)

# Path of the next level in the LevelManager database that has a scene,
# or "" when there is none after the current one.
func _next_level_scene() -> String:
	var i := LevelManager.index_for_scene(get_tree().current_scene.scene_file_path)
	if i < 0:
		return ""
	for j in range(i + 1, LevelManager.levels.size()):
		var next: level_data = LevelManager.levels[j]
		if not next.scene_path.is_empty():
			return next.scene_path
	return ""
