pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
    cls()
    mode = "start"
end

function _update60()
    if mode == "game" then
        update_game()
    elseif mode == "start" then
        update_start()
    elseif mode == "gameover"
    then
        update_gameover()
    end
end

function update_start()
    if btn(5) then
        startgame()
    end
end

function startgame()
    mode = "game"
    ball_r = 2
    
    pad_x = 52
    pad_y = 120
    pad_dx = 0
    pad_w = 24
    pad_h = 3
    pad_c = 7 --paddle color
    
    brick_w = 9
    brick_h = 4
    brick_c = 14
    buildbricks()
    --brick_y = 20
    
    lives = 3
    points = 0
    serveball()
end

function buildbricks()
    local i
    brick_x = {}
    brick_y = {}
    brick_v = {} --visibility
    for i = 1, 66 do
        add(brick_x, 
            4 
            + (i - 1)
            % 11
            * (brick_w + 2))
        add(brick_y, 
            20 
            + flr((i - 1) / 11)
            * (brick_h + 2))
        add(brick_v, true)
    end
end

function serveball()
    ball_x = 10
    ball_y = 70
    ball_dx = 1
    ball_dy = 1
end

function gameover()
    mode = "gameover"
end

function update_gameover()
    if btn(5) then
        startgame()
    end
end

function update_game()
    local btn_p = false
    local nextx
    local nexty
    local i
    
    if btn(0) then
        --left
        pad_dx = -2.5
        btn_p = true
    elseif btn(1) then
        --right
        pad_dx = 2.5
        btn_p = true
    end
    if not (btn_p) then
        pad_dx = pad_dx / 1.3
    end
    pad_x = pad_x + pad_dx
    pad_x = mid(
        0,
        pad_x,
        127 - pad_w)
    
    nextx = ball_x + ball_dx
    nexty = ball_y + ball_dy
    
    if nextx > 124 or
        nextx < 3 then
        nextx = mid(
            0,
            nextx,
            127)
        ball_dx = -ball_dx
        sfx(0)
    end
    
    if nexty < 11 then
        nexty = mid(
            0,
            nexty,
            127)
        ball_dy = -ball_dy
        sfx(0)
    end
    
    -- check if ball hit pad
    if ball_box(
        nextx,
        nexty,
        pad_x,
        pad_y,
        pad_w,
        pad_h)
    then
        -- deal with collision
        -- find out in which
        -- direction
        if deflx_ball_box(
            ball_x,
            ball_y,
            ball_dx,
            ball_dy,
            pad_x,
            pad_y,
            pad_w,
            pad_h)
        then
            ball_dx = -ball_dx
        else
            ball_dy = -ball_dy
        end
        sfx(1)
        points = points + 1
    end
    
    for i = 1, #brick_x do
        --did ball hit brick?
        if brick_v[i]
            and ball_box(
                nextx,
                nexty,
                brick_x[i],
                brick_y[i],
                brick_w,
                brick_h)
        then
            --process collision
            --find out in which
            --direction
            if deflx_ball_box(
                ball_x,
                ball_y,
                ball_dx,
                ball_dy,
                brick_x[i],
                brick_y[i],
                brick_w,
                brick_h)
            then
                ball_dx 
                = -ball_dx
            else
                ball_dy 
                = -ball_dy
            end
            sfx(3)
            brick_v[i] = false
            points = points + 10
        end
    end
    
    ball_x = nextx
    ball_y = nexty
    
    if nexty > 127 then
        sfx(2)
        lives = lives - 1
        if lives < 0 then
            gameover()
        else
            serveball()
        end
    end
end

function _draw()
    if mode == "game" then
        draw_game()
    elseif mode == "start" then
        draw_start()
    elseif mode == "gameover"
    then
        draw_gameover()
    end
end

function draw_start()
    cls()
    print(
        "pico hero breakout",
        30,
        40,
        7)
    print(
        "press ❎ to start",
        32,
        80,
        11)
end

function draw_gameover()
    --cls()
    rectfill(0, 60, 127, 75, 0)
    print(
        "game over",
        46,
        62,
        7)
    print(
        "press ❎ to restart",
        27,
        68,
        6)
end

function draw_game()
    local i
    
    cls(1)
    circfill(
        ball_x,
        ball_y,
        ball_r,
        10)
    rectfill(
        pad_x,
        pad_y,
        pad_x + pad_w,
        pad_y + pad_h,
        pad_c)
    
    --draw bricks
    for i = 1, #brick_x do

        if brick_v[i] then
            rectfill(
                brick_x[i],
                brick_y[i],
                brick_x[i] 
                + brick_w,
                brick_y[i] 
                + brick_h,
                brick_c)
        end
    end    
    
    rectfill(0, 0, 127, 7, 0)
    print(
        "lives:" .. lives,
        1,
        1,
        6)
    print("score:" .. points,
        40,
        1,
        6)
end

function ball_box(
    bx,
    by,
    box_x,
    box_y,
    box_w,
    box_h)
    
    --checks for a collision of
    --ball with a square
    if (by - ball_r)
        > (box_y + box_h)
    then
        return false
    elseif (by + ball_r)
        < box_y
    then
        return false
    elseif (bx - ball_r)
        > (box_x + box_w)
    then
        return false
    elseif (bx + ball_r)
        < box_x
    then
        return false
    end
    
    return true
end

function deflx_ball_box(
    bx,
    by,
    bdx,
    bdy,
    tx,
    ty,
    tw,
    th)
    local slp = bdy / bdx
    local cx, cy
    if bdx == 0 then
        return false
    elseif bdy == 0 then
        return true
    elseif (slp > 0)
        and (bdx > 0)
    then
        cx = tx - bx
        cy = ty - by
        return (cx > 0)
            and ((cy / cx)
            < slp)
    elseif (slp < 0)
        and (bdx > 0)
    then
        cx = tx - bx
        cy = ty + th - by
        return (cx > 0)
            and ((cy / cx)
            >= slp)
    elseif (slp > 0)
        and (bdx < 0)
    then
        cx = tx + tw - bx
        cy = ty + th - by
        return (cx < 0)
            and ((cy / cx)
            <= slp)
    else
        cx = tx + tw - bx
        cy = ty - by
        return (cx < 0)
            and ((cy / cx)
            >= slp)
    end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01010000183601836018350183301832018310300002f0002d0003a3002a000270002500022000200001c0001a000170001500013000110000f0000f0000f0000e0000d0000c0000a00009000070000500004000
010100002436013360133502433024320243100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001f0501d0501a0501705014050100500d0500a050060500305001050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003235032350323503235032350323500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
