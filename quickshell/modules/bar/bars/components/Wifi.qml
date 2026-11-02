import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

import qs.utils

// WiFi glyph reflecting connection state + rough signal strength.
//
// NOTE: Quickshell.Networking is a newer, less-documented module than
// Hyprland/UPower/Bluetooth. The property names below (activeAccessPoint,
// ssid, strength) are the ones exposed by WifiDevice as of recent
// Quickshell versions, but if this errors on load, run `qs -c <config> `
// with verbose logging or check `qmlls`/the in-editor LSP hints against
// your installed Quickshell version — the network module is still
// actively evolving.
Item {
  id: root

  Layout.preferredWidth: parent.width
  Layout.preferredHeight: 40
  Layout.alignment: Qt.AlignHCenter

  readonly property var wifiDevice: {
    for (const dev of Networking.devices.values) {
      if (dev.type === DeviceType.Wifi) return dev
    }
    return null
  }

  readonly property var sortedNetworks: root.wifiDevice
    ? root.wifiDevice.networks.values.slice().sort((a, b) => b.signalStrength - a.signalStrength)
    : []

  readonly property var activeAp: sortedNetworks?.[0] ?? null
  readonly property bool connected: sortedNetworks?.[0] !== null
  readonly property real strength: sortedNetworks?.[0]?.signalStrength * 100 ?? 0 // 0-100

  function glyph() {
    if (!root.wifiDevice) return "\uf05e"         // no adapter
    if (!root.connected) return "\udb82\udd2d"    // disconnected
    if (root.strength > 80) return "\udb82\udd28" // very strong
    if (root.strength > 60) return "\udb82\udd25" // strong
    if (root.strength > 40) return "\udb82\udd22" // medium
    if (root.strength > 20) return "\udb82\udd1f" // weak
    return "\udb82\udd2f"                         // very weak
  }

  ColumnLayout {
    anchors.centerIn: parent
    spacing: 2

    Text {
      Layout.alignment: Qt.AlignHCenter
      text: root.glyph()
      font.pixelSize: Theme.fontSizeLg
      color: Theme.mainColor
      opacity: root.connected ? 1 : 0.35
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: Quickshell.execDetached(["nm-connection-editor"])
  }
}
