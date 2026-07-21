# Change Proposal: Implement Wayland Grim and Slurp Screenshot Fallback

## Why
Under Wayland environments (like COSMIC/Wayland), using standard `libportal` desktop screenshot portals can fail due to sandbox/application id mismatches, compositor support issues, or not allowing the user to select/drag an area to capture (defeating the "drag to snatch" purpose of TextSnatcher).

## What
Modify `TesseractTrigger.vala` to detect the presence of `grim` and `slurp` command line utilities when running on Wayland. If present, run `grim -g "$(slurp)" /tmp/textshot.png` to let the user select a custom area and capture it, bypassing the portal. If they are missing, fallback to the portal.

## Impact
- Instant area selection screenshot tool on Wayland / COSMIC desktop.
- Highly stable and fast.
