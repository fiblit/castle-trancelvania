extends Label

func _process(delta):
	set_text("FPS:"+str(OS.get_frames_per_second()))

func _ready():
	set_process(true)
