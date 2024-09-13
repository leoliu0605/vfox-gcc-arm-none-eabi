local util = require("util")

--- Extension point, called after PreInstall, can perform additional operations,
--- such as file operations for the SDK installation directory or compile source code
--- Currently can be left unimplemented!
function PLUGIN:PostInstall(ctx)
    --- ctx.rootPath SDK installation directory
    local rootPath = ctx.rootPath
    local sdkInfo = ctx.sdkInfo['gcc_arm_none_eabi']
    local path = sdkInfo.path
    local version = sdkInfo.version
    local name = sdkInfo.name
    local note = sdkInfo.note

    local versions = util:fetch_versions()
    local url = ""
    for _, v in ipairs(versions) do
        if v.version == version then
            url = v.url
            break
        end
    end
    local filename = url:match("^.+/(.+)$")
    print(filename)
    filename = path .. "/" .. filename
    print(filename)
    if RUNTIME.osType ~= "windows" then
        if filename:match("%.tar%.bz2$") then
            os.execute("tar -xjf " .. filename .. " --strip-components=1 -C " .. path)
            os.remove(filename)
        end
    end
end
