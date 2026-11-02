import QtQuick
import QtQuick.Layouts

import qs.utils

// Horizontal HH:MM clock with a colon that flickers once a second, like a
// classic digital clock. Uses a plain Timer + Date, no Quickshell-specific
// clock service, so no extra dependencies.
Item {
  id: root

  // Explicit size so this behaves inside a RowLayout — an Item's implicit
  // size is 0x0, and relying on children alone was what caused it to
  // collapse the rest of the bar earlier.
  Layout.preferredWidth: row.implicitWidth
  Layout.preferredHeight: Theme.iconSizeMd
  Layout.alignment: Qt.AlignVCenter

  property date now: new Date()
  property bool colonOn: true

  // Updates the displayed time, aligned to the start of each minute.
  Timer {
    interval: 1000 * (60 - root.now.getSeconds())
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.now = new Date()
  }

  // Flickers the colon every second, independent of the minute-aligned
  // clock update above.
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.colonOn = !root.colonOn
  }

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: 2

    Text {
      text: Qt.formatTime(root.now, "hh")
      color: Theme.mainColor
      style: Text.Outline
      styleColor: Theme.accentColor
      font.pixelSize: Theme.fontSizeLg
      font.weight: 600
    }

    Text {
      text: ":"
      color: Theme.mainColor
      style: Text.Outline
      styleColor: Theme.accentColor
      font.pixelSize: Theme.fontSizeLg
      font.weight: 600
      opacity: root.colonOn ? 1 : 0.15

      Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Text {
      text: Qt.formatTime(root.now, "mm")
      color: Theme.mainColor
      style: Text.Outline
      styleColor: Theme.accentColor
      font.pixelSize: Theme.fontSizeLg
      font.weight: 600
    }
  }

  // Hover for the full date — swap for a Tooltip type if you have one.
  MouseArea {
    id: hoverArea
    anchors.fill: parent
    hoverEnabled: true
  }

  Text {
    visible: hoverArea.containsMouse
    text: Qt.formatDate(root.now, "dddd, MMM d")
    color: Theme.mainColor
    font.pixelSize: 10
    anchors.top: parent.bottom
    anchors.topMargin: 6
    anchors.horizontalCenter: parent.horizontalCenter
  }
}
