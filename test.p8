pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
box_x = 32
box_y = 58
box_w = 64
box_h = 12

rayx = 0
rayy = 0
-- raydx = -2
-- raydy = -2
raydx = 2
raydy = -2

debug1 = "hello there"

function _init()
end

function _update()
    if btn(1) then
        rayx = rayx + 1
    elseif btn(0) then
        rayx = rayx - 1
    elseif btn(2) then
        rayy = rayy - 1
    elseif btn(3) then
        rayy = rayy + 1
    end
end

function _draw()
    local px, py = rayx, rayy
    cls()
    rect(
        box_x, 
        box_y, 
        box_x + box_w, 
        box_y + box_h,
        7)
    repeat
        pset(px, py, 8)
        px = px + raydx
        py = py + raydy
    until px < 0 or px > 127 or py < 0 or py > 127
    if deflx_ballbox(
        rayx, 
        rayy,
        raydx,
        raydy,
        box_x,
        box_y,
        box_w,
        box_h)
    then
        print("horizontal")
    else
        print("vertical")
    end
    print(debug1)
end

-- function hit_ballbox(bx, by, tx, ty, tw, th)
--     if bx + ball_r < tx then return false end
--     if by + ball_r < ty then return false end
--     if bx - ball_r > tx + tw then return false end
--     if by - ball_r > ty + th then return false end
--     return true
-- end

function deflx_ballbox(
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