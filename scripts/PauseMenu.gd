extends Control

func _ready() -> void:
	self.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_pause() -> void:
	self.visible = true
	$"../ActionMargin".visible = false
	$"../RadialMargin".visible = false
	$"../PauseButton".visible = false
	get_tree().paused = true

func hide_pause() -> void:
	self.visible = false
	$"../ActionMargin".visible = true
	$"../RadialMargin".visible = true
	$"../PauseButton".visible = true
	get_tree().paused = false

func _on_resume_pressed() -> void:
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
