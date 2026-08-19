import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core
pragma Singleton

Item {
    id: updateService

    property bool packageManagerChecksEnabled: true
    property int packageManagerCheckInterval: 3.6e+06
    property var outdatedInputs: []
    property int lastNotifiedCount: -1
    readonly property bool isCheckingUpdates: flakeCheckProc.running
    readonly property bool hasResult: outdatedInputs !== null

    signal checkUpdates()

    onPackageManagerChecksEnabledChanged: {
        if (SettingsService.settingsLoaded)
            SettingsService.saveSettings();

    }
    onPackageManagerCheckIntervalChanged: {
        if (SettingsService.settingsLoaded)
            SettingsService.saveSettings();

    }
    onCheckUpdates: {
        flakeCheckProc.running = false;
        flakeCheckProc.running = true;
    }

    Process {
        id: flakeCheckProc

        command: ["python3", Quickshell.env("HOME") + "/.config/quickshell/Scripts/check_flake_updates.py"]

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    const result = JSON.parse(data);
                    updateService.outdatedInputs = result.outdated || [];
                    const count = result.count || 0;
                    if (count > 0 && count !== updateService.lastNotifiedCount) {
                        notifyProc.command = ["notify-send", "-i", "update", "Flake updates available", count + " input" + (count === 1 ? "" : "s") + " outdated: " + updateService.outdatedInputs.join(", ")];
                        notifyProc.running = true;
                    }
                    updateService.lastNotifiedCount = count;
                } catch (e) {
                }
            }
        }

    }

    Process {
        id: notifyProc
    }

    Timer {
        id: hourlyUpdateTimer

        interval: updateService.packageManagerCheckInterval
        running: updateService.packageManagerChecksEnabled
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            flakeCheckProc.running = false;
            flakeCheckProc.running = true;
        }
    }

}
