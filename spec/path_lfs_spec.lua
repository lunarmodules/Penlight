describe("pl.path lfs requirement", function()
    local original_require
    local original_path_loaded

    before_each(function()
        original_require = _G.require
        original_path_loaded = package.loaded["pl.path"]
        package.loaded["pl.path"] = nil
    end)

    after_each(function()
        _G.require = original_require
        package.loaded["pl.path"] = original_path_loaded
    end)

    it("throws friendly error when lfs module is genuinely missing", function()
        _G.require = function(mod)
            if mod == "lfs" then
                error("module 'lfs' not found:\n\tno field package.preload['lfs']\n\tno file ...")
            end
            return original_require(mod)
        end

        assert.has.error(function()
            require("pl.path")
        end, "pl.path requires LuaFileSystem")
    end)

    it("rethrows original error when lfs fails to load for other reasons", function()
        _G.require = function(mod)
            if mod == "lfs" then
                error("error loading module 'lfs' from file '...': undefined symbol: lua_gettop")
            end
            return original_require(mod)
        end

        local ok, err = pcall(require, "pl.path")
        assert.is_false(ok)
        assert.match("undefined symbol: lua_gettop", err)
    end)
end)
