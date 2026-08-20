# Configuring Kanata for home row mods

This is not going to be needed on most keyboards, but for laptops it is
very handy. Ensure you add kanata to your Brewfile.local.

Kanata needs the Karabiner-DriverKit-VirtualHIDDevice driver to grab keyboard
output on macOS — see [Karabiner VirtualHIDDevice
Driver](#karabiner-virtualhiddevice-driver) below. The recommended setup
installs that driver standalone, without the Karabiner Elements app: one less
background app/daemon, and its "auto-manages driver updates" convenience
doesn't reliably hold anyway (its bundled driver version can still lag behind
what kanata needs, forcing the same manual `.pkg` install either way). Only
add `karabiner-elements` to Brewfile.local and fully set it up, including
granting all permissions, if you want it for its own remapping features —
kanata itself doesn't need it.

## Multiple Keyboard Support

The kanata configuration is set to only apply to the MacBook's built-in keyboard,
leaving external keyboards unaffected. This prevents conflicts with external
mechanical keyboards that may have their own layouts or programming.

To see available keyboards on your system:
```bash
kanata --list
```

The configuration uses `macos-dev-names-include` to target only the
"Apple Internal Keyboard / Trackpad" device. External keyboards like mechanical
boards will continue to work normally without kanata modifications.

## Karabiner VirtualHIDDevice Driver

