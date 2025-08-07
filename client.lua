local canRespawn = false
local playerDead = false

RegisterNUICallback('canRespawn', function(data, cb)
    canRespawn = data.allowRespawn
end)

RegisterNetEvent('SpawnHandler:NoPerm', function(type)
    lib.notify({
        title = 'Permission Error',
        description  = 'You do not have permission to use ' .. type,
        type = 'error'
    })
end)

RegisterNetEvent('SpawnHandler:InvalidID', function(type)
    lib.notify({
        title = 'Spawn Handler Error',
        description  = 'Invalid Server ID',
        type = 'error'
    })
end)

local function notify(title, description, type, icon, duration)
    lib.notify({
        title = title,
        description = description,
        type = type,
        icon = icon,
        duration = duration or 3000
    })
end

-- used for respawning the character depending on if they 
local function respawnCharacter(adminInf)
    if DeathScreen.DefaultSpawns then
        canRespawn = false
        playerDead = false
        exports.spawnmanager:setAutoSpawn(true)
        Wait(500)
        exports.spawnmanager:forceRespawn()
        SendNUIMessage({ type = 'hide' })
        Wait(500)

        exports.spawnmanager:setAutoSpawn(false)

        if adminInf then
            notify('Spawn Manager', ('You have been respawned by %s'):format(adminInf), 'success')
        else
            notify('Spawn Manager', 'You have been respawned', 'success')
        end
    else
        canRespawn = false
        playerDead = false
        local spawnPoint = DeathScreen.SpawnPoints[math.random(1, #DeathScreen.SpawnPoints)]
        print(json.encode(spawnPoint))

        SendNUIMessage({ type = 'hide' })
        Wait(100)

        NetworkResurrectLocalPlayer(spawnPoint.coords.x, spawnPoint.coords.y, spawnPoint.coords.z, spawnPoint.coords.w, 0, false)

        if adminInf then
            notify('Spawn Manager', ('You have been respawned by %s at %s'):format(adminInf, spawnPoint.name), 'success')
        else
            notify('Spawn Manager', ('You have been respawned at %s'):format(spawnPoint.name), 'success')
        end
    end
end

RegisterNetEvent('SpawnHandler:Adrevved', function (adminInf)
    if source ~= 65535 then return end

    local isDead = IsEntityDead(PlayerPedId())

    if not isDead then
        return
    end

    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())

    SendNUIMessage({ type = 'hide' })
    Wait(100)
    canRespawn = false
    playerDead = false

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, 0, false)

    notify('Spawn Manager', ('You have been revived by %s'):format(adminInf), 'success')
end)

RegisterNetEvent('SpawnHandler:Respawned', function (adminInf)
    if source ~= 65535 then return end

    local isDead = IsEntityDead(PlayerPedId())

    if not isDead then
        return
    end

    respawnCharacter(adminInf)
end)

RegisterNetEvent('SpawnHandler:RespawnHandle', function(respawnTimer)
    SendNUIMessage({ type = "death", timer = respawnTimer })

    while IsEntityDead(PlayerPedId()) do
        Wait(1000)
    end

    SendNUIMessage({ type = 'hide' })
end)

local function handleDeath()
    if not playerDead then
        exports.spawnmanager:setAutoSpawn(false)
        TriggerServerEvent('SpawnHandler:PlayerDied')
        playerDead = not playerDead
    end
end

CreateThread(function()
    while true do
        local isDead = IsEntityDead(PlayerPedId())
        if isDead then
            handleDeath()
        end
        Wait(1000)
    end
end)

RegisterCommand("respawn", function(source, args, rawCommand)
    local isDead = IsEntityDead(PlayerPedId())

    if not canRespawn and isDead then
        notify('Spawn Manager', 'You cannot respawn right now.', 'error')
        return
    end

    if not canRespawn and not isDead then
        notify('Spawn Manager', 'You are not dead.', 'error')
        return
    end

    if canRespawn and isDead then
        respawnCharacter()
        return
    end

    canRespawn = false
    playerDead = false
end, false)

RegisterCommand('adrev', function(_, args, _)
    local targetId = args[1] or tostring(GetPlayerServerId(PlayerId()))
    TriggerServerEvent('SpawnHandler:AdrevPlayer', targetId)
end, false)

RegisterCommand('adres', function(_, args, _)
    local targetId = args[1] or tostring(GetPlayerServerId(PlayerId()))
    TriggerServerEvent('SpawnHandler:AdresPlayer', targetId)
end, false)

TriggerEvent('chat:addSuggestion', '/adrev', 'Admin revive any player or yourself.', {
    { name="Server ID", help="The ID that pops above their head" },
})
TriggerEvent('chat:addSuggestion', '/adres', 'Admin respawn any player or yourself.', {
    { name="Server ID", help="The ID that pops above their head" },
})
TriggerEvent('chat:addSuggestion', '/respawn', 'Respawn yourself.')