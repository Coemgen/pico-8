pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
in_progress = 0
start_end_game = 1
game_over = 2

left = 0 right = 1 up = 2 down = 3
valid_moves = {left, right, up, down}

function _init()
	player = {}
	player.x = flr(rnd(120))
	player.y = flr(rnd(114) + 8)
	player.startsprite = 0
	player.endsprite = 1
	player.sprite = 0
	player.speed = 2
	player.stuck = 0
	
	enemy = {}
	enemy.x = flr(rnd(120))
	enemy.y = flr(rnd(114) + 8)
	enemy.startsprite = 4
	enemy.endsprite = 5
	enemy.sprite = 4
	enemy.speed = 1
	enemy.stuck = 0
	
	state = in_progress
	score = 0
end

function move(unit)
	unit.sprite = unit.sprite + 1
	if unit.sprite > unit.endsprite then
		unit.sprite = unit.startsprite
	end
end

function draw_unit(unit)
	spr(unit.sprite, unit.x, unit.y) 
end

function get_map_cell(unit) 
	return mget(
		flr((unit.x + 4) / 8), 
		flr((unit.y - 4) / 8)) 
end

function hit_house(unit) 
	return get_map_cell(unit) == 16 
end

function move_unit(unit, direction)
	unit.moving = false
	
	if hit_house(unit) then
		unit.stuck = unit.stuck + 1
		if unit.stuck > 4 then
			unit.stuck = 0
		else
			return
		end
	end
	
	if direction == left and
		unit.x - unit.speed > 0 then
		unit.x = unit.x - unit.speed
		unit.moving = true
	end
	if direction == right and
		unit.x + unit.speed < 120 then
		unit.x = unit.x + unit.speed
		unit.moving = true
	end
	if direction == up and
		unit.y - unit.speed > 8 then
		unit.y = unit.y - unit.speed
		unit.moving = true
	end
	if direction == down and
		unit.y + unit.speed < 120 then
		unit.y = unit.y + unit.speed
		unit.moving = true
	end
	if not unit.moving then
		unit.sprite = unit.startsprite
	else
		move(unit)
	end
end

function move_player()
	for i = 1, #valid_moves do
		if btn(valid_moves[i]) then
			move_unit(player, valid_moves[i])
		end
	end
end

function move_enemy()
	if enemy.x > player.x then
		move_unit(enemy, left)
	end
	if enemy.x < player.x then
		move_unit(enemy, right)
	end
	if enemy.y > player.y then
		move_unit(enemy, up)
	end
	if enemy.y < player.y then
		move_unit(enemy, down)
	end
	enemy.speed = enemy.speed + 0.0005
end

function distance(p0, p1)
	dx = p0.x - p1.x dy = p0.y - p1.y
	return sqrt(dx * dx + dy * dy)
end

function check_game_over()
	if
		distance(enemy, player) < 7
		and state ~= game_over
	then
		state = start_end_game
	end
end

function _update()
	move_player()
	move_enemy()
	check_game_over()
end

function _draw()
	cls()
	if state == in_progress then
		map(0, 0, 0, 8, 16, 15)
		draw_unit(player)
		draw_unit(enemy)
		score = score + 1
		print("score: " .. score)
	elseif state == start_end_game then
		sfx(0)
		state = game_over
	elseif state == game_over then
		print("\135 game over \135")
		print("your final score was: " .. score)
		print("press action to try again")
		if btn(4) then
			_init()
		end
	end
end

__gfx__
00000000000000006666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888886666666600000000aaaaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffff8fffffff86666666600000000fffffffafffffffa00000000000000000000000000000000000000000000000000000000000000000000000000000000
f0ffff0ff0ffff0f6637736600000000f1ffff1ff1ffff1f00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffff6637736600088000ffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
089999800899998066377366008888000c2222c00c2222c000000000000000000000000000000000000000000000000000000000000000000000000000000000
089999800899998066666666088888800c2222c00c2222c000000000000000000000000000000000000000000000000000000000000000000000000000000000
089999800899998066666666888888880c2222c00c2222c000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
