extends Control

func _ready() -> void:
	$CanvasLayer.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_game_over() -> void:
	$CanvasLayer.visible = true
	get_tree().paused = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_home_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/Menu/main_menu.tscn")
