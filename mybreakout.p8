pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
ball_x = 1
ball_y = 1
ball_dx = 2
ball_dy = 2

ball_r = 2

pad_x = 52
pad_y = 120
pad_dx = 0
pad_w = 24
pad_h = 3

function _init()
    cls()
end

function _update()
    local btn_press = false
    if btn(0) then
        --move paddle left
        pad_dx = -5
        btn_press = true
    elseif btn(1) then
        --move paddle right
        pad_dx = 5
        btn_press = true
    end
    if not(btn_press) then
        pad_dx = pad_dx / 1.7
    end
    pad_x = pad_x + pad_dx
        
    ball_x = ball_x + ball_dx
    ball_y = ball_y + ball_dy
    
    if ball_x > 127
        or ball_x < 0 
    then
        ball_dx = -ball_dx
        sfx(0)
    end
    if ball_y > 127
        or ball_y < 0 
    then
        ball_dy = -ball_dy
        sfx(0)
    end

end

function _draw()
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
        7)
end
__sfx__
00010000183601836018350183301832018310183002230022300250002000019000120000e000090000600005000040000400004000040000400004000040000400005000070000c000140001f000270002a000
