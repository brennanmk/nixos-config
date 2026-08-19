import "./Components"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Core
import qs.Core.Components
import qs.Core.Services

Item {
    id: root

    property string typedPassword: ""
    property bool authFailed: false
    property bool authenticating: false
    property bool unlocking: false

    // Every caller of this (hypridle's idle timeout, the lock keybind, the
    // PowerMenu lock button) only ever wants to lock, never unlock -- the
    // only path that should ever set locked back to false is a successful
    // password submission (see submitPassword/authProc below). Toggling
    // here previously meant a second idle-timeout firing while already
    // locked would flip the session back to unlocked with no password.
    function forceLock() {
        if (!lockManager.locked) {
            root.typedPassword = "";
            root.authFailed = false;
            root.unlocking = false;
            lockManager.locked = true;
        }
    }

    function submitPassword(pwd) {
        if (root.authenticating)
            return ;

        authProc.running = false;
        root.authenticating = true;
        root.authFailed = false;
        authProc.command = ["python3", Quickshell.env("HOME") + "/.config/quickshell/Scripts/auth.py", pwd];
        authProc.running = true;
    }

    Component.onCompleted: {
        socketCleanup.running = true;
    }

    SocketServer {
        id: server

        path: "/tmp/quickshell_lockScreen"
        active: false

        handler: Component {
            Socket {
                onConnectedChanged: {
                    if (connected) {
                        root.forceLock();
                        connected = false;
                    }
                }
            }

        }

    }

    Process {
        id: socketCleanup

        command: ["rm", "-f", "/tmp/quickshell_lockScreen"]
        onExited: function(exitCode) {
            server.active = true;
        }
    }

    Process {
        id: authProc

        onExited: function(exitCode) {
            if (!root.authenticating)
                return ;

            root.authenticating = false;
            if (exitCode === 0) {
                root.unlocking = true;
            } else {
                root.authFailed = true;
                root.typedPassword = "";
            }
        }
    }

    WlSessionLock {
        id: lockManager

        onLockedChanged: {
            if (locked) {
                root.typedPassword = "";
                root.authFailed = false;
                root.authenticating = false;
                root.unlocking = false;
            }
        }

        WlSessionLockSurface {
            id: lockSurface

            readonly property string primaryMonitor: Quickshell.env("QS_PRIMARY_MONITOR")
            readonly property bool showContent: primaryMonitor === "" || (screen && screen.name === primaryMonitor)

            Rectangle {
                id: mainOverlay

                property bool ready: false

                Component.onCompleted: ready = true
                anchors.fill: parent
                color: Theme.bg
                opacity: 1
                state: root.unlocking ? "unlocking" : (ready ? "locked" : "hidden")
                states: [
                    State {
                        name: "hidden"

                        PropertyChanges {
                            target: dimOverlay
                            opacity: 1
                        }

                        PropertyChanges {
                            target: mainContent
                            opacity: 0
                            scale: 1.05
                        }

                        PropertyChanges {
                            target: topLeftGroup
                            opacity: 0
                        }

                        PropertyChanges {
                            target: topLeftTranslate
                            y: -30
                        }

                        PropertyChanges {
                            target: centerGroup
                            opacity: 0
                        }

                        PropertyChanges {
                            target: centerGroupTranslate
                            y: 30
                        }

                    },
                    State {
                        name: "locked"

                        PropertyChanges {
                            target: dimOverlay
                            opacity: 0
                        }

                        PropertyChanges {
                            target: mainContent
                            opacity: 1
                            scale: 1
                        }

                        PropertyChanges {
                            target: topLeftGroup
                            opacity: 1
                        }

                        PropertyChanges {
                            target: topLeftTranslate
                            y: 0
                        }

                        PropertyChanges {
                            target: centerGroup
                            opacity: 1
                        }

                        PropertyChanges {
                            target: centerGroupTranslate
                            y: 0
                        }

                    },
                    State {
                        name: "unlocking"

                        PropertyChanges {
                            target: dimOverlay
                            opacity: 0
                        }

                        PropertyChanges {
                            target: mainContent
                            opacity: 0
                            scale: 0.95
                        }

                        PropertyChanges {
                            target: topLeftGroup
                            opacity: 0
                        }

                        PropertyChanges {
                            target: topLeftTranslate
                            y: -20
                        }

                        PropertyChanges {
                            target: centerGroup
                            opacity: 0
                        }

                        PropertyChanges {
                            target: centerGroupTranslate
                            y: 20
                        }

                    }
                ]
                transitions: [
                    Transition {
                        from: "hidden"
                        to: "locked"

                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation {
                                    target: dimOverlay
                                    property: "opacity"
                                    duration: Constants.animExpressive * 1.5
                                    easing.type: Easing.OutExpo
                                }

                                NumberAnimation {
                                    target: mainContent
                                    properties: "opacity,scale"
                                    duration: Constants.animExpressive * 1.5
                                    easing.type: Easing.OutExpo
                                }

                                NumberAnimation {
                                    targets: [topLeftGroup, centerGroup]
                                    property: "opacity"
                                    duration: Constants.animExpressive * 1.5
                                    easing.type: Easing.OutExpo
                                }

                                NumberAnimation {
                                    target: topLeftTranslate
                                    property: "y"
                                    duration: Constants.animExpressive * 1.5
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 1.2
                                }

                                NumberAnimation {
                                    target: centerGroupTranslate
                                    property: "y"
                                    duration: Constants.animExpressive * 1.5
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 1.2
                                }

                            }

                            ScriptAction {
                                script: {
                                    if (lockSurface.showContent)
                                        authBox.forceFocus();
                                }
                            }

                        }

                    },
                    Transition {
                        to: "unlocking"

                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation {
                                    target: mainContent
                                    properties: "opacity,scale"
                                    duration: Constants.animExpressive
                                    easing.type: Easing.OutCubic
                                }

                                NumberAnimation {
                                    targets: [dimOverlay, topLeftGroup, centerGroup]
                                    property: "opacity"
                                    duration: Constants.animExpressive
                                    easing.type: Easing.OutCubic
                                }

                                NumberAnimation {
                                    target: topLeftTranslate
                                    property: "y"
                                    duration: Constants.animExpressive
                                    easing.type: Easing.OutCubic
                                }

                                NumberAnimation {
                                    target: centerGroupTranslate
                                    property: "y"
                                    duration: Constants.animExpressive
                                    easing.type: Easing.OutCubic
                                }

                            }

                            ScriptAction {
                                script: lockManager.locked = false
                            }

                        }

                    }
                ]

                Background {
                    id: bgRect

                    anchors.fill: parent
                }

                Rectangle {
                    id: dimOverlay

                    anchors.fill: parent
                    color: Theme.bg
                    opacity: 0
                }

                Item {
                    id: mainContent

                    anchors.fill: parent
                    visible: lockSurface.showContent

                    TopLeftGroup {
                        id: topLeftGroup

                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: Constants.size5Xl * 1.2

                        transform: Translate {
                            id: topLeftTranslate
                        }

                    }

                    ColumnLayout {
                        id: centerGroup

                        anchors.centerIn: parent
                        spacing: Constants.size5Xl * 0.7

                        transform: Translate {
                            id: centerGroupTranslate
                        }

                        ClockGroup {
                            Layout.alignment: Qt.AlignHCenter
                        }

                        AuthBox {
                            id: authBox

                            Layout.alignment: Qt.AlignHCenter
                            backgroundItem: bgRect
                            typedPassword: root.typedPassword
                            authFailed: root.authFailed
                            authenticating: root.authenticating
                            locked: lockManager.locked
                            onPasswordChanged: (text) => {
                                root.typedPassword = text;
                                if (text.length > 0)
                                    root.authFailed = false;

                            }
                            onSubmitPassword: (pwd) => {
                                root.submitPassword(pwd);
                            }
                            onClearRequested: () => {
                                root.typedPassword = "";
                                root.authFailed = false;
                            }
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        onClicked: {
                            root.typedPassword = "";
                            root.authFailed = false;
                            authBox.forceFocus();
                        }
                    }

                }

            }

        }

    }

}
