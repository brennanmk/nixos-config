import Qt5Compat.GraphicalEffects
import QtQuick
import qs.Core
import qs.Core.Services
import qs.Core.Utils

Rectangle {
    id: bgRect

    property bool isDark: ColorUtils.isDark(Theme.bg)

    color: Theme.bg
    opacity: 1

    Image {
        id: wallpaperImage

        anchors.fill: parent
        source: WallpaperManager.currentWallpaperPath ? "file://" + WallpaperManager.currentWallpaperPath : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
        cache: false
    }

    FastBlur {
        anchors.fill: parent
        source: wallpaperImage
        radius: 96
        visible: wallpaperImage.status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        opacity: wallpaperImage.status === Image.Ready ? (bgRect.isDark ? 0.55 : 0.7) : 1
    }

}
