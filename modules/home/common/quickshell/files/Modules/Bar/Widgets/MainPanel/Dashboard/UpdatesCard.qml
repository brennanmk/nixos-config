import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Core.Components
import qs.Core.Services

Card {
    id: root

    readonly property var outdatedInputs: UpdateService.outdatedInputs || []
    readonly property int outdatedCount: outdatedInputs.length
    readonly property bool hasUpdates: outdatedCount > 0
    readonly property bool isChecking: UpdateService.isCheckingUpdates

    ColumnLayout {
        anchors.fill: parent
        spacing: Constants.sizeSm

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeSm

            ThemedText {
                text: "Flake Updates"
                font.pixelSize: Constants.sizeMd
                font.bold: true
                color: Theme.fg
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                visible: root.hasUpdates && !root.isChecking
                color: Theme.bgSecondary
                radius: height / 2
                implicitWidth: updateCountText.implicitWidth + 12
                implicitHeight: 18

                ThemedText {
                    id: updateCountText

                    anchors.centerIn: parent
                    text: root.outdatedCount + " NEW"
                    font.pixelSize: Constants.sizeXs
                    font.bold: true
                    color: Theme.accent
                }

            }

        }

        Divider {
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeMd

            RowLayout {
                spacing: Constants.sizeSm
                Layout.fillWidth: true

                SvgIcon {
                    id: statusIcon

                    icon: root.isChecking ? "reload" : (root.hasUpdates ? "update" : "check")
                    flat: true
                    iconColor: Theme.accent

                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: root.isChecking
                        onRunningChanged: {
                            if (!running)
                                statusIcon.rotation = 0;

                        }
                    }

                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    ThemedText {
                        text: {
                            if (root.isChecking)
                                return "Checking flake inputs...";

                            return root.hasUpdates ? root.outdatedCount + " input" + (root.outdatedCount === 1 ? "" : "s") + " outdated" : "Flake is up to date";
                        }
                        font.pixelSize: Constants.sizeSm
                        font.bold: true
                        color: Theme.fg
                    }

                    ThemedText {
                        text: {
                            if (root.isChecking)
                                return "Please wait";

                            return root.hasUpdates ? root.outdatedInputs.join(", ") : "nix flake update whenever you're ready";
                        }
                        font.pixelSize: Constants.sizeXs
                        color: Theme.muted
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

            ThemedButton {
                id: updateButton

                text: "Check"
                onClicked: UpdateService.checkUpdates()
            }

        }

    }

}
