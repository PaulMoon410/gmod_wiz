-- Lightning effect for wizard
function EFFECT:Init(data)
    local startPos = data:GetStart()
    local endPos = data:GetOrigin()
    
    self.StartPos = startPos
    self.EndPos = endPos
    self.LifeTime = 0.5
    self.DieTime = CurTime() + self.LifeTime
    
    -- Create lightning beam
    self:CreateLightningBeam()
end

function EFFECT:CreateLightningBeam()
    local emitter = ParticleEmitter(self.StartPos)
    if not emitter then return end
    
    local direction = (self.EndPos - self.StartPos):GetNormalized()
    local distance = self.StartPos:Distance(self.EndPos)
    local segments = math.floor(distance / 20)
    
    for i = 0, segments do
        local pos = self.StartPos + direction * (distance * (i / segments))
        
        -- Add some randomness to make it look like lightning
        if i > 0 and i < segments then
            pos = pos + Vector(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
        end
        
        local particle = emitter:Add("effects/spark", pos)
        if particle then
            particle:SetVelocity(Vector(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50)))
            particle:SetDieTime(0.3)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(3)
            particle:SetEndSize(0)
            particle:SetColor(150, 150, 255)
        end
    end
    
    emitter:Finish()
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    if CurTime() > self.DieTime then return end
    
    -- Draw lightning bolt
    render.SetMaterial(Material("effects/laser1"))
    render.DrawBeam(self.StartPos, self.EndPos, 5, 0, 1, Color(200, 200, 255, 255))
end
