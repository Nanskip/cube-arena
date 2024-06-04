Config = {
    Items = {
        "nanskip.v", "nanskip.ca_wall", "nanskip.ca_bush"
    },
    Map = "nanskip.v"
}

start = function()
    Camera:SetParent(World)
    
    maploader.loadmaps()
end

tick = function()
    
end

Client.OnStart = function()
    ui = require("uikit")
    loadingScreen.show()
    Camera:SetParent(nil)
    githubScriptsCount = 0
    loadGitHub()
end

Client.Tick = function(dt)
    deltaTime = 62/(1/dt)
    if githubScriptsCount == loadCount then
        loadingScreen:hide()
        start()
        githubScriptsCount = nil
    elseif githubScriptsCount == nil then
        tick()
    end
end

-- load everything
loadGitHub = function()
    loadCount = 4
    
    maploader = loadFromGitHub("modules/maploader.lua", true)
    player = loadFromGitHub("modules/player.lua", true)
    joysticks = loadFromGitHub("modules/joysticks.lua", true)
    voting = loadFromGitHub("modules/voting.lua", true)
end

-- loading function
loadFromGitHub = function(url, isCode)
    url = "https://raw.githubusercontent.com/Nanskipp/cube-arena/main/" .. url
    local fileName = url:match("[^/]-$")
    loadingText.Text = "Loading: " .. fileName
    local ret = HTTP:Get(url, function(res)
        if res.StatusCode ~= 200 then
            print("Error on " .. fileName .." loading. Code: " .. res.StatusCode)
            return
        end
        local obj = load(res.Body:ToString(), nil, "bt", _ENV)

        githubScriptsCount = githubScriptsCount + 1
        if isCode then return obj() else return obj end
        end)
    return ret
end

loadingScreen = {}

loadingScreen.show = function()
    blackScreen = ui:createFrame(Color(0, 0, 0))

    blackScreen.Width = Screen.Width
    blackScreen.Height = Screen.Height

    loadingText = ui:createText("Loading: {placeholder}", Color(255, 255, 255))
    loadingText.pos.X = Screen.Width/2 - loadingText.Width/2
    loadingText.pos.Y = Screen.Height/2 - loadingText.Height/2
    loadingText.Tick = function(self)
        self.pos.X = Screen.Width/2 - self.Width/2
        self.pos.Y = Screen.Height/2 - self.Height/2
    end
end

loadingScreen.hide = function(self)
    blackScreen:setParent(nil) blackScreen = nil
    loadingText:setParent(nil) loadingText.Tick = nil loadingText = nil
    self = nil
end

Client.DidReceiveEvent = function(event)
    if event.type == "start vote" then
        voting.start(event.config)
    elseif event.type == "player voted" then
        voting.vote.buttons[event.variant].votes.Text = event.votes
    elseif event.type == "vote end" then
        voting:remove()
    end
end

Server.OnStart = function()
    currentlyVoting = false

    callVote = function()
        currentVote = {
            name = "Server vote",
            description = "This vote was called by server.",
            time = 60*10,
            variants = {
                {
                    name = "Vote variant 1",
                    image = nil,
                    votes = 0
                },
                {
                    name = "Vote variant 2",
                    image = nil,
                    votes = 0
                },
                {
                    name = "Vote variant 3",
                    image = nil,
                    votes = 0
                },
            }
        }
        
        print("Vote called.")
    end

    sendVote = function(to)
        local e = Event()
        e.type = "start vote"
        e.config = currentVote

        e:SendTo(to)
    end

    endVote = function()
        currentVote = nil
        currentlyVoting = false

        local e = Event()
        e.type = "vote end"
        e:SendTo(Players)

        print("Vote ended.")
    end
end

Server.OnPlayerJoin = function(p)
    local player = p

    if not currentlyVoting then
        currentlyVoting = true

        callVote()
    end

    Timer(0, false, function()
        sendVote(player)
        print("Vote sent to " .. player.Username)
    end)
end

Server.DidReceiveEvent = function(event)
    if event.type == "vote" then
        if event.variant ~= nil then
            local e = Event()
            e.type = "player voted"
            e.variant = event.variant
            currentVote.variants[event.variant].votes = currentVote.variants[event.variant].votes + 1
            e.votes = currentVote.variants[event.variant].votes
            e:SendTo(Players)

            print(event.Sender.Username .. " voted for variant " .. event.variant)
        end
    end
end

Server.Tick = function(dt)
    local delta = dt*62.5

    if currentVote.time ~= nil then
        currentVote.time = currentVote.time - (1*delta)
    end

    if currentlyVoting and currentVote.time < 0 then
        endVote()
    end
end