Kanata grabs keyboard *output* on macOS through the
[Karabiner-DriverKit-VirtualHIDDevice](https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice)
driver. This is **not the same thing** as the Input Monitoring/Accessibility
permissions below, and it's not available via Homebrew — it's a manual
`.pkg` install either way, whether or not Karabiner Elements is involved.
The driver has its own version line (v1.x, v5.x, v6.x, v8.x, ...), independent
of both kanata's and Karabiner Elements' version numbers. Check the
[kanata setup-macos.md](https://github.com/jtroo/kanata/blob/main/docs/setup-macos.md)
for the version your installed kanata expects — as of kanata 1.12.0 that's
**v6.2.0**; kanata >= v1.13.0 needs v8.0.0. Download the matching `.pkg` from
its [releases page](https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases)
and run the installer. That installs the driver files but does **not** by
itself activate the system extension — on a machine where this driver has
never been approved before, `systemextensionsctl list` will show nothing for
it even after the `.pkg` finishes. Trigger activation explicitly with the
manager binary the `.pkg` drops (it's a hidden, dot-prefixed app; double-
clicking or `open`-ing it does nothing — it needs a subcommand):

```bash
"/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate
```

That prints `request ... requires user approval` — System Settings > Privacy
& Security should then show a banner (or check System Settings > General >
Login Items & Extensions > Driver Extensions) to approve it. Confirm with
`systemextensionsctl list`; the driver should show
`org.pqrs.Karabiner-DriverKit-VirtualHIDDevice ... [activated enabled]`.
Once approved, upgrading to a newer driver version later reportedly doesn't
need this dance repeated — the daemon (whether started by Karabiner Elements
or the standalone LaunchDaemon below) picks up the new version against the
already-trusted extension — but that's unconfirmed against the initial-
activation behavior above. If kanata is ever upgraded across the v1.13.0
line, the driver needs a matching upgrade or you'll hit this mismatch
symptom: kanata runs and grabs the keyboard for *input* fine, then loops
forever on:

```
connect_failed asio.system:2
[INFO] Waiting for DriverKit virtual keyboard... (Ns/10.0s)
[WARN] output backend not ready after 10s. Key output may fail until the backend recovers.
```

### Recommended: standalone driver, no Karabiner Elements

Karabiner Elements isn't actually required by kanata — only the driver is,
and installing Karabiner Elements doesn't reliably save you from managing
that driver by hand anyway: its bundled copy is pinned to whatever version
shipped with that release, and it can be (and in practice has been) older
than what kanata's client library speaks — so you can end up doing the
manual `.pkg` install above *even with* Karabiner Elements installed. Given
that, the standalone driver is the simpler default when you don't need
Karabiner Elements for anything else: one less background app, and the same
manual driver management either way.

Skipping the `karabiner-elements` cask means its daemon isn't around to start
the driver automatically, so the daemon needs its own LaunchDaemon instead.
This repo ships one at `kanata/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist`
(copied from kanata's own `cfg_samples/karabiner-vhid-daemon.plist`):

```bash
sudo cp kanata/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist \
  /Library/LaunchDaemons/
sudo launchctl bootstrap system \
  /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist
```

Verify it's running:

```bash
sudo launchctl list | grep org.pqrs
```

To uninstall:

```bash
sudo launchctl bootout system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon
sudo rm /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist
```

### Alternative: with Karabiner Elements

Only do this if you want Karabiner Elements for its own remapping features.
Add `karabiner-elements` to Brewfile.local, then completely set it up,
including granting all permissions. Its daemon replaces the LaunchDaemon
above — skip that step. Expect the same manual driver `.pkg` install from
above whenever its bundled driver version falls behind what kanata needs;
Karabiner Elements being installed doesn't prevent that.

## Installation

If you installed Karabiner Elements, quit it, including the menu bar app.
Then copy the kanata plist to the right place:

```bash
sudo cp kanata/com.example.kanata.plist /Library/LaunchDaemons/
sudo launchctl load /Library/LaunchDaemons/com.example.kanata.plist
```

Finally, start kanata using the following command:

```bash
sudo launchctl start com.example.kanata
```

Kanata needs **two** separate permissions to open the keyboard, both under
System Settings > Privacy & Security. Grant both; missing either causes the same
"failed to open keyboard device(s)" failure:

- **Input Monitoring**
- **Accessibility**

For each, hit the `+` button and navigate to the kanata binary, likely
`/opt/homebrew/bin/kanata`, then make sure its toggle is on.

Finally, pin the formula so Homebrew stops silently updating the binary out from
under these permission grants (`repack` runs a bare `brew upgrade`,
which is what keeps bumping it):

```bash
brew pin kanata
```

The pin is machine-local brew state (a symlink under
`$(brew --prefix)/var/homebrew/pinned/`), not tracked in this repo and not
expressible in a Brewfile — so it's a required manual step on every new machine.
Pending kanata updates still show up in the `repack` summary under "Held back";
take one deliberately with `brew unpin kanata && brew upgrade kanata`, then
re-grant both permissions and `brew pin kanata` again.

## Troubleshooting

### Permission Errors ("failed to open keyboard device(s)")

**Symptom**: Kanata fails to start, `KeepAlive` restarts it every ~10s, and the
logs show `config file is valid` but then one of:
```
kanata needs macOS Input Monitoring permission ...
kanata needs macOS Accessibility permission ...
IOHIDDeviceOpen error: (iokit/common) not permitted Apple Internal Keyboard / Trackpad
```

**Cause**: This typically occurs after Homebrew updates the kanata binary. macOS
pins permissions to the exact binary and revokes them when it changes, so the new
binary is unauthorized. Kanata needs **both** Input Monitoring and Accessibility;
they are revoked independently, so fixing one can just surface the other on the
next restart (Accessibility is the commonly-missed second one — jtroo/kanata#1211).

**Solution**: for **each** of Input Monitoring **and** Accessibility, under
System Settings > Privacy & Security:
1. Find the kanata entry — it may show an error or warning icon, or point at a
   stale binary path
2. Remove it with the `-` button (macOS pins the old path; a stale entry won't
   authorize the current binary)
3. Click `+`, navigate to `/opt/homebrew/bin/kanata`, and select it
4. Make sure its toggle is on

Then restart the daemon (it's already loaded, so `kickstart -k` re-runs it in
place — cleaner than stop/start):
```bash
sudo launchctl kickstart -k system/com.example.kanata
```

Verify it grabbed the keyboard cleanly (look for `keyboard grabbed, entering
event processing loop` with no following `[ERROR]`):
```bash
tail -f /Library/Logs/Kanata/kanata.out.log /Library/Logs/Kanata/kanata.err.log
```

**Note**: You'll need to repeat this each time Homebrew updates the kanata binary.
To avoid the churn, `brew pin kanata` stops it from silently updating out from
under the permission grants.

### Driver version mismatch (`connect_failed asio.system:2`)

**Symptom**: Kanata starts, logs `keyboard grabbed, entering event processing
loop` (input side is fine), but then loops on:
```
connect_failed asio.system:2
[INFO] Waiting for DriverKit virtual keyboard... (Ns/10.0s)
[WARN] output backend not ready after 10s. Key output may fail until the backend recovers.
```

**Cause**: see [Karabiner VirtualHIDDevice Driver](#karabiner-virtualhiddevice-driver)
above — the installed driver version doesn't match what this kanata version's
client library speaks.

**Solution**: install the matching driver `.pkg` from its
[releases page](https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases)
per that section, then `sudo launchctl kickstart -k system/com.example.kanata`.

### Driver not activated (`failed to open keyboard device(s): Karabiner-VirtualHIDDevice driver is not activated`)

**Symptom**: kanata grabs input fine, Input Monitoring and Accessibility are
both granted, but it still loops on this error (distinct from the version
mismatch above — no `connect_failed asio.system:2`). `systemextensionsctl
list` shows nothing for `org.pqrs.Karabiner-DriverKit-VirtualHIDDevice`.

**Cause**: installing the driver `.pkg` does not activate the system
extension by itself on a machine where it's never been approved before — see
[Karabiner VirtualHIDDevice Driver](#karabiner-virtualhiddevice-driver)
above.

**Solution**: run the manager binary's `activate` subcommand and approve the
resulting prompt, per that section, then
`sudo launchctl kickstart -k system/com.example.kanata`.

## Resources

- https://github.com/jtroo/kanata/issues/1264#issuecomment-2763085239
- https://github.com/jtroo/kanata/discussions/1537
- https://github.com/dreamsofcode-io/home-row-mods/tree/main/kanata/macos
- https://github.com/jtroo/kanata/blob/main/docs/setup-macos.md
- https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice
