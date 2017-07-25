extends Node

var current_scene = null

# Called on AutoLoad
func _ready():
	var root = get_tree().get_root()
	var last_scene = root.get_child_count() - 1
	current_scene = root.get_child(last_scene)

# For a simple scene transition call SceneTree.change_scene(path), this is for
# custom/controlled transitions.
func goto_scene(path):
	# from godot docs (v2.1): /step_by_step/singletons_autoload.html
	print("goto scene: ", path)
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	# Immediately free. There is no risk here.
	current_scene.free()
	# Load new scene
	var new_scene = ResourceLoader.load(path)
	current_scene = new_scene.instance()
	# Add it to active scene
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene) #For SceneTree API
	
