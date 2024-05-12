Config = {
    Map = "nanskip.v",
    Items = "nanskip.ca_bullet"
}

Modules = {
    maploader = "github.com/Nanskipp/cube-arena/modules/maploader:aed1351",
    player = "github.com/Nanskipp/cube-arena/modules/player:0eedb26",
}

Client.OnStart = function()
    loadMaps()
end

Client.Tick = function(dt)
    
end

loadMaps = function()
    HTTP:Get("https://raw.githubusercontent.com/Nanskipp/cube-arena/main/data/maps.json", function(res)
        if res.StatusCode ~= 200 then
            error("Error on loading maps. Code: " .. res.StatusCode)
            return
        end
        
        maps = JSON:Decode(res.Body)
        print(maps)
    end)
end