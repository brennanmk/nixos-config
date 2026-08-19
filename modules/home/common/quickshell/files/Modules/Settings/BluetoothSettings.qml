import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core
import qs.Core.Components
import qs.Modules.ControlCenter.Widgets.QuickSettings.Components
import qs.Modules.Settings.Components

SettingContainer {
    id: root

    SettingGroup {
        title: "Bluetooth"
        icon: "bluetooth"

        SettingToggle {
            id: btToggle

            label: "Bluetooth"
            description: btControl.subtitle
            checked: btControl.isActive
            onCheckedChanged: {
                if (checked !== btControl.isActive)
                    btControl.toggle();

            }

            Binding {
                target: btToggle
                property: "checked"
                value: btControl.isActive
            }

        }

        BluetoothControl {
            id: btControl

            visible: false
            expanded: true
        }

        Divider {
        }

        BluetoothList {
            Layout.fillWidth: true
            expanded: btControl.isActive
            isActive: btControl.isActive
            btList: btControl.btList
            onConnect: (mac) => {
                return btControl.connect(mac);
            }
        }

    }

}
