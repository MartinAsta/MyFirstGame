extends Path2D
class_name Bunny
var is_on_floor = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$AnimationPlayer.pause()
		#$frames.animation = "Jumping"
