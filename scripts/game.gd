
extends Node2D

@export var bpm: float = 128.0
var beat_duration: float
var score: int = 0
var combo: int = 0
var game_over: bool = false

# Preload scenes
var weed_scene = preload("res://scenes/weed.tscn")

@onready var flower_left: Node2D = $FlowerPotLeft
@onready var flower_top: Node2D = $FlowerPotTop
@onready var flower_right: Node2D = $FlowerPotRight
@onready var flower_bottom: Node2D = $FlowerPotBottom


@onready var audio_player: AudioStreamPlayer2D = $BackgroundMusic


# Plant health system
@export var plant_health = {
	"left": 1,
	"top": 1, 
	"right": 1,
	"bottom": 1
}
var max_plant_health: int = 4
var plant_protection_time = {
	"left": 0.0,
	"top": 0.0,
	"right": 0.0,
	"bottom": 0.0
}
var regeneration_time: float = 7.0 
# Island positions 
# left -> x: 50 , y: -100
# top  -> x: 130 , y: -170
# right -> x: 200 , y: -100
# bottom  -> x: 130 , y: -35

var island_positions = {
	"left": Vector2(50, -100),
	"top": Vector2(130, -170), 
	"right": Vector2(200, -100),
	"bottom": Vector2(130, -35)
}

# Center plant position
var center_position = Vector2(95, -100)

# Spawn points (where weeds start - in the water)
var weed_to_island_distance = 50
var spawn_positions = {
	"left": Vector2(50 - weed_to_island_distance, -100),
	"top": Vector2(130, -170 - weed_to_island_distance),
	"right": Vector2(200 + weed_to_island_distance, -100), 
	"bottom": Vector2(130, -35 + weed_to_island_distance)
}

func _ready():
	beat_duration = 60.0 / bpm
	audio_player.stream.loop = true  # Enable looping
	audio_player.play()
	
	# Update UI
	update_score()
	update_plant_display()
	
	# Start spawning weeds
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = beat_duration
	timer.timeout.connect(spawn_weed)
	timer.start()

func _process(delta):
	if game_over:
		return
	
	# Update plant protection timers and regeneration
	for direction in plant_protection_time.keys():
		if plant_health[direction] > 0:  # Only alive plants can regenerate
			plant_protection_time[direction] += delta 
			
			# Check if plant should regenerate
			if plant_protection_time[direction] >= regeneration_time and plant_health[direction] < max_plant_health:
				plant_health[direction] += 1
				plant_protection_time[direction] = 0.0
				update_plant_display()
				print(direction + " plant grew! Health: " + str(plant_health[direction]))

@onready var arrow_left: Sprite2D = $ArrowLeft
@onready var arrow_top: Sprite2D = $ArrowTop
@onready var arrow_right: Sprite2D = $ArrowRight
@onready var arrow_bottom: Sprite2D = $ArrowBottom


func _input(event):
	
	if game_over:
		return
		
	if event.is_action_pressed("ui_left"):
		hit_direction("left")
	elif event.is_action_pressed("ui_right"):
		hit_direction("right")
	elif event.is_action_pressed("ui_up"):
		hit_direction("top")
	elif event.is_action_pressed("ui_down"):
		hit_direction("bottom")

func spawn_weed():
	if game_over:
		return
		
	# Randomly choose a direction
	var directions = ["left", "top", "right", "bottom"]
	var direction = directions[randi() % directions.size()]
	
	# Create weed
	var weed = weed_scene.instantiate()
	add_child(weed)
	weed.setup(spawn_positions[direction], island_positions[direction], direction)
	weed.reached_plant.connect(_on_weed_reached_plant)




func hit_direction(direction: String):
	# Find weeds in the hit zone for this direction
	var hit_any = false
	
	for child in get_children():
		if child.has_method("is_in_hit_zone") and child.direction == direction:
			if child.is_in_hit_zone():
				child.destroy()
				score += 10
				combo += 1
				if direction == "left":
					arrow_left.frame_coords = Vector2(0,1)
					$Timer.start()
					await $Timer.timeout
					arrow_left.frame_coords = Vector2(0,0)
				elif direction == "right":
					arrow_right.frame_coords = Vector2(0,1)
					$Timer.start()
					await $Timer.timeout
					arrow_right.frame_coords = Vector2(0,0)					
				elif direction == "bottom":
					arrow_bottom.frame_coords = Vector2(0,1)
					$Timer.start()
					await $Timer.timeout
					arrow_bottom.frame_coords = Vector2(0,0)					
				elif direction == "top":
					arrow_top.frame_coords = Vector2(0,1)
					$Timer.start()
					await $Timer.timeout
					arrow_top.frame_coords = Vector2(0,0)					
										
				$AudioStreamPlayer2D.play()
				hit_any = true
				# Reset protection timer when successfully defending
				plant_protection_time[direction] = 0.0
				break
	
	if not hit_any:
		# Missed - reset combo
		$GetRidOfWeedsSound.play()
		combo = 0
		score = max(0, score - 5)
	
	update_score()

func _on_weed_reached_plant(direction: String):
	# Weed reached the plant - damage it
	if plant_health[direction] > 0:
		plant_health[direction] -= 1
		score = max(0, score - 20)
		combo = 0
		
		# Reset protection timer when plant gets hit
		plant_protection_time[direction] = 0.0
		
		update_score()
		update_plant_display()
		
		print(direction + " plant hit! Health: " + str(plant_health[direction]))
		
		# Check if all plants are dead
		check_game_over()


func check_game_over():
	var all_dead = true
	for direction in plant_health.keys():
		if plant_health[direction] > 0:
			all_dead = false
			break
	
	if all_dead:
		game_over_sequence()

func update_plant_display():
	var plant_status = ""
	for direction in ["left", "top", "right", "bottom"]:
		var health = plant_health[direction]
		var hearts = ""
		
		# Show hearts for current health
		for i in range(health):
			hearts += "♥"
		# Show empty hearts for lost health  
		for i in range(max_plant_health - health):
			hearts += "♡"
			
		plant_status += direction.capitalize() + ": " + hearts + "\n"

	$UI/PlantStatusHealth.text = plant_status

func update_score():
	$UI/ScoreLabel.text = "Score: " + str(score) + "\nCombo: " + str(combo)
 
func game_over_sequence():
	game_over = true
	audio_player.stop()
	$UI/GameOverLabel.text = "Game Over!\nAll Plants Died!\nFinal Score: " + str(score)
	$UI/GameOverLabel.visible = true
