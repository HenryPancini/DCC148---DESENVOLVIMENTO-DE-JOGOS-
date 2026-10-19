extends Node

@export var tilemap: TileMapLayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.visible = true
	countdown()
	born_car1()
	born_car2()
	born_car3()
	born_car4()
	born_car5()
	born_log1()
	born_log2()
	born_log3()
	born_log4()
	born_log5()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if $Frog.life<=0:
		$Frog.visible=false
		$Label.visible=true
		$Label.text="GAME OVER
		 Pressione R e Tente de Novo!"
	if $Frog.contador==5:
		$Frog.visible=false
		$Label.visible=true
		$Label.text="Parabéns! 
		Pressione R e Tente de Novo!"
		

func born_car1() -> void:
	while true:
		await get_tree().create_timer(randf_range(2,9)).timeout

		var c = $CarPool.get_from_pool()
		if c :
			c.tilemap=tilemap
			c.car_pool = $CarPool
			c.global_position = tilemap.to_global(
	tilemap.map_to_local(Vector2i(7,7)))
func born_car2() -> void:
	while true:
		await get_tree().create_timer(randf_range(2,6)).timeout

		var c = $CarPool2.get_from_pool()
		if c :
			c.tilemap=tilemap
			c.car_pool = $CarPool2
			c.global_position = tilemap.to_global(
	tilemap.map_to_local(Vector2i(-8,6))
)
func born_car3() -> void:
	while true:
		await get_tree().create_timer(randf_range(2,7)).timeout

		var c = $CarPool3.get_from_pool()
		if c :
			c.tilemap=tilemap
			c.car_pool = $CarPool3
			c.global_position = tilemap.to_global(
	tilemap.map_to_local(Vector2i(7,5))
)
func born_car4() -> void:
	while true:
		await get_tree().create_timer(randf_range(2,9)).timeout

		var c = $CarPool4.get_from_pool()
		if c :
			c.tilemap=tilemap
			c.car_pool = $CarPool4
			c.global_position = tilemap.to_global(
	tilemap.map_to_local(Vector2i(-8,4))
)
func born_car5() -> void:
	while true:
		await get_tree().create_timer(randf_range(2,4)).timeout

		var c = $CarPool5.get_from_pool()
		if c :
			c.tilemap=tilemap
			c.car_pool = $CarPool5
			c.global_position = tilemap.to_global(
	tilemap.map_to_local(Vector2i(7,3))
)
func born_log1() -> void:
	while true:
		await get_tree().create_timer(randf_range(3, 5)).timeout

		var c = $LogPool.get_from_pool()
		if c:
			c.tilemap = tilemap
			c.log_pool = $LogPool
			c.isleft = true
			c.direction = Vector2i.RIGHT
			c.speed = 0.6
			c.global_position = tilemap.to_global(
				tilemap.map_to_local(Vector2i(-9, 0))
			)


func born_log2() -> void:
	while true:
		await get_tree().create_timer(randf_range(2, 5)).timeout

		var c = $LogPool2.get_from_pool()
		if c:
			c.tilemap = tilemap
			c.log_pool = $LogPool2
			c.isleft = true
			c.direction = Vector2i.RIGHT
			c.speed = 0.6
			c.global_position = tilemap.to_global(
				tilemap.map_to_local(Vector2i(-10, -3))
			)


func born_log3() -> void:
	while true:
		await get_tree().create_timer(randf_range(3, 5)).timeout

		var c = $LogPool.get_from_pool()
		if c:
			c.tilemap = tilemap
			c.log_pool = $LogPool
			c.isleft = false
			c.direction = Vector2i.LEFT
			c.speed = 0.8
			c.global_position = tilemap.to_global(
				tilemap.map_to_local(Vector2i(9, -2))
			)


func born_log4() -> void:
	while true:
		await get_tree().create_timer(randf_range(3, 4)).timeout

		var c = $LogPool3.get_from_pool()
		if c:
			c.tilemap = tilemap
			c.log_pool = $LogPool3
			c.isleft = true
			c.direction = Vector2i.RIGHT
			c.global_position = tilemap.to_global(
				tilemap.map_to_local(Vector2i(-11, -1))
			)


func born_log5() -> void:
	while true:
		await get_tree().create_timer(randf_range(3, 6)).timeout

		var c = $LogPool2.get_from_pool()
		if c:
			c.tilemap = tilemap
			c.log_pool = $LogPool2
			c.isleft = false
			c.direction = Vector2i.LEFT
			c.speed = 0.8
			c.global_position = tilemap.to_global(
				tilemap.map_to_local(Vector2i(9, 1))
			)
func countdown() -> void:
	$Frog.accepting_commands = false
	$Label.visible = true

	for seconds in range(5, 0, -1):
		$Label.text = str(seconds)
		await get_tree().create_timer(1.0).timeout

	$Label.text = "VAI!"
	await get_tree().create_timer(0.5).timeout

	$Label.hide()
	$Frog.accepting_commands = true
