-- Death effect for wizard
function EFFECT:Init(data)
    local pos = data:GetOrigin()
    
    self.Pos = pos
    self.LifeTime = 3
    self.DieTime = CurTime() + self.LifeTime
    
    self:CreateDeathExplosion()
end

function EFFECT:CreateDeathExplosion()
    local emitter = ParticleEmitter(self.Pos)
    if not emitter then return end
    
    -- Create magical explosion particles
    for i = 1, 50 do
        local particle = emitter:Add("effects/spark", self.Pos)
        if particle then
            local vel = Vector(math.random(-200, 200), math.random(-200, 200), math.random(-100, 200))
            particle:SetVelocity(vel)
            particle:SetDieTime(math.random(1, 3))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.random(3, 8))
            particle:SetEndSize(0)
            particle:SetColor(math.random(100, 255), math.random(0, 100), math.random(100, 255))
        end
    end
    
    emitter:Finish()
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    -- No additional rendering needed
end
