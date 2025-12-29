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

Note that you may need to grant Input Monitoring permissions to Kanata in
System Preferences > Security & Privacy > Privacy > Input Monitoring. This is done by
hitting the `+` button and navigating to the path for kanata,
likely /opt/homebrew/bin/kanata.

## Troubleshooting

### IOKit Permission Errors

**Symptom**: Kanata fails to start with errors in the logs similar to:
```
IOHIDDeviceOpen error: (iokit/common) not permitted Apple Internal Keyboard / Trackpad
```

**Cause**: This typically occurs after Homebrew updates the kanata binary. macOS
revokes previously granted Input Monitoring permissions when the binary changes.

**Solution**:
1. Open System Settings > Privacy & Security > Input Monitoring (or System Preferences > Security & Privacy > Privacy > Input Monitoring on older macOS)
2. Find the kanata entry in the list - it may show an error or warning icon
3. Remove the existing kanata entry by selecting it and clicking the `-` button
4. Click the `+` button to re-add kanata
5. Navigate to `/opt/homebrew/bin/kanata` and select it
6. Restart the kanata service:
   ```bash
   sudo launchctl stop com.example.kanata
   sudo launchctl start com.example.kanata
   ```
7. Verify kanata is running by checking the logs:
   ```bash
   tail -f /Library/Logs/Kanata/kanata.out.log
   tail -f /Library/Logs/Kanata/kanata.err.log
   ```

**Note**: You'll need to repeat this process each time Homebrew updates the kanata binary.

## Resources

- https://github.com/jtroo/kanata/issues/1264#issuecomment-2763085239
- https://github.com/jtroo/kanata/discussions/1537
- https://github.com/dreamsofcode-io/home-row-mods/tree/main/kanata/macos
