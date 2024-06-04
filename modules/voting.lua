voting = {}

voting.start = function(config)
    local defaultConfig = {
        name = "NIL VOTING",
        description = "Nil description.",
        time = 60*60,
        variants = {
            {
                name = "Nil variant1",
                image = nil
            },
            {
                name = "Nil variant2",
                image = nil
            },
            {
                name = "Nil variant3",
                image = nil
            },
        }
    }

    if config == nil then
        config = {}
    end

    for key, value in pairs(defaultConfig) do
        if config[key] == nil then
            config[key] = defaultConfig[key]
        end
    end
    voting.voted = false

    if not currentlyVoting then
        voting.createVote(config)
        currentlyVoting = true
    else
        voting:remove()
        voting.createVote(config)
        currentlyVoting = true
    end
end

voting.createVote = function(config)
    local ui = require("uikit")
    local scale = math.max(0.5, math.min(1920/Screen.Width, 1080/Screen.Height))

    voting.vote = Object()
    local vote = voting.vote
    vote.time = config.time
    vote.background = ui:createFrame(Color(0, 0, 0, 0.6))
    vote.background.pos = Number2(Screen.Width/2-(700/2/scale), Screen.Height-(320/scale)-Screen.SafeArea.Top-10)
    vote.background.size = Number2(700/scale, 320/scale)

    vote.name = ui:createText(config.name, Color(255, 255, 255))
    vote.name.object.Scale = Number3(2, 2, 1) / scale
    vote.name.pos = Number2(Screen.Width/2-(vote.name.Width/2), Screen.Height-Screen.SafeArea.Top-10-(vote.name.Height))

    vote.description = ui:createText(config.description, Color(200, 200, 200))
    vote.description.object.Scale = Number3(1, 1, 1)/scale
    vote.description.pos = Number2(Screen.Width/2-(vote.description.Width/2), Screen.Height-Screen.SafeArea.Top-10-vote.description.Height-vote.name.Height)

    vote.timeCounter = ui:createText(vote.time//60, Color(255, 255, 0))
    vote.timeCounter.object.Scale = Number3(1, 1, 1)/scale
    vote.timeCounter.pos = Number2(vote.background.pos.X + vote.background.Width - vote.timeCounter.Width-10/scale, vote.background.pos.Y + vote.background.Height - vote.timeCounter.Height-5/scale)

    vote.Tick = function(self, dt)
        local delta = dt*62.5
        self.time = self.time - 1*delta

        vote.timeCounter.Text = string.format("%.0f", self.time//60)
    end

    vote.buttons = {}
    for i=1, #config.variants do
        vote.buttons[i] = ui:createFrame(Color(0, 0, 0, 0.3))
        vote.buttons[i].pos = Number2(10/scale+(i-1)/scale*230+vote.background.pos.X, 10/scale+vote.background.pos.Y)
        vote.buttons[i].size = Number2(220/scale, 220/scale)
        
        vote.buttons[i].text = ui:createText(config.variants[i].name, Color(200, 200, 200))
        vote.buttons[i].text.pos = Number2(vote.buttons[i].pos.X+10/scale, vote.buttons[i].pos.Y+5/scale)
        vote.buttons[i].text.object.Scale = Number3(1, 1, 1)/scale
        vote.buttons[i].votes = ui:createText("0", Color(255, 255, 255))
        vote.buttons[i].votes.object.Scale = Number3(1.5, 1.5, 1)/scale
        vote.buttons[i].votes.pos = Number2(vote.buttons[i].pos.X+vote.buttons[i].Width-(vote.buttons[i].votes.Width+10)/scale, vote.buttons[i].pos.Y+5/scale)
        vote.buttons[i].var = i

        vote.buttons[i].onPress = function(self)
            if not voting.voted then
                voting.voted = true
                local playSound = AudioSource('button_1')
                playSound:SetParent(World)
                playSound:Play()

                local e = Event()
                e.type = "vote"
                e.variant = self.var
                e:SendTo(Server)

                for i=1, #vote.buttons do
                    vote.buttons[i].Color = Color(0, 0, 0, 0.2)
                    vote.buttons[i].onPress = nil
                end
                vote.buttons[i].Color = Color(50, 50, 50, 0.3)
            end
        end

        print("Button #"..i..' created. Name: "'..config.variants[i].name..'".')
    end
end

voting.remove = function(self)
    if self ~= voting then
        error('voting.remove() should be called with ":"!')

        return
    end

    voting.vote.background:setParent(nil)
    voting.vote.background = nil
    voting.vote.name:setParent(nil)
    voting.vote.name = nil
    voting.vote.description:setParent(nil)
    voting.vote.description = nil
    voting.vote.timeCounter:setParent(nil)
    voting.vote.timeCounter = nil

    for i=1, #voting.vote.buttons do
        voting.vote.buttons[i].text:setParent(nil)
        voting.vote.buttons[i].text = nil
        voting.vote.buttons[i].votes:setParent(nil)
        voting.vote.buttons[i].votes = nil
        voting.vote.buttons[i]:setParent(nil)
        voting.vote.buttons[i] = nil
    end
    voting.vote.buttons = nil

    voting.vote:SetParent(nil)
    voting.vote = nil
    currentlyVoting = false
end

return voting