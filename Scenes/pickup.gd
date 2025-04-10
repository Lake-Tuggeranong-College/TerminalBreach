extends Node3D





# Called when the node enters the scene tree for the first time.
func _ready():
	float_object_up()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func float_object_up():
	var tween = create_tween()
	tween.tween_property(self, "position", position +Vector3(0,0.5,0), 2).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(float_object_down)

func float_object_down():
	var tween = create_tween()
	tween.tween_property(self, "position", position +Vector3(0,-0.5,0), 2).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(float_object_up)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("pickup"):
		#print("player collide")
		body.pickup()
		queue_free()
