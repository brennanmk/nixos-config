import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Core.Components
import qs.Modules.Settings.Components

SettingContainer {
    id: root

    property var monitors: []
    // Keyed by monitor name: { mode, scale, x, y, disabled }. Controls edit
    // this, not live Hyprland state -- nothing is sent until Apply is
    // pressed, so you can try values without every keystroke hitting Hyprland.
    property var staged: ({})
    property bool hasPendingChanges: false

    function refresh() {
        monitorsProc.running = false;
        monitorsProc.running = true;
    }

    function modeString(w, h, hz) {
        return w + "x" + h + "@" + hz.toFixed(2) + "Hz";
    }

    function logicalSize(m) {
        let w = m.width / m.scale;
        let h = m.height / m.scale;
        // transform 1/3/5/7 = 90deg/270deg (+ flipped variants): width and
        // height swap on screen.
        if (m.transform % 2 === 1)
            return {
                "w": h,
                "h": w
            };

        return {
            "w": w,
            "h": h
        };
    }

    function stagedFor(name) {
        return root.staged[name] || {
            "mode": "",
            "scale": 1,
            "x": 0,
            "y": 0,
            "disabled": false,
            "mirror": "none"
        };
    }

    function snapshotOf(mon) {
        return {
            "mode": root.modeString(mon.width, mon.height, mon.refreshRate),
            "scale": mon.scale,
            "x": mon.x,
            "y": mon.y,
            "disabled": mon.disabled,
            "mirror": mon.mirrorOf && mon.mirrorOf !== "" ? mon.mirrorOf : "none"
        };
    }

    function ensureStaged(mon) {
        if (root.staged[mon.name] !== undefined)
            return;

        let s = Object.assign({}, root.staged);
        s[mon.name] = root.snapshotOf(mon);
        root.staged = s;
    }

    function setStaged(name, key, value) {
        let s = Object.assign({}, root.staged);
        s[name] = Object.assign({}, s[name]);
        s[name][key] = value;
        root.staged = s;
        root.hasPendingChanges = true;
    }

    function discardChanges() {
        let s = {};
        for (let i = 0; i < root.monitors.length; i++)
            s[root.monitors[i].name] = root.snapshotOf(root.monitors[i]);

        root.staged = s;
        root.hasPendingChanges = false;
    }

    function applyAll() {
        for (let i = 0; i < root.monitors.length; i++) {
            let mon = root.monitors[i];
            let s = root.staged[mon.name];
            if (!s)
                continue;

            root.sendMonitor(mon.name, s, mon.transform);
        }
        root.hasPendingChanges = false;
        applyAllDelay.start();
    }

    function sendMonitor(name, s, transform) {
        // `hyprctl keyword` is rejected outright under the Lua config
        // ("keyword can't work with non-legacy parsers. Use eval.") -- has
        // to go through `hyprctl eval` calling the same hl.monitor() the
        // static config uses. availableModes entries end in "Hz", which
        // hl.monitor's mode string doesn't expect.
        if (s.disabled) {
            let lua = "hl.monitor({ output = \"" + name + "\", disabled = true })";
            applyProc.command = ["hyprctl", "eval", lua];
            applyProc.running = true;
            return;
        }
        let cleanMode = String(s.mode).replace(/Hz$/i, "");
        let mirror = s.mirror && s.mirror !== "none" ? s.mirror : "none";
        let lua = "hl.monitor({ output = \"" + name + "\", mode = \"" + cleanMode + "\", position = \"" + s.x + "x" + s.y + "\", scale = \"" + Number(s.scale).toFixed(2) + "\", mirror = \"" + mirror + "\"" + (transform ? ", transform = " + transform : "") + " })";
        applyProc.command = ["hyprctl", "eval", lua];
        applyProc.running = true;
    }

    Component.onCompleted: refresh()

    Timer {
        id: applyAllDelay

        interval: 500
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!root.hasPendingChanges)
                root.refresh();

        }
    }

    Process {
        id: monitorsProc

        command: ["hyprctl", "monitors", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let parsed = JSON.parse(text);
                    root.monitors = parsed;
                    for (let i = 0; i < parsed.length; i++)
                        root.ensureStaged(parsed[i]);

                } catch (e) {
                }
            }
        }

    }

    Process {
        id: applyProc
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Constants.sizeMd

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            ThemedText {
                text: "Displays"
                font.pixelSize: Constants.sizeLg
                font.bold: true
            }

            ThemedText {
                text: root.hasPendingChanges ? "You have unapplied changes" : "Everything is applied"
                font.pixelSize: Constants.sizeXs
                color: root.hasPendingChanges ? Theme.accent : Theme.muted
            }

        }

        ThemedButton {
            text: "Discard"
            visible: root.hasPendingChanges
            onClicked: root.discardChanges()
        }

        ThemedButton {
            text: "Apply"
            enabled: root.hasPendingChanges
            opacity: enabled ? 1 : 0.5
            onClicked: root.applyAll()
        }

    }

    SettingGroup {
        title: "Arrange Displays"
        icon: "app-window"
        visible: root.monitors.length > 0

        ThemedText {
            text: "Drag a display to reposition it, then hit Apply above."
            font.pixelSize: Constants.sizeXs
            color: Theme.muted
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }

        Item {
            id: arrangeCanvas

            function boundsOf() {
                if (root.monitors.length === 0)
                    return {
                        "minX": 0,
                        "minY": 0,
                        "maxX": 1,
                        "maxY": 1
                    };

                let minX = Infinity;
                let minY = Infinity;
                let maxX = -Infinity;
                let maxY = -Infinity;
                for (let i = 0; i < root.monitors.length; i++) {
                    let m = root.monitors[i];
                    let size = root.logicalSize(m);
                    let s = root.stagedFor(m.name);
                    minX = Math.min(minX, s.x);
                    minY = Math.min(minY, s.y);
                    maxX = Math.max(maxX, s.x + size.w);
                    maxY = Math.max(maxY, s.y + size.h);
                }
                return {
                    "minX": minX,
                    "minY": minY,
                    "maxX": maxX,
                    "maxY": maxY
                };
            }

            readonly property var bounds: boundsOf()
            readonly property real contentW: Math.max(1, bounds.maxX - bounds.minX)
            readonly property real contentH: Math.max(1, bounds.maxY - bounds.minY)
            readonly property real fitScale: Math.min(width / contentW, height / contentH) * 0.85
            readonly property real offsetX: (width - contentW * fitScale) / 2
            readonly property real offsetY: (height - contentH * fitScale) / 2

            Layout.fillWidth: true
            Layout.preferredHeight: 220

            Repeater {
                model: root.monitors

                Rectangle {
                    id: monRect

                    required property var modelData
                    readonly property var stagedSelf: root.stagedFor(modelData.name)
                    readonly property real logicalW: root.logicalSize(modelData).w
                    readonly property real logicalH: root.logicalSize(modelData).h

                    width: logicalW * arrangeCanvas.fitScale
                    height: logicalH * arrangeCanvas.fitScale
                    x: (stagedSelf.x - arrangeCanvas.bounds.minX) * arrangeCanvas.fitScale + arrangeCanvas.offsetX
                    y: (stagedSelf.y - arrangeCanvas.bounds.minY) * arrangeCanvas.fitScale + arrangeCanvas.offsetY
                    radius: Constants.sizeSm
                    opacity: stagedSelf.disabled ? 0.4 : 1
                    color: dragArea.drag.active ? Theme.accent : Theme.bgTertiary
                    border.width: modelData.focused ? 2 : 1
                    border.color: modelData.focused ? Theme.accent : Theme.border

                    ThemedText {
                        anchors.centerIn: parent
                        text: monRect.modelData.name
                        font.pixelSize: Constants.sizeXs
                        font.bold: true
                        color: dragArea.drag.active ? Theme.bg : Theme.fg
                    }

                    MouseArea {
                        id: dragArea

                        anchors.fill: parent
                        drag.target: parent
                        cursorShape: Qt.SizeAllCursor
                        onReleased: {
                            let realX = (monRect.x - arrangeCanvas.offsetX) / arrangeCanvas.fitScale + arrangeCanvas.bounds.minX;
                            let realY = (monRect.y - arrangeCanvas.offsetY) / arrangeCanvas.fitScale + arrangeCanvas.bounds.minY;
                            let snapPx = 40 / arrangeCanvas.fitScale;
                            for (let i = 0; i < root.monitors.length; i++) {
                                let other = root.monitors[i];
                                if (other.name === monRect.modelData.name)
                                    continue;

                                let otherStaged = root.stagedFor(other.name);
                                let otherSize = root.logicalSize(other);
                                if (Math.abs(realX - (otherStaged.x + otherSize.w)) < snapPx)
                                    realX = otherStaged.x + otherSize.w;
                                else if (Math.abs((realX + monRect.logicalW) - otherStaged.x) < snapPx)
                                    realX = otherStaged.x - monRect.logicalW;

                                if (Math.abs(realY - (otherStaged.y + otherSize.h)) < snapPx)
                                    realY = otherStaged.y + otherSize.h;
                                else if (Math.abs((realY + monRect.logicalH) - otherStaged.y) < snapPx)
                                    realY = otherStaged.y - monRect.logicalH;

                            }
                            root.setStaged(monRect.modelData.name, "x", Math.round(realX));
                            root.setStaged(monRect.modelData.name, "y", Math.round(realY));
                        }
                    }

                }

            }

        }

    }

    Repeater {
        model: root.monitors

        SettingGroup {
            id: group

            required property var modelData
            readonly property var staged: root.stagedFor(modelData.name)

            title: modelData.name + (staged.disabled ? " (disabled)" : "")
            icon: "app-window"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                ThemedText {
                    text: modelData.description
                    font.pixelSize: Constants.sizeXs
                    color: Theme.muted
                }

            }

            SettingToggle {
                label: "Enabled"
                checked: !group.staged.disabled
                onCheckedChanged: {
                    if (checked === group.staged.disabled)
                        root.setStaged(group.modelData.name, "disabled", !checked);

                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: !group.staged.disabled
                spacing: Constants.sizeLg

                SettingSelect {
                    label: "Mirror Of"
                    description: "Show the same image as another display"
                    model: {
                        let names = ["None"];
                        for (let i = 0; i < root.monitors.length; i++) {
                            if (root.monitors[i].name !== group.modelData.name)
                                names.push(root.monitors[i].name);

                        }
                        return names;
                    }
                    currentIndex: {
                        if (!group.staged.mirror || group.staged.mirror === "none")
                            return 0;

                        let idx = model.indexOf(group.staged.mirror);
                        return idx !== -1 ? idx : 0;
                    }
                    onActivated: (index) => {
                        root.setStaged(group.modelData.name, "mirror", model[index] === "None" ? "none" : model[index]);
                    }
                }

                Divider {
                }

                SettingSelect {
                    enabled: group.staged.mirror === "none"
                    opacity: enabled ? 1 : 0.5
                    label: "Resolution & Refresh Rate"
                    model: group.modelData.availableModes || []
                    currentIndex: {
                        let idx = model.indexOf(group.staged.mode);
                        return idx !== -1 ? idx : 0;
                    }
                    onActivated: (index) => {
                        root.setStaged(group.modelData.name, "mode", model[index]);
                    }
                }

                SettingSpinBox {
                    enabled: group.staged.mirror === "none"
                    opacity: enabled ? 1 : 0.5
                    label: "Scale"
                    from: 0.5
                    to: 3
                    stepSize: 0.05
                    decimals: 2
                    value: group.staged.scale
                    suffix: "x"
                    onMoved: (val) => {
                        root.setStaged(group.modelData.name, "scale", val);
                    }
                }

                SettingSpinBox {
                    enabled: group.staged.mirror === "none"
                    opacity: enabled ? 1 : 0.5
                    label: "Position X"
                    description: "Left edge, in pixels"
                    from: -10000
                    to: 10000
                    stepSize: 10
                    decimals: 0
                    value: group.staged.x
                    suffix: "px"
                    onMoved: (val) => {
                        root.setStaged(group.modelData.name, "x", Math.round(val));
                    }
                }

                SettingSpinBox {
                    enabled: group.staged.mirror === "none"
                    opacity: enabled ? 1 : 0.5
                    label: "Position Y"
                    description: "Top edge, in pixels"
                    from: -10000
                    to: 10000
                    stepSize: 10
                    decimals: 0
                    value: group.staged.y
                    suffix: "px"
                    onMoved: (val) => {
                        root.setStaged(group.modelData.name, "y", Math.round(val));
                    }
                }

            }

        }

    }

}
