import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Core
import qs.Core.Components
import qs.Core.Services
import qs.Core.Windows
import qs.Modules.ControlCenter.Widgets.QuickSettings

TopPopup {
    id: root

    property var notificationService

    popupId: "controlCenter"
    backgroundColor: Theme.bg
    // Include the same content-padding + corner-radius insets TopPopup's
    // own popupWidth/popupHeight would add, since squareRightCorners means
    // the right inset is contentPadding-only (see TopPopup innerLayout.rightInset).
    preferredWidth: quickSettings.implicitWidth + root.contentPadding * 2 + root.cornerRadius
    preferredHeight: quickSettings.implicitHeight + root.contentPadding * 2
    alignRight: true
    squareRightCorners: true
    // Wi-Fi/Bluetooth status text updates asynchronously (nmcli polling)
    // while this popup is open, which nudges row widths. Animating the
    // popup's size in that situation causes content to overflow past a
    // still-growing background (see TopPopup.animateSize).
    animateSize: false

    QuickSettings {
        id: quickSettings

        quickSettingsOpen: root.isOpen
        notificationService: root.notificationService
        onRequestClose: root.isOpen = false
    }

    // TopPopup (unlike PopupLoader) doesn't create the /tmp/quickshell_*
    // IPC socket on its own -- replicate it here so Ctrl+Alt+S and the
    // toggle_minflair_* -style socat triggers keep working.
    Component.onCompleted: {
        socketCleanup.running = true;
    }

    SocketServer {
        id: server

        path: "/tmp/quickshell_controlCenter"
        active: false

        handler: Component {
            Socket {
                onConnectedChanged: {
                    if (connected) {
                        AppState.togglePopup("controlCenter");
                        connected = false;
                    }
                }
            }

        }

    }

    Process {
        id: socketCleanup

        command: ["rm", "-f", "/tmp/quickshell_controlCenter"]
        onExited: function(exitCode) {
            server.active = true;
        }
    }

}
