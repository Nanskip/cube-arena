maploader = {}

maploader.loadMaps = function()
     HTTP:Get("https://raw.githubusercontent.com/Nanskipp/cube-arena/main/data/maps.json", function(res)
        if res.StatusCode ~= 200 then
            error("Error on loading maps. Code: " .. res.StatusCode)
            return
        end
        
        maps = JSON:Decode(res.Body)
    end)
end

maploader.load = function(map)
    if map ~= maps.empty and map ~= maps.grove then

    end
    for x=1, #map do
        for y=1, #map[x] do
            local block = Block(Color(255, 255, 255), Number3(x, 0, y))
            if map[x][y] == 0 then
                block.Color = Color(235, 200, 106)
            elseif map[x][y] == 1 then
                block.Color = Color(217, 183, 93)
            elseif map[x][y] == 2 then
                block.Color = Color(101, 172, 219)
            elseif map[x][y] == 3 then
                block.Color = Color(235, 200, 106)
            end
            
            local getblock = Map:GetBlock(Number3(x, 0, y))
            if getblock ~= nil then getblock:Remove() end
            Map:AddBlock(block)
        end
    end
end

return maploader