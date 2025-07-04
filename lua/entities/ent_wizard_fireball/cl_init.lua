include("shared.lua")

function ENT:Initialize()
    -- Client-side initialization for fireball
end

function ENT:Draw()
    self:DrawModel()
    
    -- Add glowing effect
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self:GetPos(), 30, 30, Color(255, 100, 0, 200))
end

function ENT:Think()
    -- Fire particles
    if math.random(1, 3) == 1 then
        local particle = ParticleEmitter(self:GetPos())
        if particle then
            local p = particle:Add("particles/fire1", self:GetPos() + Vector(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5)))
            if p then
                p:SetVelocity(-self:GetVelocity() * 0.3 + Vector(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)))
                p:SetDieTime(0.5)
                p:SetStartAlpha(255)
                p:SetEndAlpha(0)
                p:SetStartSize(8)
                p:SetEndSize(0)
                p:SetColor(255, math.random(50, 150), 0)
            end
            particle:Finish()
        end
    end
end
