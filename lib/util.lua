local util = {}

local http = require("http")
local json = require("json")

function util:fetch_versions()
    local resp, err = http.get({
        url = "https://raw.githubusercontent.com/leoli0605/json-gcc-arm-none-eabi/main/versions.json"
    })
    if err ~= nil or resp.status_code ~= 200 then
        return {}
    end
    local body = json.decode(resp.body)
    local result = {}

    for label, data in pairs(body) do
        for v, next_data in pairs(data) do
            for platform, detail in pairs(next_data) do
                local str = ""
                if RUNTIME.osType == "windows" then
                    str = "win32_x86_64"
                elseif RUNTIME.osType == "linux" then
                    if RUNTIME.archType == "amd64" then
                        str = "linux_x86_64"
                    else
                        str = "linux_arm64"
                    end
                elseif RUNTIME.osType == "darwin" then
                    if RUNTIME.archType == "amd64" then
                        str = "darwin_x86_64"
                    else
                        str = "darwin_arm64"
                    end
                end
                if platform == str then
                    table.insert(result, {
                        label = label,
                        version = v,
                        url = detail.url,
                        md5 = detail.md5,
                    })
                end
            end
        end
    end

    table.sort(result, function(a, b)
        return a.label > b.label
    end)
    return result
end

function util:fetchAvailable()
    local result = util:fetch_versions()
    local versions = {}
    for i, v in ipairs(result) do
        table.insert(versions, {
            version = v.version,
            note = i == 1 and "latest" or "",
        })
    end
    return versions
end

function util:hasValue(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end

    return false
end

function util:clearCache()
    os.remove(RUNTIME.pluginDirPath .. "/available.cache")
end

function util:get_download_info(version)
    local ver = nil
    local url = nil
    local md5 = nil
    local result = util:fetch_versions()
    if version == "latest" then
        ver = result[1].version
        url = result[1].url
        md5 = result[1].md5
    else
        for _, v in ipairs(result) do
            if v.version == version then
                ver = v.version
                url = v.url
                md5 = v.md5
                break
            end
        end
    end

    return {
        version = ver,
        url = url,
        md5 = md5,
    }
end

return util
