-- Magical aura effect for wizard
function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local ent = data:GetEntity()
    
    self.Entity = ent
    self.LifeTime = 1
    self.DieTime = CurTime() + self.LifeTime
    
    if IsValid(ent) then
        self:CreateAuraParticles(pos)
    end
end

function EFFECT:CreateAuraParticles(pos)
    local emitter = ParticleEmitter(pos)
    if not emitter then return end
    
    -- Create floating magical particles around the wizard
    for i = 1, 10 do
        local particle = emitter:Add("effects/spark", pos + Vector(math.random(-40, 40), math.random(-40, 40), math.random(20, 60)))
        if particle then
            particle:SetVelocity(Vector(math.random(-20, 20), math.random(-20, 20), math.random(10, 30)))
            particle:SetDieTime(math.random(2, 4))
            particle:SetStartAlpha(150)
            particle:SetEndAlpha(0)
            particle:SetStartSize(2)
            particle:SetEndSize(0)
            particle:SetColor(100, 100, 255)
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
