extends RayCast3D

func _process(delta):
	if Input.is_action_just_pressed("Interact"):
		if is_colliding():
			var collider = get_collider()
			if collider.is_in_group("door"):
				print("interacted better")
		else:
			print("interacted")
