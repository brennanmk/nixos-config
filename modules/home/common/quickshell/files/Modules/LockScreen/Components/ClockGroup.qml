import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Components
import qs.Core.Services

RowLayout {
    spacing: Constants.sizeLg

    Text {
        text: Qt.formatTime(SystemInfoService.currentTime, "hh:mm")
        font.family: Constants.fontFamily
        font.pixelSize: Constants.size4Xl
        font.bold: true
        color: Theme.fg
    }

    Divider {
        vertical: true
        Layout.preferredHeight: Constants.size2Xl
    }

    Text {
        text: Qt.formatDate(SystemInfoService.currentTime, "ddd, d MMM yyyy")
        font.family: Constants.fontFamily
        font.pixelSize: Constants.sizeLg
        color: Theme.muted
    }

}
