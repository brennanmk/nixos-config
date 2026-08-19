import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.Core
import qs.Core.Components

Rectangle {
    id: root

    property bool expanded: false
    property bool isOutput: true
    readonly property var devices: {
        const all = Pipewire.nodes.values;
        const out = [];
        for (let i = 0; i < all.length; i++) {
            const n = all[i];
            if (!n.audio || n.isStream)
                continue;

            if (n.isSink === root.isOutput)
                out.push(n);

        }
        return out;
    }
    readonly property var activeNode: root.isOutput ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource
    // Optimistic override: PipeWire's own default-node change can lag behind
    // the write, so reflect the click immediately and self-heal once the
    // real default catches up (or reverts, if the write didn't take).
    property var pendingActiveId: null

    onActiveNodeChanged: {
        if (root.pendingActiveId !== null && root.activeNode && root.activeNode.id === root.pendingActiveId)
            root.pendingActiveId = null;

    }

    Layout.fillWidth: true
    Layout.preferredHeight: expanded ? Math.max(deviceCol.implicitHeight, 60) : 0
    opacity: expanded ? 1 : 0
    visible: opacity > 0
    clip: true
    radius: 0
    color: "transparent"
    border.width: 0

    PwObjectTracker {
        objects: root.devices
    }

    ColumnLayout {
        id: deviceCol

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        ThemedText {
            visible: root.devices.length === 0
            text: "No devices found"
            color: Theme.muted
            font.pixelSize: Constants.sizeSm
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(deviceRepeaterCol.implicitHeight, 200)
            contentHeight: deviceRepeaterCol.implicitHeight
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                id: deviceRepeaterCol

                width: parent.width
                spacing: Constants.sizeXs

                Repeater {
                    model: root.devices

                    Item {
                        id: deviceItem

                        readonly property bool isActive: root.pendingActiveId !== null ? root.pendingActiveId === modelData.id : (root.activeNode && root.activeNode.id === modelData.id)

                        Layout.fillWidth: true
                        implicitHeight: 36

                        Rectangle {
                            anchors.fill: parent
                            radius: Constants.sizeLg
                            color: hoverHandlerD.hovered ? Theme.bgSecondary : "transparent"

                            Behavior on color {
                                ColorAnimation {
                                    duration: Constants.animFast
                                }

                            }

                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Constants.sizeSm
                            anchors.rightMargin: Constants.sizeSm
                            spacing: Constants.sizeSm

                            SvgIcon {
                                icon: root.isOutput ? "volume" : "microphone"
                                iconColor: deviceItem.isActive ? Theme.accent : Theme.fg
                                iconSize: Constants.sizeLg
                                flat: true
                                opacity: deviceItem.isActive ? 1 : 0.7
                            }

                            ThemedText {
                                text: modelData.description || modelData.nickname || modelData.name
                                color: deviceItem.isActive ? Theme.accent : Theme.fg
                                font.pixelSize: Constants.sizeSm
                                font.bold: deviceItem.isActive
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                visible: deviceItem.isActive
                                radius: 4
                                implicitWidth: statusText.implicitWidth + Constants.sizeXs
                                implicitHeight: statusText.implicitHeight + 2
                                color: Theme.bgSecondary

                                ThemedText {
                                    id: statusText

                                    anchors.centerIn: parent
                                    text: "Default"
                                    font.pixelSize: Constants.sizeXs - 1
                                    font.bold: true
                                    color: Theme.accent
                                }

                            }

                        }

                        HoverHandler {
                            id: hoverHandlerD
                        }

                        TapHandler {
                            onTapped: {
                                root.pendingActiveId = modelData.id;
                                if (root.isOutput)
                                    Pipewire.preferredDefaultAudioSink = modelData;
                                else
                                    Pipewire.preferredDefaultAudioSource = modelData;
                            }
                        }

                    }

                }

            }

        }

    }

    transform: Translate {
        y: root.expanded ? 0 : -Constants.sizeSm

        Behavior on y {
            NumberAnimation {
                duration: Constants.animNormal
                easing.type: Easing.OutCubic
            }

        }

    }

    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: Constants.animNormal
            easing.type: Easing.OutCubic
        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: Constants.animNormal
            easing.type: Easing.OutCubic
        }

    }

}
