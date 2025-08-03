extends Node2D

signal reached_plant(direction: String)

var direction: String = ""
var target_position: Vector2
var travel_time: float = 5.0
var hit_zone_distance: float = 60.0  # Distance from target where it can be hit
var is_destroyed: bool = false

func setup(start_pos: Vector2, target_pos: Vector2, dir: String):
	position = start_pos
	target_position = target_pos
	direction = dir
	
	move_to_center()

func move_to_center():
	# First move to island
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, travel_time * 0.7)
	tween.finished.connect(move_to_plant)

func move_to_plant():
	if is_destroyed:
		return
		
	# Then move to center plant2
	var center_pos = Vector2(95, -100)  # Adjust to match your center
	var tween = create_tween()
	tween.tween_property(self, "position", center_pos, travel_time * 0.3)
	tween.finished.connect(attack_plant)

func attack_plant():
	if is_destroyed:
		return
		
	reached_plant.emit(direction)
	queue_free()

func is_in_hit_zone() -> bool:
	# Check if weed is close enough to its target island to be hit
	var distance_to_target = position.distance_to(target_position)
	return distance_to_target <= hit_zone_distance

func destroy():
	if is_destroyed:
		return
		
	is_destroyed = true
	
	# Visual destruction effect
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	tween.finished.connect(func(): queue_free())
	
	# Optional: Add particle effect or sound here
