extends Resource
class_name level_data

@export var name: String
@export_file("*.tscn") var scene_path: String
## Optional cinematic played before the level starts (it must chain to scene_path itself).
@export_file("*.tscn") var cinematic_path: String
@export_file("*.png") var title: String
@export_file("*.png") var graphic: String
@export_file("*.png") var complete_image_path : String
@export var progress: int
## Per-level art for the progress bar: the fill strip and the cap drawn at its tip.
@export_file("*.png") var progress_fill: String
@export_file("*.png") var progress_edge: String
@export var locked: bool = false
@export var completed: bool = false
