Config = {
    Map = "nanskip.v",
    Items = "nanskip.ca_bullet"
}

Modules = {
    maploader = "github.com/Nanskipp/cube-arena/modules/maploader:2c76e58",
    player = "github.com/Nanskipp/cube-arena/modules/player:0eedb26",
}

Client.OnStart = function()
    maploader.loadMaps()
end

Client.Tick = function(dt)
    
end