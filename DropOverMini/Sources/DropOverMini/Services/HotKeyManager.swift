import AppKit
import Carbon

// MARK: - HotKey Manager

/// Manages global hotkeys using CGEvent tap.
/// Requires Accessibility permissions in System Settings > Privacy & Security > Accessibility.
class HotKeyManager {
    private unowned let shelfManager: ShelfManager
    private var eventTap: CFMachPort?

    /// HotKey: Command + Shift + N
    private let hotKeyCode: UInt16 = 45  // kVK_ANSI_N
    private let hotKeyModifiers: CGEventFlags = [.maskCommand, .maskShift]

    init(shelfManager: ShelfManager) {
        self.shelfManager = shelfManager
    }

    /// Register the global hotkey
    func registerHotKey() {
        guard eventTap == nil else { return }

        let eventMask = (1 << CGEventType.keyDown.rawValue)
        let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { proxy, type, event, refcon in
                guard type == .keyDown,
                      let refcon = refcon else {
                    return Unmanaged.passUnretained(event)
                }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(refcon).takeUnretainedValue()
                if manager.handleKeyEvent(event) {
                    return nil  // Consume event
                }
                return Unmanaged.passUnretained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        guard let tap else {
            print(L.hotkeyFailed)
            return
        }

        eventTap = tap
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        print(L.hotkeyOK)
    }

    /// Unregister the hotkey
    func unregisterHotKey() {
        guard let tap = eventTap else { return }
        CGEvent.tapEnable(tap: tap, enable: false)
        CFMachPortInvalidate(tap)
        eventTap = nil
        print("HotKey: unregistered")
    }

    /// Handle a keyDown event — check if it's our hotkey
    private func handleKeyEvent(_ event: CGEvent) -> Bool {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags

        guard keyCode == hotKeyCode else { return false }

        // Check for exactly Command + Shift (no other modifiers)
        let hasCmd = flags.contains(.maskCommand)
        let hasShift = flags.contains(.maskShift)
        let hasAlt = flags.contains(.maskAlternate)
        let hasCtrl = flags.contains(.maskControl)
        guard hasCmd && hasShift && !hasAlt && !hasCtrl else { return false }

        // Create new shelf
        DispatchQueue.main.async {
            self.shelfManager.createShelf(withFiles: [])
        }
        return true
    }
}
