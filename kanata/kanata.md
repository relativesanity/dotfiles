# Configuring Kanata for home row mods

This is not going to be needed on most keyboards, but for laptops it is
very handy. Ensure you add kanata and karabiner-elements to your Brewfile.local,
and then completely set up Karabiner Elements, including granting all permissions.

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

## Installation

Quit Karabiner Elements, including the menu bar app, and copy the plist to the
right place

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
under these permission grants (`repack`/`dot pack` runs a bare `brew upgrade`,
which is what keeps bumping it):

```bash
brew pin kanata
```

The pin is machine-local brew state (a symlink under
`$(brew --prefix)/var/homebrew/pinned/`), not tracked in this repo and not
expressible in a Brewfile — so it's a required manual step on every new machine.
Pending kanata updates still show up in the `dot pack` summary under "Held back";
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

## Resources

- https://github.com/jtroo/kanata/issues/1264#issuecomment-2763085239
- https://github.com/jtroo/kanata/discussions/1537
- https://github.com/dreamsofcode-io/home-row-mods/tree/main/kanata/macos
