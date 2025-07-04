include("shared.lua")

-- Client-side rendering and effects
function ENT:Initialize()
    -- Client-side initialization
end

function ENT:Draw()
    self:DrawModel()
    
    -- Draw mana bar above wizard
    if LocalPlayer():GetPos():Distance(self:GetPos()) <= 400 then
        self:DrawManaBar()
    end
end

function ENT:DrawManaBar()
    local pos = self:GetPos() + Vector(0, 0, 80)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang.Forward(), 90)
    ang:RotateAroundAxis(ang.Right(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        -- Background
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(-50, -10, 100, 20)
        
        -- Mana bar
        local manaPercent = (self.CurrentMana or 100) / 100
        surface.SetDrawColor(50, 50, 255, 200)
        surface.DrawRect(-48, -8, 96 * manaPercent, 16)
        
        -- Border
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawOutlinedRect(-50, -10, 100, 20)
        
        -- Text
        draw.SimpleText("Mana", "DermaDefault", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

-- Particle effects
function ENT:Think()
    -- Ambient magical particles
    if math.random(1, 30) == 1 then
        local particle = ParticleEmitter(self:GetPos())
        if particle then
            local p = particle:Add("effects/spark", self:GetPos() + Vector(math.random(-20, 20), math.random(-20, 20), math.random(40, 60)))
            if p then
                p:SetVelocity(Vector(math.random(-10, 10), math.random(-10, 10), math.random(10, 30)))
                p:SetDieTime(2)
                p:SetStartAlpha(255)
                p:SetEndAlpha(0)
                p:SetStartSize(2)
                p:SetEndSize(0)
                p:SetColor(100, 100, 255)
            end
            particle:Finish()
        end
    end
end

-- Network message handling
net.Receive("wizard_mana_update", function()
    local wizard = net.ReadEntity()
    local manaPercent = net.ReadFloat()
    
    if IsValid(wizard) then
        wizard.CurrentMana = manaPercent * 100
    end
end)
