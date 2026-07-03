extends Control

var progress: int 

func _ready() -> void:
	self.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	AudioManager.wire_buttons(self)

func show_pause() -> void:
	self.visible = true
	$"../ActionMargin".visible = false
	$"../RadialMargin".visible = false
	$"../PauseButton".visible = false
	get_tree().paused = true
	
	_refresh_progress()
	save_highest_progress()

# Pull this level's progress from the LevelManager database; keep the
# scene's exported value when the current scene isn't in it.
func _refresh_progress() -> void:
	#var pct: float = LevelManager.get_progress_for_scene(get_tree().current_scene.scene_file_path)
	progress = $"../../..".calculate_progress_percentage()
	if progress >= 0.0:
		$CenterContainer/Paper/VBoxContainer/ProgressBar.progress = progress

	# Use this level's progress bar art (see level_data).
	var data: level_data = LevelManager.get_level(
		LevelManager.index_for_scene(get_tree().current_scene.scene_file_path))
	if data:
		$CenterContainer/Paper/VBoxContainer/ProgressBar.set_level_textures(
			load(data.progress_fill) if not data.progress_fill.is_empty() else null,
			load(data.progress_edge) if not data.progress_edge.is_empty() else null)

func hide_pause() -> void:
	self.visible = false
	$"../ActionMargin".visible = true
	$"../RadialMargin".visible = true
	$"../PauseButton".visible = true
	get_tree().paused = false

func _on_resume_pressed() -> void:
	hide_pause()

# Tapping the dimmed area outside the panel (the CenterContainer catches it,
# since the Paper panel stops input over itself) resumes the game.
func _on_backdrop_gui_input(event: InputEvent) -> void:
	var pressed := (event is InputEventMouseButton) \
		or (event is InputEventScreenTouch)
	if pressed:
		accept_event()
		hide_pause()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_home_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/Menu/main_menu.tscn")

func _on_list_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/Menu/level_select.tscn")
	
func save_highest_progress() -> void:
	LevelManager.save_progress_for_scene(get_tree().current_scene.scene_file_path, progress)

func _on_settings_pressed() -> void:
	# TODO: hook up the settings screen.
	print("Settings (TODO)")
