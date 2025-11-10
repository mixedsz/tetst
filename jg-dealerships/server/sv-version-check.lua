local resourceName = "jg-dealerships"
local versionCheckBaseUrl = "https://raw.githubusercontent.com/jgscripts/versions/main/"
local versionCheckUrl = versionCheckBaseUrl .. resourceName .. ".txt"

-- Function to compare version strings and determine if an update is available
local function isUpdateAvailable(currentVersion, latestVersion)
    local currentVersionParts = {}
    local latestVersionParts = {}
    
    -- Parse current version string into number parts
    for versionPart in string.gmatch(currentVersion, "[^.]+") do
        table.insert(currentVersionParts, tonumber(versionPart))
    end
    
    -- Parse latest version string into number parts
    for versionPart in string.gmatch(latestVersion, "[^.]+") do
        table.insert(latestVersionParts, tonumber(versionPart))
    end
    
    -- Compare version parts
    local maxParts = math.max(#currentVersionParts, #latestVersionParts)
    
    for i = 1, maxParts do
        local currentPart = currentVersionParts[i] or 0
        local latestPart = latestVersionParts[i] or 0
        
        if currentPart < latestPart then
            return true
        end
    end
    
    return false
end

-- Perform HTTP request to check for updates
PerformHttpRequest(versionCheckUrl, function(responseCode, responseData, responseHeaders)
    -- Check if the HTTP request was successful
    if responseCode ~= 200 then
        print("^1Unable to perform update check")
        return
    end
    
    -- Get the current version from resource metadata
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
    
    if not currentVersion then
        return
    end
    
    -- Skip version check for dev versions
    if currentVersion == "dev" then
        print("^3Using dev version")
        return
    end
    
    -- Extract the first line from response data (latest version)
    local latestVersion = responseData:match("^[^\n]+")
    
    if not latestVersion then
        return
    end
    
    -- Remove 'v' prefix from versions before comparison
    local currentVersionNumber = currentVersion:sub(2)
    local latestVersionNumber = latestVersion:sub(2)
    
    -- Check if update is available
    if isUpdateAvailable(currentVersionNumber, latestVersionNumber) then
        print("^3Update available for " .. resourceName .. "! (current: ^1" .. currentVersion .. "^3, latest: ^2" .. latestVersion .. "^3)")
        print("^3Release notes: discord.gg/jgscripts")
    end
end, "GET")

-- Function to check FXServer artifact version for known issues
local function checkArtifactVersion()
    -- Get FXServer version
    local serverVersion = GetConvar("version", "unknown")
    
    -- Extract artifact number from version string (format: v1.0.0.1234)
    local artifactNumber = string.match(serverVersion, "v%d+%.%d+%.%d+%.(%d+)")
    
    -- Perform HTTP request to check artifact status
    PerformHttpRequest("https://artifacts.jgscripts.com/check?artifact=" .. artifactNumber, function(responseCode, responseData, responseHeaders, errorData)
        -- Check for HTTP errors
        if responseCode ~= 200 or errorData then
            print("^1Could not check artifact version^0")
            return
        end
        
        if not responseData then
            return
        end
        
        -- Parse JSON response
        local artifactInfo = json.decode(responseData)
        local artifactStatus = artifactInfo.status
        
        -- Check if artifact is marked as broken
        if artifactStatus == "BROKEN" then
            print("^1WARNING: The current FXServer version you are using (artifacts version) has known issues. Please update to the latest stable artifacts: https://artifacts.jgscripts.com^0")
            print("^0Artifact version:^3", artifactNumber, "\n\n^0Known issues:^3", artifactInfo.reason, "^0")
            return
        end
    end)
end

-- Start artifact version check in a separate thread
CreateThread(function()
    checkArtifactVersion()
end)