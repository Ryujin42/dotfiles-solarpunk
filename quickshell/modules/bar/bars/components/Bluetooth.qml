import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

import qs.utils

// Bluetooth glyph that reflects adapter power + connected device count.
// Click toggles the adapter on/off.
Item {
  id: root

  Layout.preferredWidth: parent.width
  Layout.preferredHeight: 40
  Layout.alignment: Qt.AlignHCenter

  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property bool enabled: adapter?.enabled ?? false
  readonly property int connectedCount: {
    if (!adapter) return 0
    let n = 0
    for (const dev of adapter.devices.values) {
      if (dev.connected) n++
    }
    return n
  }

  ColumnLayout {
    anchors.centerIn: parent
    spacing: 2

    Text {
      Layout.alignment: Qt.AlignHCenter
      text: "\uf294" // nerd font bluetooth glyph
      font.pixelSize: Theme.fontSizeLg
      color: Theme.mainColor
      opacity: root.enabled ? 1 : 0.35
    }

    // Small dot badge when something is connected.
    Rectangle {
      visible: root.connectedCount > 0
      Layout.alignment: Qt.AlignHCenter
      width: 5
      height: 5
      radius: 2.5
      color: Theme.accentColor
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton) {
        if (root.adapter) root.adapter.enabled = !root.adapter.enabled
      } else {
        // Right-click: open your bluetooth settings UI of choice.
        Quickshell.execDetached(["blueman-manager"])
      }
    }
  }
}
