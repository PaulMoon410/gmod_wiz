function EFFECT:Init(data)
    local pos = data:GetOrigin()
    
    -- Purple burst effect
    local emitter = ParticleEmitter(pos, false)
    
    -- Explosion burst
    for i = 1, 40 do
        local particle = emitter:Add("effects/spark", pos)
        if particle then
            particle:SetVelocity(VectorRand() * 200)
            particle:SetLifeTime(0)
            particle:SetDieTime(2)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(8)
            particle:SetEndSize(1)
            particle:SetColor(128, 0, 255)
            particle:SetGravity(Vector(0, 0, -100))
            particle:SetAirResistance(10)
        end
    end
    
    -- Ground impact particles
    for i = 1, 15 do
        local particle = emitter:Add("effects/softglow", pos + Vector(math.random(-20, 20), math.random(-20, 20), 0))
        if particle then
            particle:SetVelocity(Vector(0, 0, 50))
            particle:SetLifeTime(0)
            particle:SetDieTime(1.5)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(3)
            particle:SetEndSize(20)
            particle:SetColor(180, 100, 255)
        end
    end
    
    emitter:Finish()
    
    -- Flash effect for teleport arrival
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and ply:GetPos():Distance(pos) < 300 then
            ply:ScreenFade(SCREENFADE.IN, Color(128, 0, 255, 30), 0.1, 0)
        end
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
