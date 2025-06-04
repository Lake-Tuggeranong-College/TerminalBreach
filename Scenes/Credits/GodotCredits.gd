extends Node2D

const section_time := 0.5
const line_time := 0.15
const base_speed := 200
const speed_up_multiplier := 5.0
const title_color := Color.BLUE_VIOLET

# var scroll_speed := base_speed
var speed_up := false

@onready var line := $CreditsContainer/Line
var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits = [
	[
		"A game by LTC students"
	],[
		
		"Programming",
		"Atharva",
		"Alex",
		"Emmet",
		"Jordan",
		"Malakai",
		"Nadal",
		"Oscar"
	],[
		"Art and Design",
		"Jordan",
		"Malakai",
		"Nadal",
		"Oscar"
	],[
		"Music",
		"Main Title - Mega Man 11 (Produced by Marika Suzuki)",
		"Dr. Light - Mega Man 11 (Produced by Marika Suzuki)",
		"Acid Man Stage - Mega Man 11 (Produced by Marika Suzuki)",
		"Monkeys Spinning Monkeys (Produced by Kevin MacLeod)",
		"Wild Side (Produced by Toshimi Watanabe featuring ALI)"
	],[
		"Sound Effects",
		"Gunshot noise but pitched higher",
		"Stage clear noise from mega man 11",
		"eerie.ogg"
	],[
		"Testers",
		"Beta tester inni winni mc inni",
		"GURT",
		"My 2 pet cats",
		"Ethan",
		"Joseph",
		"Zac",
		"Crystal",
		"Lexy",
		"Leonard",
		"Colby",
		"Max",
		"Karen",
		"Leelah",
		"Chris",
		"Joel",
		"Tristan",
		"Leah",
		"Noah",
		"Luke",
		"Emma",
		"Mitchell",
		"Will",
		"Zoe",
		"Zayne",
		"Bryn",
		"George",
		"Joseph",
		"Jasmine",
		"Thomas",
		"Henry",
		"Blake",
		"Calvin",
		"Griffin",
		"Grant",
		"Jack",
		"Oliver"
	],[
		"Tools used",
		"Developed with Godot Engine",
		"https://godotengine.org/license",
		"",
		"Art, Textures, Map and Models created/edited with",
		"https://www.blender.org/"
	],[
		"Special thanks",
		"Ryan Cather",
		"Jacob Strachan",
		"Umair",
		"competitors"
	],[
		"Web Development",
		"Nadal"
	],[
		"Web Dev",
		"Nadal"
	],[
		"Dev Web",
		"Nadal"
	],[
		"Web Spinner",
		"Nadal"
	],[
		"Maker of web",
		"Nadal"
	],[
		"Developing web",
		"Nadal"
	],[
		"Webologist",
		"Nadal"
	],[
		"Weberfile",
		"Nadal"
	],[
		"Front-End Development",
		"Nadal"
	],[
		"Back-End Development",
		"Nadal"
	],[
		"All-Around-End Development",
		"Nadal"
	],[
		"Full-Stack Development",
		"Nadal"
	],[
		"UI/UX Development",
		"Nadal"
	],[
		"Software Engineering (Web)",
		"Nadal"
	],[
		"Web Application Development",
		"Nadal"
	],[
		"Digital Development",
		"Nadal"
	],[
		"Credit stealer",
		"Nadal"
	],[
		"Building the Front-End / Back-End / All-Around-End",
		"Nadal"
	],[
		"Coding for the Web",
		"Nadal"
	],[
		"Writing Web Apps",
		"Nadal"
	],[
		"DevOps (for infrastructure-heavy work)",
		"Nadal"
	],[
		"Cloud Web Dev",
		"Nadal"
	],[
		"Just a guy",
		"Nadal",
	],[
		"Are you",
		"Ladiesman217?",
	],[
		"Cracked at Fortnite",
		"Jebediah Sparks -- 3x FNCS Champion",
		"IeatDoritoes",
		"Dimitri Hucklebuck -- 6x FNCS Silver Medalist",
		"The Console Demon From The Hood Who's Misunderstood fortnitebeast283"
	],[
		"Thanks for playing!"]
	
]


func _process(delta):
	var scroll_speed = base_speed * delta
	
	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	
	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if speed_up:
		scroll_speed *= speed_up_multiplier
	
	if lines.size() > 0:
		for l in lines:
			l.position.y -= scroll_speed
			if l.position.y < -l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()


func finish():
	if not finished:
		finished = true
		# This is called when the credits finish and returns to the main menu
		get_tree().change_scene_to_file("res://Scenes/Worlds/main_menu.tscn")


func add_line():
	var new_line = line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if curr_line == 0:
		# new_line.add_color_override("font_color", title_color)
		new_line.set("theme_override_colors/font_color", title_color)
	$CreditsContainer.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		finish()
	if event.is_action_pressed("ui_down") and !event.is_echo():
		speed_up = true
	if event.is_action_released("ui_down") and !event.is_echo():
		speed_up = false


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Worlds/main_menu.tscn")
