import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Core
import qs.Core.Components
import qs.Core.Services

BarButton {
    id: root

    implicitWidth: hLayout.implicitWidth + 24
    implicitHeight: 32
    color: Theme.bgSecondary

    RowLayout {
        id: hLayout

        anchors.centerIn: parent
        spacing: Constants.sizeSm

        Repeater {
            model: 10

            Rectangle {
                id: wsItemH

                readonly property int wsId: index + 1
                readonly property var workspace: Hyprland.workspaces.values.find((ws) => {
                    return ws.id === wsId;
                })
                readonly property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === wsId : false
                readonly property bool hasWindows: workspace !== undefined && workspace.toplevels.values.length > 0

                visible: hasWindows || isActive
                Layout.preferredWidth: visible ? 22 : 0
                Layout.preferredHeight: 22
                radius: Constants.sizeSm
                color: mouseAreaH.containsMouse ? Theme.bgTertiary : (isActive ? Theme.accent : "transparent")
                scale: mouseAreaH.pressed ? 0.9 : (mouseAreaH.containsMouse ? 1.05 : 1)

                ThemedText {
                    anchors.centerIn: parent
                    text: wsItemH.wsId
                    font.bold: wsItemH.isActive
                    font.pixelSize: Constants.sizeSm
                    color: wsItemH.isActive ? Theme.bg : (wsItemH.hasWindows ? Theme.fg : Theme.muted)
                }

                MouseArea {
                    id: mouseAreaH

                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch('hl.dsp.focus({workspace=' + wsId + '})')
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Constants.animFast
                    }

                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Constants.animFast
                        easing.type: Easing.OutQuad
                    }

                }

            }

        }

    }

}
