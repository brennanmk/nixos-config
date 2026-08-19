import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.Core
import qs.Core.Components
import qs.Core.Services
import qs.Modules.ControlCenter.Widgets.QuickSettings.Components
import qs.Modules.Settings.Components

SettingContainer {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int volume: (sink && sink.audio) ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool muted: (sink && sink.audio) ? sink.audio.muted : false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    SettingGroup {
        title: "Volume"
        icon: "volume"

        VolumeSlider {
            Layout.fillWidth: true
            volume: root.volume
            muted: root.muted
            onMoved: (val) => {
                if (root.sink && root.sink.audio)
                    root.sink.audio.volume = val / 100;

            }
            onIconClicked: {
                if (root.sink && root.sink.audio)
                    root.sink.audio.muted = !root.sink.audio.muted;

            }
        }

        ThemedSlider {
            Layout.fillWidth: true
            sliderEnabled: !AudioService.micMuted
            value: AudioService.micVolume
            icon: AudioService.micMuted ? "microphone-off" : "microphone"
            onMoved: (val) => {
                AudioService.setMicVolume(val);
            }
            onIconClicked: AudioService.setMicMuted(!AudioService.micMuted)
        }

    }

    SettingGroup {
        title: "Output Device"
        icon: "volume"

        AudioDeviceList {
            Layout.fillWidth: true
            expanded: true
            isOutput: true
        }

    }

    SettingGroup {
        title: "Input Device"
        icon: "microphone"

        AudioDeviceList {
            Layout.fillWidth: true
            expanded: true
            isOutput: false
        }

    }

}
