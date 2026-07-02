extends Resource
class_name level_data

@export var name: String
@export_file("*.tscn") var scene_path: String
@export_file("*.png") var title: String
@export_file("*.png") var graphic: String
@export var progress: int
@export var default_unlocked: bool = false

var is_unlocked: bool = false
var high_score: int = 0
