-- Healing effect for wizard
function EFFECT:Init(data)
    local pos = data:GetOrigin()
    
    self.Pos = pos
    self.LifeTime = 2
    self.DieTime = CurTime() + self.LifeTime
    
    self:CreateHealingParticles()
end

function EFFECT:CreateHealingParticles()
    local emitter = ParticleEmitter(self.Pos)
    if not emitter then return end
    
    -- Create upward floating healing particles
    for i = 1, 20 do
        local particle = emitter:Add("effects/spark", self.Pos + Vector(math.random(-30, 30), math.random(-30, 30), 0))
        if particle then
            particle:SetVelocity(Vector(math.random(-10, 10), math.random(-10, 10), math.random(50, 100)))
            particle:SetDieTime(2)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(4)
            particle:SetEndSize(0)
            particle:SetColor(0, 255, 100)
        end
    end
    
    emitter:Finish()
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    -- No additional rendering needed, particles handle the visual
end
