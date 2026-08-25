-- A repeating timer walks the metrics through a deterministic
-- pseudo-random sequence (LCG), so the dashboard animates without any
-- backend. Swap `step()` for `fetch(...)` + `on_fetch` to drive it
-- from a real API.

local function rand(n)
    -- Park-Miller LCG over a signal-backed seed.
    local s = signal("seed", 20260722)
    local next_seed = (s:get() * 48271) % 2147483647
    s:set(next_seed)
    return next_seed % n
end

local function step()
    local tick = signal("ticks", 0)
    tick:set(tick:get() + 1)
    signal("clock", ""):set("tick " .. tick:get())

    local req = 180 + rand(120)
    local usr = 40 + rand(25)
    local err = rand(40)
    signal("requests", 0):set(req)
    signal("users", 0):set(usr)
    signal("errors", ""):set(math.floor(err / 10) .. "." .. (err % 10) .. "%")

    local cpu = 20 + rand(70)
    local mem = 35 + rand(50)
    signal("cpu", 0):set(cpu)
    signal("mem", 0):set(mem)
    signal("cpu_label", ""):set(cpu .. "%")
    signal("mem_label", ""):set(mem .. "%")

    local feed = signal_array("activity")
    local n = tick:get()
    feed:push({
        id = "" .. n,
        time = "+" .. n .. "s",
        text = "deploy " .. (1000 + rand(9000)) .. " served " .. req .. " req/min",
    })
    -- Keep the feed bounded (newest last). Rows come back 1-indexed, the Lua
    -- convention every host-built sequence follows.
    local rows = feed:all()
    if #rows > 12 then
        table.remove(rows, 1)
        feed:set(rows)
    end
end

function on_start()
    on("click", "pause", "toggle_pause")
    signal("pause_label", ""):set("Pause")
    step()
    set_interval("sim", 1200)
end

function on_timer(name)
    if name == "sim" then step() end
end

function toggle_pause(id)
    local running = signal("running", "true")
    if running:get() == "true" then
        cancel_timer("sim")
        running:set("false")
        signal("pause_label", ""):set("Resume")
    else
        set_interval("sim", 1200)
        running:set("true")
        signal("pause_label", ""):set("Pause")
    end
end
