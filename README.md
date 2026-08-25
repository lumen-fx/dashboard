# dashboard

A live metrics dashboard: stat tiles, progress bars, and an activity
feed, all animated by a repeating timer.

This is the Lua template. The builtins are Lua globals with no import
step, handles use the colon call form (`signal("cpu", 0):set(70)`), and
every sequence the host builds is 1-indexed.

Concepts demonstrated:

- **`<tile>` composition** - stat cards are plain tiles with labels;
  every color / radius routes through CSS custom properties.
- **`<progress bind-value max>`** - determinate bars track a numeric
  signal; the fill is styled via `.progress-fill { ... }`.
- **Timers** - `set_interval("sim", 1200)` + `on_timer(name)` drive the
  simulation; `cancel_timer` pauses it (Pause / Resume button).
- **Bounded array feeds** - the activity list pushes onto an array
  signal and trims the head so the `<for>` stays 12 rows.
- **`bind-text` everywhere** - no `set_text` calls; every dynamic string
  is a signal.

Swap the `step()` simulation for `fetch(url, tag)` + `on_fetch` to feed
the same UI from a real endpoint.

Run it:

```sh
lumenc run .
```
