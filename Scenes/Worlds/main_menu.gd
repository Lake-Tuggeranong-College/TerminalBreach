
extends Control

@onready var menu = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_single_player_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Worlds/spaceshipMap.tscn")
	print("pressed")


func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/options.tscn")
	menu.visible == false
	


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits/GodotCredits.tscn")
