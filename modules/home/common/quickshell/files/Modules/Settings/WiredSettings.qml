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

    property var connections: []
    // Keyed by connection name: { method, address, gateway, dns }. Nothing
    // is sent to NetworkManager until Apply is pressed.
    property var staged: ({})
    property bool hasPendingChanges: false

    function refresh() {
        listProc.running = false;
        listProc.running = true;
    }

    function stagedFor(name) {
        return root.staged[name] || {
            "method": "auto",
            "address": "",
            "gateway": "",
            "dns": ""
        };
    }

    function ensureStaged(conn) {
        if (root.staged[conn.name] !== undefined)
            return;

        let s = Object.assign({}, root.staged);
        s[conn.name] = {
            "method": conn.method || "auto",
            "address": conn.address || "",
            "gateway": conn.gateway || "",
            "dns": conn.dns || ""
        };
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
        for (let i = 0; i < root.connections.length; i++) {
            let c = root.connections[i];
            s[c.name] = {
                "method": c.method || "auto",
                "address": c.address || "",
                "gateway": c.gateway || "",
                "dns": c.dns || ""
            };
        }
        root.staged = s;
        root.hasPendingChanges = false;
    }

    function applyAll() {
        for (let i = 0; i < root.connections.length; i++) {
            let conn = root.connections[i];
            let s = root.staged[conn.name];
            if (!s)
                continue;

            if (s.method === "auto") {
                applyProc.command = ["nmcli", "connection", "modify", conn.name, "ipv4.method", "auto", "ipv4.addresses", "", "ipv4.gateway", "", "ipv4.dns", ""];
            } else {
                applyProc.command = ["nmcli", "connection", "modify", conn.name, "ipv4.method", "manual", "ipv4.addresses", s.address, "ipv4.gateway", s.gateway, "ipv4.dns", s.dns];
            }
            applyProc.running = true;
            upProc.command = ["nmcli", "connection", "up", conn.name];
            upProc.running = true;
        }
        root.hasPendingChanges = false;
        refreshDelay.start();
    }

    Component.onCompleted: refresh()

    Timer {
        id: refreshDelay

        interval: 800
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
        id: listProc

        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status | awk -F: '$2==\"ethernet\"'"]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n").filter((l) => {
                    return l.length > 0;
                });
                let out = [];
                let pending = lines.length;
                if (pending === 0) {
                    root.connections = [];
                    return;
                }
                let results = [];
                lines.forEach((line, idx) => {
                    let parts = line.split(":");
                    let device = parts[0];
                    let state = parts[2];
                    let connName = parts[3];
                    if (!connName) {
                        pending -= 1;
                        if (pending === 0)
                            root.connections = results;

                        return;
                    }
                    detailProcFor(device, connName, state, (info) => {
                        results.push(info);
                        pending -= 1;
                        if (pending === 0) {
                            root.connections = results;
                            for (let j = 0; j < results.length; j++)
                                root.ensureStaged(results[j]);

                        }
                    });
                });
            }
        }

    }

    function detailProcFor(device, connName, state, cb) {
        let p = detailProcComponent.createObject(root, {
            "device": device,
            "connName": connName,
            "state": state,
            "onInfoReady": cb
        });
        p.start();
    }

    Component {
        id: detailProcComponent

        Item {
            id: helper

            property string device: ""
            property string connName: ""
            property string state: ""
            property var onInfoReady: null

            function start() {
                proc.running = true;
            }

            Process {
                id: proc

                command: ["sh", "-c", "nmcli -t -f IP4.ADDRESS,IP4.GATEWAY,IP4.DNS device show '" + helper.device + "'; echo ---; nmcli -t -f ipv4.method,ipv4.addresses,ipv4.gateway,ipv4.dns connection show '" + helper.connName + "'"]

                stdout: StdioCollector {
                    onStreamFinished: {
                        let sections = text.split("---\n");
                        let runtime = (sections[0] || "").trim().split("\n");
                        let configured = (sections[1] || "").trim().split("\n");
                        let currentAddr = "";
                        let currentGw = "";
                        let currentDns = "";
                        runtime.forEach((l) => {
                            if (l.startsWith("IP4.ADDRESS"))
                                currentAddr = l.split(":").slice(1).join(":");
                            else if (l.startsWith("IP4.GATEWAY"))
                                currentGw = l.split(":").slice(1).join(":");
                            else if (l.startsWith("IP4.DNS") && currentDns === "")
                                currentDns = l.split(":").slice(1).join(":");
                        });
                        let method = "auto";
                        let cfgAddr = "";
                        let cfgGw = "";
                        let cfgDns = "";
                        configured.forEach((l) => {
                            if (l.startsWith("ipv4.method:"))
                                method = l.split(":")[1] || "auto";
                            else if (l.startsWith("ipv4.addresses:"))
                                cfgAddr = l.substring("ipv4.addresses:".length);
                            else if (l.startsWith("ipv4.gateway:"))
                                cfgGw = l.substring("ipv4.gateway:".length);
                            else if (l.startsWith("ipv4.dns:"))
                                cfgDns = l.substring("ipv4.dns:".length);
                        });
                        let info = {
                            "name": helper.connName,
                            "device": helper.device,
                            "state": helper.state,
                            "method": method,
                            "address": method === "manual" ? cfgAddr : currentAddr,
                            "gateway": method === "manual" ? cfgGw : currentGw,
                            "dns": method === "manual" ? cfgDns : currentDns,
                            "currentAddress": currentAddr,
                            "currentGateway": currentGw,
                            "currentDns": currentDns
                        };
                        if (helper.onInfoReady)
                            helper.onInfoReady(info);

                        helper.destroy();
                    }
                }

            }

        }

    }

    Process {
        id: applyProc
    }

    Process {
        id: upProc
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Constants.sizeMd
        visible: root.connections.length > 0

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            ThemedText {
                text: "Wired Network"
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

    ThemedText {
        visible: root.connections.length === 0
        text: "No wired connections detected."
        color: Theme.muted
        font.pixelSize: Constants.sizeSm
    }

    Repeater {
        model: root.connections

        SettingGroup {
            id: group

            required property var modelData
            readonly property var staged: root.stagedFor(modelData.name)

            title: modelData.device + " — " + modelData.name
            icon: "commit"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                ThemedText {
                    text: "Status: " + group.modelData.state
                    font.pixelSize: Constants.sizeXs
                    color: Theme.muted
                }

                ThemedText {
                    text: "Current: " + (group.modelData.currentAddress || "none") + (group.modelData.currentGateway ? " via " + group.modelData.currentGateway : "")
                    font.pixelSize: Constants.sizeXs
                    color: Theme.muted
                }

            }

            SettingToggle {
                label: "Automatic (DHCP)"
                description: "Turn off to set a static IP address"
                checked: group.staged.method !== "manual"
                onCheckedChanged: {
                    let wantAuto = checked;
                    let isAuto = group.staged.method !== "manual";
                    if (wantAuto !== isAuto)
                        root.setStaged(group.modelData.name, "method", wantAuto ? "auto" : "manual");

                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: group.staged.method === "manual"
                spacing: Constants.sizeLg

                ThemedTextField {
                    Layout.fillWidth: true
                    label: "IP Address"
                    placeholderText: "192.168.1.50/24"
                    text: group.staged.address
                    onEditingFinished: root.setStaged(group.modelData.name, "address", text)
                }

                ThemedTextField {
                    Layout.fillWidth: true
                    label: "Gateway"
                    placeholderText: "192.168.1.1"
                    text: group.staged.gateway
                    onEditingFinished: root.setStaged(group.modelData.name, "gateway", text)
                }

                ThemedTextField {
                    Layout.fillWidth: true
                    label: "DNS Servers (comma-separated)"
                    placeholderText: "1.1.1.1,8.8.8.8"
                    text: group.staged.dns
                    onEditingFinished: root.setStaged(group.modelData.name, "dns", text)
                }

            }

        }

    }

}
