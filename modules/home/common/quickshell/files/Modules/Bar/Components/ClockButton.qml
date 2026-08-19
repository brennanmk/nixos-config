import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Components
import qs.Core.Services

Rectangle {
    id: root

    required property var widget
    property bool isHovered: clockHoverHandler.hovered
    property bool isPressed: clockTapHandler.pressed

    color: isHovered || isPressed ? Theme.bgTertiary : "transparent"
    radius: Constants.sizeLg
    implicitWidth: mainLayout.implicitWidth + (Constants.sizeLg * 2)
    implicitHeight: 32
    scale: isPressed ? 0.95 : (isHovered ? 1.02 : 1)

    TapHandler {
        id: clockTapHandler

        onTapped: {
            if (root.widget)
                root.widget.isOpen = !root.widget.isOpen;
        }
    }

    HoverHandler {
        id: clockHoverHandler

        cursorShape: Qt.PointingHandCursor
    }

    Behavior on color {
        ColorAnimation {
            duration: Constants.animFast
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: Constants.animFast
            easing.type: Easing.OutBack
        }

    }

    RowLayout {
        id: mainLayout

        anchors.centerIn: parent
        spacing: Constants.sizeXs

        ThemedText {
            text: Qt.formatDateTime(SystemInfoService.currentTime, "HH:mm")
            font.bold: true
            font.pixelSize: Constants.sizeSm
        }

        Divider {
            vertical: true
        }

        ThemedText {
            text: Qt.formatDateTime(SystemInfoService.currentTime, "ddd, d MMM")
            color: Theme.muted
            font.pixelSize: Constants.sizeSm
        }

    }

}
