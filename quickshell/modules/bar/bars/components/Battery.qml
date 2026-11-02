import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

import qs.utils

// Battery level + charging indicator. Reads Quickshell's built-in UPower
// integration, so it needs the upower daemon running on the system.
Item {
  id: root

  Layout.preferredWidth: parent.width
  Layout.preferredHeight: 72
  Layout.alignment: Qt.AlignHCenter

  readonly property var device: UPower.displayDevice
  readonly property real pct: device?.percentage ?? 0
  readonly property bool charging: device?.state === UPowerDeviceState.Charging
  readonly property bool low: pct < 0.15 && !charging

  ColumnLayout {
    anchors.centerIn: parent
    spacing: 4

    Rectangle {
      id: body
      Layout.alignment: Qt.AlignHCenter
      width: 26
      height: 44
      radius: 8
      color: "transparent"
      border.color: Theme.mainColor
      border.width: 2

      // Nub on top of the battery outline.
      Rectangle {
        width: 10
        height: 4
        radius: 1
        color: Theme.mainColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -5
      }

      // Fill level. Hidden on hover, swapped for the percentage text below.
      Rectangle {
        visible: !hoverArea.containsMouse
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 4
        height: (parent.height - 8) * root.pct
        radius: 3
        color: root.low ? "#e06c75" : Theme.mainColor

        Behavior on height { NumberAnimation { duration: 300 } }
      }

      // Little bolt overlay while charging (hidden along with the fill
      // on hover, so it doesn't clash with the percentage text).
      Text {
        visible: root.charging && !hoverArea.containsMouse
        text: "\u26A1"
        color: Theme.accentColor
        font.pixelSize: 19
        anchors.centerIn: parent
      }

      // Percentage, shown in place of the fill/bolt while hovering.
      Text {
        visible: hoverArea.containsMouse
        anchors.centerIn: parent
        text: Math.round(root.pct * 100)
        color: root.low ? "#e06c75" : Theme.mainColor
        font.pixelSize: 13
        font.weight: 700
      }

      MouseArea {
        id: hoverArea
        anchors.fill: parent
        anchors.margins: -6
        hoverEnabled: true
      }
    }
  }

  // Wire this up to whatever battery/power stats tool you use, e.g.:
  // MouseArea {
  //   anchors.fill: parent
  //   onClicked: Quickshell.execDetached(["your-battery-monitor"])
  // }
}
