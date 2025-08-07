math.randomseed(os.time()) -- ensure that the math.random functions...

-- webhook for your discord logs.
local webhook = "https://discord.com/api/webhooks/1402944760662196295/QCLhg9qyp5EIDubhvMf_zsxXA2kM64trEbPGIuwiwXbP6HWE8Ho1UYxPB2ZHqCY8YaFd"

-- get a target players discord id.
local function getDiscordID(playerId)
    local discordId = GetPlayerIdentifierByType(playerId, 'discord')
    return discordId and discordId:gsub('discord:', '')
end

-- log the action using discord webhooking.
local function LogAction(adminInfo, target, action)
    print(adminInfo[1], adminInfo[2])

    local adminDiscordId = getDiscordID(tonumber(adminInfo[2]))
    local targetDiscordId = getDiscordID(target)

    print(adminDiscordId, targetDiscordId)
    
    local embed = {
        {
            title = ('%s - On Player'):format(action),
            description = string.format("**Moderator:**\n- Discord: <@%s> (%s)\n- Player: %s [%s]\n**Target:**\n- Discord: <@%s> (%s)\n- Player: %s [%s]\n**Type:** %s",
                        adminDiscordId, adminDiscordId, adminInfo[1], adminInfo[2],
                        targetDiscordId, targetDiscordId, GetPlayerName(target), target,
                        action
            ),
            color = 13504833, -- Red color
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        }
    }

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = 'Adrev Logs',
        avatar_url = 'https://cdn.discordapp.com/attachments/1216838045521674310/1216838045802954772/chromaroleicondiscord.png?ex=6895ae7d&is=68945cfd&hm=b7327898d58f8ae6849424a745cee736b85372bcab41e97e7c91196dfa7f376a&', -- replace with your bot avatar
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- handle adrevs on players.
RegisterNetEvent('SpawnHandler:AdrevPlayer', function(serverId)
    local src = source
    local adminName = GetPlayerName(src)

    -- if not IsPlayerAceAllowed(src, DeathScreen.AdminAce) then
    --     return
    -- end

    local targetId = tonumber(serverId)
    if not targetId then
        TriggerClientEvent('SpawnHandler:InvalidID', src)
        return
    end

    local playerSource = GetPlayerName(targetId)
    if not playerSource then
        TriggerClientEvent('SpawnHandler:InvalidID', src)
        return
    end

    local adminInf = ('%s (%s)'):format(adminName, src)

    TriggerClientEvent('SpawnHandler:Adrevved', targetId, adminInf)

    LogAction({adminName, src}, targetId, 'Adrev')
end)

-- handle admin respawns on players.
RegisterNetEvent('SpawnHandler:AdresPlayer', function(serverId)
    local src = source
    local adminName = GetPlayerName(src)

    -- if not IsPlayerAceAllowed(src, DeathScreen.AdminAce) then
    --     return
    -- end

    -- Convert to number in case it's a string
    local targetId = tonumber(serverId)
    if not targetId then
        TriggerClientEvent('SpawnHandler:InvalidID', src)
        return
    end

    local playerSource = GetPlayerName(targetId)
    print(playerSource)

    if not playerSource then
        TriggerClientEvent('SpawnHandler:InvalidID', src)
        return
    end

    local adminInf = ('%s (%s)'):format(adminName, src)

    TriggerClientEvent('SpawnHandler:Respawned', targetId, adminInf)

    LogAction({adminName, src}, targetId, 'Adres')
end)

RegisterNetEvent('SpawnHandler:PlayerDied', function()
    local src = source

    if IsPlayerAceAllowed(src, DeathScreen.DonatorAce) then
        TriggerClientEvent('SpawnHandler:RespawnHandle', src, DeathScreen.DonatorRespawnTimer)
        return
    else
        TriggerClientEvent('SpawnHandler:RespawnHandle', src, DeathScreen.DefaultRespawnTimer)
        return
    end
end)