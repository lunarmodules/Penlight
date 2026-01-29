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

    it("shows descriptive error when lfs fails to load", function()
        _G.require = function(mod)
            if mod == "lfs" then
                error("module 'lfs' not found:\n\tno field package.preload['lfs']\n\tno file ...")
            end
            return original_require(mod)
        end

        local ok, err = pcall(require, "pl.path")
        assert.is_false(ok)
        assert.match("pl.path requires LuaFileSystem, but failed loading it:", err)
        assert.match("module 'lfs' not found", err)
    end)

    it("includes loader error in message", function()
        _G.require = function(mod)
            if mod == "lfs" then
                error("error loading module 'lfs' from file '...': undefined symbol: lua_gettop")
            end
            return original_require(mod)
        end

        local ok, err = pcall(require, "pl.path")
        assert.is_false(ok)
        assert.match("pl.path requires LuaFileSystem, but failed loading it:", err)
        assert.match("undefined symbol: lua_gettop", err)
    end)
end)
