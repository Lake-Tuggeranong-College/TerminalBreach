extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var spawn_radius: float = 10.0
@export var enemies_per_wave_base: int = 5
@export var wave_increment: int = 2

var current_wave: int = 0
var enemies_to_spawn: int = 0
var enemies_spawned: int = 0

var spawn_timer: Timer
var wave_label: Label3D

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(spawn_enemy)
	spawn_timer.one_shot = false
	add_child(spawn_timer)

	wave_label = Label3D.new()
	wave_label.text = "Wave: 0 | Enemies: 0"
	wave_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	wave_label.top_level = true
	wave_label.transform.origin = Vector3(0, 3, 0)  # adjust height as needed
	add_child(wave_label)

	start_next_wave()

func start_next_wave():
	current_wave += 1
	enemies_to_spawn = enemies_per_wave_base + wave_increment * (current_wave - 1)
	enemies_spawned = 0
	update_wave_label()
	spawn_timer.start()

func spawn_enemy():
	if enemies_spawned >= enemies_to_spawn:
		spawn_timer.stop()
		return

	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.global_transform.origin = get_random_position()

	get_tree().current_scene.add_child(enemy_instance)
	enemy_instance.add_to_group("enemy")

	enemies_spawned += 1
	update_wave_label()

	if enemies_spawned >= enemies_to_spawn:
		await monitor_enemies()

func monitor_enemies():
	while get_tree().get_nodes_in_group("enemy").size() > 0:
		await get_tree().create_timer(0.5).timeout
	print("Wave", current_wave, "cleared. Starting next wave...")
	await get_tree().create_timer(2.0).timeout
	start_next_wave()

func update_wave_label():
	var alive = get_tree().get_nodes_in_group("enemy").size()
	wave_label.text = "Wave: %d | Enemies: %d" % [current_wave, alive]

func get_random_position() -> Vector3:
	var random_dir = Vector3(
		randf_range(-1.0, 1.0),
		0,
		randf_range(-1.0, 1.0)
	).normalized()
	return global_transform.origin + random_dir * randf_range(0.0, spawn_radius)
