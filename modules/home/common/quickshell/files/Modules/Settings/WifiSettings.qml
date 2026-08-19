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
        title: "Wi-Fi"
        icon: "wifi"

        SettingToggle {
            id: wifiToggle

            label: "Wi-Fi"
            description: wifiControl.currentSsid
            checked: wifiControl.isActive
            onCheckedChanged: {
                if (checked !== wifiControl.isActive)
                    wifiControl.toggle();

            }

            Binding {
                target: wifiToggle
                property: "checked"
                value: wifiControl.isActive
            }

        }

        WifiControl {
            id: wifiControl

            visible: false
            expanded: true
        }

        Divider {
        }

        WifiList {
            id: wifiListView

            Layout.fillWidth: true
            expanded: wifiControl.isActive
            isActive: wifiControl.isActive
            wifiList: wifiControl.wifiList
            onConnect: (ssid, password) => {
                return wifiControl.connect(ssid, password);
            }

            Connections {
                function onConnectFailed(ssid, message) {
                    wifiListView.errorSsid = ssid;
                    wifiListView.errorText = message;
                }

                function onConnectSucceeded(ssid) {
                    if (wifiListView.pendingSsid === ssid)
                        wifiListView.pendingSsid = "";

                }

                target: wifiControl
            }

        }

    }

}
