function EFFECT:Init(data)
    local pos = data:GetOrigin()
    
    -- Purple swirl effect
    local emitter = ParticleEmitter(pos, false)
    
    for i = 1, 30 do
        local particle = emitter:Add("effects/spark", pos + VectorRand() * 50)
        if particle then
            particle:SetVelocity(VectorRand() * 100)
            particle:SetLifeTime(0)
            particle:SetDieTime(1.5)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(5)
            particle:SetEndSize(0)
            particle:SetColor(128, 0, 255)
            particle:SetGravity(Vector(0, 0, -50))
            particle:SetAirResistance(5)
        end
    end
    
    -- Ring particles
    for i = 1, 20 do
        local angle = (i / 20) * 360
        local ringPos = pos + Vector(math.cos(math.rad(angle)) * 30, math.sin(math.rad(angle)) * 30, 0)
        
        local particle = emitter:Add("effects/softglow", ringPos)
        if particle then
            particle:SetVelocity(Vector(0, 0, 100))
            particle:SetLifeTime(0)
            particle:SetDieTime(1)
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(8)
            particle:SetEndSize(15)
            particle:SetColor(128, 0, 255)
        end
    end
    
    emitter:Finish()
    
    -- Screen shake for nearby players
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and ply:GetPos():Distance(pos) < 400 then
            ply:ScreenFade(SCREENFADE.IN, Color(128, 0, 255, 50), 0.2, 0)
        end
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
