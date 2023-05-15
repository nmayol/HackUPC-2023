-- NESUS --

-- Global variables
local target = nil
local cooldowns = {0, 0, 0}
local last_shooter = 0
local last_shooter_id = -1

-- Initialize bot
function bot_init(me)
end

-- Main bot function
function bot_main(me)

    -- Update cooldowns
    for i = 1, 3 do
        if cooldowns[i] > 0 then
            cooldowns[i] = cooldowns[i] - 1
        end
    end

    local me_pos = me:pos() --en me_pos guardem la nostra posició
    --print(me:health())
    -- Find the closest visible enemy
    local closest_enemy = nil
    local min_distance = math.huge
    for _, player in ipairs(me:visible()) do
        local dist = vec.distance(me_pos, player:pos())
        if dist < min_distance and dist ~= 0 then
            min_distance = dist
            closest_enemy = player
        end
    end
    -- Set target to closest visible enemy
    local target = closest_enemy
    local visitant = target:type()
    local dist = vec.distance(me_pos, target:pos())



    -- (1) COD is active and NOT in the safe zone (safely inside the radius)
    if  me:cod():x() ~= -1 and vec.distance(me_pos,vec.new(me:cod():x(),me:cod():y())) >  19*me:cod():radius()/20 then
        me:move(me_pos:sub(vec.new(me:cod():x(),me:cod():y())):neg())
    -- (3) The nearest object is a player or the distance of a bullet is larger than 10
    elseif visitant == "player" or dist > 10 then
        local dir = target:pos():sub(me_pos)
        local salut = me:health() 
        local shooter = target:id()

        if shooter == last_shooter_id then
            last_shooter = last_shooter + 1
        else
            last_shooter = 0
            last_shooter_id = shooter
        end        
        
        --(3.1) if player has bad health run away
        if salut < 20 then
            if (cooldowns[2] == 0) then
                me:cast(1,dir:neg())
                cooldowns[2] = 200
            end
        --(3.2) if health is intermediate or someone has influenced two times in a row
        elseif (salut >= 20 and salut < 30) or last_shooter >= 2 then
            if cooldowns[3] == 0 and dist == 2 then -- atacar mele
                me:cast(2, dir)
                cooldowns[3] = 50
            elseif cooldowns[1] == 0 then -- atacat shoot
                me:cast(0, dir)
                cooldowns[1] = 60
            else    -- fugir
                me:move(dir:neg())
            end
            last_shooter = 0
        elseif dist < 50 then  -- (3.3) distance is closer than 100 attack
            if cooldowns[3] == 0 and dist == 2 then
                me:cast(2, dir)
                cooldowns[3] = 50
            elseif cooldowns[1] == 0 then
                me:cast(0, dir)
                cooldowns[1] = 60
            else
                me:move(dir:neg())
            end
        else    -- (3.4) Si no tens res a fer moures cap al centre
            if (cooldowns[2] == 0) then
                me:cast(1, me_pos:sub(vec.new(250, 250)):neg())
                cooldowns[2] = 200
            end
            
        end

    elseif dist < 10 then -- (4) cas que l'enemic es una bala i esta a poca distancia
        if (me:pos():x() < 5 or me:pos():x() > 490) or (me:pos():y() < 10 or me:pos():y() > 490) then -- (4.1) Si la bala ve pero esta a un dels limits de la pista
            if (cooldowns[2] == 0) then 
                me:move(me_pos:sub(vec.new(250, 250)):neg())
                cooldowns[2] = 200
            end
        else
            if (cooldowns[2] == 0) then -- (4.2) Si no esta  als limits del camp
                me:move(vec.new(-((target:pos():sub(me_pos)):y()), (target:pos():sub(me_pos)):x()))
                cooldowns[2] = 200
            end
        end

    end


end
