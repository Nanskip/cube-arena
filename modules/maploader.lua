maploader = {}

maploader.load = function(map)
    if #map ~= #maps.empty then
        error("Invalid map.")
        
        return
    end

    if walls == nil then
        walls = Object()
        walls:SetParent(World)
    else
        for i=1, walls.ChildrenCount do
            local v = walls:GetChild(1)
            if v ~= nil then v:SetParent(nil) end
            if walls.ChildrenCount == 0 then break end
        end
    end

    if bushes == nil then
        bushes = Object()
        bushes:SetParent(World)
    else
        for i=1, bushes.ChildrenCount do
            local v = bushes:GetChild(1)
            if v ~= nil then v:SetParent(nil) end
            if bushes.ChildrenCount == 0 then break end
        end
    end

    if water == nil then
        water = Quad()
        water.Color = Color(99, 190, 242)
        water.Rotation.X = math.pi/2
        water.Scale = 5*32
        water.Position = Number3(-15*5, 0, -15*5)

        water.Tick = function(self, dt)
            if self.ticks == nil then self.ticks = 0 end
            self.ticks = self.ticks+0.01
            self.Position.Y = 4 - (math.sin(self.ticks*2)-1)/3
        end

        water:SetParent(World)
    end

    for x=1, #map do
        for y=1, #map[x] do
            local block = Block(Color(255, 255, 255), Number3(x-16, 0, y-16))
            if map[x][y][1] == 0 then
                block.Color = Color(235, 200, 106)
            elseif map[x][y][1] == 1 then
                block.Color = Color(217, 183, 93)
                wall = Shape(Items.nanskip.ca_wall)
                walls:AddChild(wall)

                wall.Position = Number3(x-16, 1, y-16)*5
                wall.Pivot = Number3(0, 0, 0)
            elseif map[x][y][1] == 2 then
                block.Color = Color(255, 255, 255, 0)
            elseif map[x][y][1] == 3 then
                block.Color = Color(235, 200, 106)

                bush = Shape(Items.nanskip.ca_bush)
                bushes:AddChild(bush)

                bush.Position = Number3(x-16, 1, y-16)*5
                bush.Pivot = Number3(0, 0, 0)
            end

            local fakex = x

            if y%2 == 1 then
                fakex = fakex+1
            end

            if fakex%2 == 0 then
                if block.Color == Color(235, 200, 106) then
                    block.Color = Color(block.Color.R + 5, block.Color.G + 5, block.Color.B + 5)
                end
            end
            
            local getblock = Map:GetBlock(Number3(x-16, 0, y-16))
            if getblock ~= nil then getblock:Remove() end
            local getblock = Map:GetBlock(Number3(x-16, 1, y-16))
            if getblock ~= nil then getblock:Remove() end
            local newBlock = Block(Color(255, 255, 255, 0), Number3(x-16, 1, y-16))
            if block.Color == Color(255, 255, 255, 0) then
                local getblock = Map:GetBlock(Number3(x-16, 1, y-16))
                Map:AddBlock(newBlock)
            end
            Map:AddBlock(block)
        end
    end
end

maploader.loadmaps = function()
    HTTP:Get("https://raw.githubusercontent.com/Nanskipp/cube-arena/main/data/maps.json", function(res)
        if res.StatusCode ~= 200 then
            error("Error on loading maps. Code: " .. res.StatusCode)
            return
        end
        
        maps = JSON:Decode(res.Body)
    end)
end

return maploader