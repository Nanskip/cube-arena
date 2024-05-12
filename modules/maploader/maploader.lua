maploader = {}

maploader.load = function(map)
    if #map ~= #maps.empty then
        error("Invalid map.")
        
        return
    end
    for x=1, #map do
        for y=1, #map[x] do
            local block = Block(Color(255, 255, 255), Number3(x-16, 0, y-16))
            if map[x][y][1] == 0 then
                block.Color = Color(235, 200, 106)
            elseif map[x][y][1] == 1 then
                block.Color = Color(217, 183, 93)
            elseif map[x][y][1] == 2 then
                block.Color = Color(101, 172, 219)
            elseif map[x][y][1] == 3 then
                block.Color = Color(235, 200, 106)
            end
            
            local getblock = Map:GetBlock(Number3(x-16, 0, y-16))
            if getblock ~= nil then getblock:Remove() end
            Map:AddBlock(block)
        end
    end
end

return maploader