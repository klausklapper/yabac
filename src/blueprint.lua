require 'src.math'

Blueprint = Class {}

function Blueprint:init(building)
    self.building = building
    self.x = 0
    self.y = 0
    self.canBuild = false
end

function Blueprint:create()
    if resourceManager:payCost(self.building) then
        love.audio.play(sndClick)
        local b = Class.clone(self.building)
        if self.building.production then b.production = Class.clone(self.building.production) end
        b.x = self.x
        b.y = self.y
        return b
    else
        love.audio.play(sndDenied)
    end
end

function Blueprint:update(dt)
    local mx, my = cameraManager:getCamera():mousePosition()

    self.x = (math.floor(mx/16) )*16
    self.y = (math.floor(my/16) )*16

    self.x = math:clamp(0, self.x, world.size.x * 16)
    self.y = math:clamp(0, self.y, world.size.y * 16)

    if world.terrainInfo[self.x/16][self.y/16] == 1 then self.canBuild = true else self.canBuild = false end
    for k,v in pairs(buildingManager.buildings) do
        if v.x == self.x and v.y == self.y then 
            self.canBuild = false
            break
        end
    end
end

function Blueprint:draw()
    cameraManager:attach()
    if self.canBuild and self:canAfford() then love.graphics.setColor(0, 255, 0, 127) else love.graphics.setColor(255, 0, 0, 127) end
    love.graphics.draw(self.building.gfx, self.x, self.y)
    love.graphics.setColor(255, 255, 255, 255)
    cameraManager:detach()
end

function Blueprint:canAfford()
    if not self.building.cost then return true else return resourceManager:hasResource(self.building.cost) end
end