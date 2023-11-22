extends Node

@export var ball_scene : PackedScene # 打包球的场景 之后方便例化
var cue_ball
const Start_position = Vector2(890,340) # 白球初始位置
var ball_images := [] # 存放球的png名字的数组
# Called when the node enters the scene tree for the first time.
const MAX_POWER = 10.0

var taking_shot : bool # 判断是否发射了 发射一次之后要重置

func _ready() -> void:
	set_balls()
	generate_balls_1()
	set_cue()
	set_bounce(0.9)
	
	# 实际需要考虑的问题有 线性阻尼 摩擦力 弹力
	pass # Replace with function body.

func set_balls():
	for i in range(1,17):
		var ball_image = load(str("res://assets/ball_",i,".png")) # 更具i 调整名字
		ball_images.append(ball_image)

func generate_balls_1():
	var rows = 5 
	var dia = 36 # 每个球的直径像素
	var count = 0
	for col in range (5):
		for row in range (rows):
			var temp_ball = ball_scene.instantiate() # 生成一个球的场景
			temp_ball.position = Vector2(250+col*dia , 267+row*dia+col*dia/2)
			temp_ball.get_node("Sprite2D").texture = ball_images[count]
			count += 1
			add_child(temp_ball)
			
		rows -= 1
		
	reset_cue_ball()
 
func reset_cue_ball():
	cue_ball = ball_scene.instantiate()
	cue_ball.position = Start_position
	cue_ball.get_node("Sprite2D").texture = ball_images[15] # 设置白球的图像
	add_child(cue_ball)
	taking_shot = false # 初始设置为没有发射
	
func set_cue():
	$Cue.position = Start_position
	$Cue.rotation_degrees = 180
	
	
func set_bounce(k): # 将弹力值k传给球 
	for ball in get_children():
		if ball is RigidBody2D:
			
			var physics_material = PhysicsMaterial.new()
			# 设置物理材料的属性，例如摩擦力和弹性
			#physics_material.friction = 0.5  # 根据需要调整摩擦力
			physics_material.bounce = 0.6    # 根据需要调整弹性
			
			ball.physics_material_override = physics_material
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cue_shoot(power) -> void:
	cue_ball.apply_central_impulse(power) # 利用白球是rigidbody的特性，施加力量
 
