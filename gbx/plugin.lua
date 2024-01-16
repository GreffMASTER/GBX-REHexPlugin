local gbx = require('gbx')

-- Settings

local settings = {
    offer_analysis = true,  -- Offers to analyse the file upon opening
    debug_mode = false      -- Displays lua file traceback in the error popup
}

-- Code

local large_warn = '(Large files might take a while and freeze the editor until it\'s done, do not close it!)'

local function analyse_gbx(mainwindow, doc)
    local status, err = pcall(gbx.analyse, doc)
    if not status then
        if not settings.debug_mode then
            -- Get rid of the lua traceback for non-debug mode
            local str_off = err:find(': ')
            err = err:sub(str_off + 2)
        end
        wx.wxMessageBox(err, 'Analysis error', wx.wxOK, mainwindow)
    end
end

local function f_OnTabCreated(mainwindow, tab)
    -- Don't offer to analyse if user doesn't want to
    if not settings.offer_analysis then return end

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
            
            local message = 'It looks like ' .. filename .. ' is a GBX file, attempt to analyse?\n' .. large_warn
            
            local res = wx.wxMessageBox(message, 'Analyse GBX file', wx.wxYES_NO, mainwindow)
            if res == wx.wxYES then
                analyse_gbx(mainwindow, doc)
            end
        end
	end
end

local function f_ToolanalyseGbx(mainwindow)
    local doc = mainwindow:active_document()
    if doc:buffer_length() < 8 then
        -- Don't offer to analyse if there is not enough data
        return
    end
    -- Check for b'GBX' magic
    local magic = doc:read_data(0,3)
    if magic == 'GBX' then
        local message = 'Attempt to analyse?\n' .. large_warn
        local res = wx.wxMessageBox(message, 'Analyse GBX file', wx.wxYES_NO, mainwindow)
        if res == wx.wxYES then
            analyse_gbx(mainwindow, doc)
        end
    end
end

local function f_ToolAboutGbx(mainwindow)
    local message = [[

        GBX ReHex Plugin
        Version 1.0.3
        Made By GreffMASTER
        2024
    ]]
    wx.wxMessageBox(message, 'About GBX Plugin', wx.wxOK, mainwindow)
end

-- Hooks

rehex.OnTabCreated(f_OnTabCreated)
rehex.AddToToolsMenu('Analyse GBX', f_ToolanalyseGbx);
rehex.AddToToolsMenu('About GBX Plugin', f_ToolAboutGbx);