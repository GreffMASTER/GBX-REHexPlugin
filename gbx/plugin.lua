local gbx = require('gbx')

local plugin_debug = false

local function f_OnTabCreated(mainwindow, tab)
    local doc = mainwindow:active_document()
    local comments = tab.doc:get_comments()
	if #comments > 0 then
		-- Don't offer to analyse if there are any comments.
		return
	end
	
	local filepath = tab.doc:get_filename()
	
	if string.match(filepath:lower(), '%.gbx$') then
        if doc:buffer_length() < 8 then
            -- Don't offer to analyse if there is not enough data
            return
        end
        -- Check for b'GBX' magic
        local magic = doc:read_data(0,3)
        if magic == 'GBX' then
            -- Get only the filename
            local filename_off = filepath:find('[^\\/]+$')
            local filename = filepath:sub(filename_off)
            
            local message = 'It looks like ' .. filename .. ' is a GBX file, attempt to analyse?'
            
            local res = wx.wxMessageBox(message, 'Analyse GBX file', wx.wxYES_NO, mainwindow)
            if res == wx.wxYES then
                local status, err = pcall(gbx.analyse, doc)
                if not status then
                    if not plugin_debug then
                        -- Get rid of the lua traceback
                        local str_off = err:find(': ')
                        err = err:sub(str_off + 2)
                    end
                    wx.wxMessageBox(err, 'Analysis error', wx.wxOK, mainwindow)
                end
            end
        end
	end
end

local function f_ToolAnalyseGbx(mainwindow)
    local doc = mainwindow:active_document()
    if doc:buffer_length() < 8 then
        -- Don't offer to analyse if there is not enough data
        return
    end
    -- Check for b'GBX' magic
    local magic = doc:read_data(0,3)
    if magic == 'GBX' then
        local status, err = pcall(gbx.analyse, doc)
        if not status then
            if not plugin_debug then
                -- Get rid of the lua traceback
                local str_off = err:find(': ')
                err = err:sub(str_off + 2)
            end
            wx.wxMessageBox(err, 'Analysis error', wx.wxOK, mainwindow)
        end
    end
end

local function f_ToolAboutGbx(mainwindow)
    local message = [[

        GBX ReHex Plugin
        Version 1.0
        Made By GreffMASTER
        2024
    ]]
    wx.wxMessageBox(message, 'Analyse GBX file', wx.wxOK, mainwindow)
end

-- Hooks

rehex.OnTabCreated(f_OnTabCreated)
rehex.AddToToolsMenu('Analyse GBX', f_ToolAnalyseGbx);
rehex.AddToToolsMenu('About GBX plugin', f_ToolAboutGbx);