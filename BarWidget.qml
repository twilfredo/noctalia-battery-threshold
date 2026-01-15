import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

Rectangle {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    implicitWidth: contentRow.implicitWidth + Style.marginM * 2
    implicitHeight: Style.capsuleHeight

    color: Style.capsuleColor
    radius: Style.radiusL

    BatteryThresholdService {
        id: service
        pluginApi: root.pluginApi
    }

    NText {
        id: contentRow
        anchors.centerIn: parent
        text: "Battery Threshold"
        color: mouseArea.containsMouse ? Color.mOnHover : Color.mPrimary
        pointSize: Style.barFontSize
        font.weight: Font.Medium
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            root.color = Color.mHover
        }

        onExited: {
            root.color = Style.capsuleColor
        }

        onClicked: {
            if (pluginApi) {
                pluginApi.openPanel(root.screen)
            }
        }
    }
}
