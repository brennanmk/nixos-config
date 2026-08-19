import "Components"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Core.Components
import qs.Core.Services
import qs.Core.Windows

Item {
    id: root

    property bool quickSettingsOpen: false
    property var notificationService
    property int activePageIndex: 0

    signal requestClose()

    function openNetworkSettings(tab) {
        AppState.pendingSettingsTab = tab;
        AppState.openPopup("minflair_settings");
        root.requestClose();
    }

    implicitWidth: mainPage.implicitWidth
    implicitHeight: {
        if (activePageIndex === 0)
            return mainPage.implicitHeight;

        if (activePageIndex === 1)
            return audioOutputPage.implicitHeight;

        return audioInputPage.implicitHeight;
    }

    Item {
        id: stackContainer

        width: parent.width
        implicitHeight: root.implicitHeight
        clip: true

        ColumnLayout {
            id: mainPage

            width: parent.width
            spacing: Constants.sizeLg
            x: root.activePageIndex === 0 ? 0 : -parent.width
            visible: x > -parent.width

            Card {
                id: mainCard

                Layout.fillWidth: true

                ColumnLayout {
                    id: innerCol

                    anchors.fill: parent
                    spacing: Constants.sizeLg

                    RowLayout {
                        id: topControlsRow

                        Layout.fillWidth: true
                        spacing: Constants.sizeLg

                        WifiControl {
                            id: wifiControl

                            Layout.fillWidth: true
                            onMenuClicked: root.openNetworkSettings(3)
                        }

                        BluetoothControl {
                            id: btControl

                            Layout.fillWidth: true
                            onMenuClicked: root.openNetworkSettings(5)
                        }

                    }

                    GridLayout {
                        id: bottomControlsRow

                        Layout.alignment: Qt.AlignHCenter
                        columns: 4
                        rowSpacing: Constants.sizeLg
                        columnSpacing: Constants.sizeLg

                        VolumeControl {
                            id: volControl

                            onMenuClicked: root.activePageIndex = 1
                        }

                        MicControl {
                            id: micBtn

                            onMenuClicked: root.activePageIndex = 2
                        }

                        CaffeineControl {
                            id: caffeineBtn
                        }

                        NightLightControl {
                            id: nightLightBtn
                        }

                        GameModeControl {
                            id: gamepadBtn
                        }

                        RecordControl {
                            id: recordBtn
                        }

                        DndControl {
                            id: dndBtn

                            notificationService: root.notificationService
                        }

                    }

                    ColumnLayout {
                        id: sliderCol

                        Layout.fillWidth: true
                        spacing: Constants.sizeLg

                        VolumeSlider {
                            volume: volControl.volume
                            muted: volControl.muted
                            onMoved: (val) => {
                                return volControl.setVolume(val);
                            }
                            onIconClicked: volControl.toggleMute()
                        }

                        ThemedSlider {
                            id: micSlider

                            sliderEnabled: !AudioService.micMuted
                            value: AudioService.micVolume
                            icon: AudioService.micMuted ? "microphone-off" : "microphone"
                            onMoved: (val) => {
                                AudioService.setMicVolume(val);
                            }
                            onIconClicked: AudioService.setMicMuted(!AudioService.micMuted)
                        }

                        BrightnessSlider {
                            // brightnessctl only controls a laptop panel's
                            // backlight, not external DisplayPort/HDMI monitors.
                            visible: Quickshell.env("QS_IS_LAPTOP") === "1"
                        }

                    }

                }

            }

            Behavior on x {
                NumberAnimation {
                    duration: Constants.animNormal
                    easing.type: Easing.OutCubic
                }

            }

        }

        Card {
            id: audioOutputPage

            width: parent.width
            x: root.activePageIndex === 1 ? 0 : parent.width
            visible: x < parent.width

            ColumnLayout {
                anchors.fill: parent
                spacing: Constants.sizeLg

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Constants.sizeSm

                    SvgIconButton {
                        icon: "chevron-left"
                        iconSize: Constants.sizeLg
                        flat: true
                        onClicked: root.activePageIndex = 0
                    }

                    ThemedText {
                        text: "Output Device"
                        font.pixelSize: Constants.sizeLg
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                }

                AudioDeviceList {
                    Layout.fillWidth: true
                    expanded: root.activePageIndex === 1
                    isOutput: true
                }

            }

            Behavior on x {
                NumberAnimation {
                    duration: Constants.animNormal
                    easing.type: Easing.OutCubic
                }

            }

        }

        Card {
            id: audioInputPage

            width: parent.width
            x: root.activePageIndex === 2 ? 0 : parent.width
            visible: x < parent.width
            backgroundColor: Theme.bgSecondary

            ColumnLayout {
                anchors.fill: parent
                spacing: Constants.sizeLg

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Constants.sizeSm

                    SvgIconButton {
                        icon: "chevron-left"
                        iconSize: Constants.sizeLg
                        flat: true
                        onClicked: root.activePageIndex = 0
                    }

                    ThemedText {
                        text: "Input Device"
                        font.pixelSize: Constants.sizeLg
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                }

                AudioDeviceList {
                    Layout.fillWidth: true
                    expanded: root.activePageIndex === 2
                    isOutput: false
                }

            }

            Behavior on x {
                NumberAnimation {
                    duration: Constants.animNormal
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

}
