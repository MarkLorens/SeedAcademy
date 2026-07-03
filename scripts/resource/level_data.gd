extends Resource
class_name level_data

@export var name: String
@export_file("*.tscn") var scene_path: String
@export_file("*.png") var title: String
@export_file("*.png") var graphic: String
@export_file("*.png") var complete_image_path : String
@export var progress: int
@export var locked: bool = false
@export var completed: bool = false
