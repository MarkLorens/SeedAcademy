extends Control

func _ready() -> void:
	$CanvasLayer.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_pause() -> void:
	$CanvasLayer.visible = true
	get_tree().paused = true

func hide_pause() -> void:
	$CanvasLayer.visible = false
	get_tree().paused = false

func _on_resume_pressed() -> void:
	hide_pause()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_home_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/Menu/main_menu.tscn")
