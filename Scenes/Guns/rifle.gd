extends Node3D

signal enemy_hit

@export var damage: int = 15
@export var bullet_speed: float = 100.0
@export var fire_rate: float = 0.1  # Time between each shot
@export var ammo_capacity: int = 30
var current_ammo = ammo_capacity
var is_reloading = false

func shoot():
	if current_ammo > 0 and not is_reloading:
		var bullet = preload("res://Scenes/Player/player_bullet.tscn").instantiate()
		bullet.global_transform = $bullet_spawn.global_transform
		get_tree().root.add_child(bullet)
		current_ammo -= 1
	else:
		print("Out of Ammo! Reload needed.")

func process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()
