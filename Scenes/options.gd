extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Worlds/main_menu.tscn")


func _on_volume_value_changed(value: float) -> void:
	pass # Replace with function body.
	AudioServer.set_bus_volume_db(0,value)


#func _on_mute_toggled(toggled_on: bool) -> void:
	#pass # Replace with function body.


func _on_resolutions_item_selected(index: int) -> void:
	var resolution = Vector2i()
	match index:
		0:
			resolution = Vector2i(1920, 1080)
		1:
			resolution = Vector2i(1600, 900)
		2:
			resolution = Vector2i(1280, 720)

	# Set the window size
	DisplayServer.window_set_size(resolution)

	# Adjust the main viewport size
	var root = get_tree().root
	root.size = resolution

	# Save the user settings
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	file.store_line(str(index))
	file.close()

	# Provide feedback
	print("Resolution changed to: ", resolution)
