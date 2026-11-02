import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.utils

Button {
  id: launcher
  width: Theme.IconSizeMd
  height: Theme.IconSizeMd

  background: Rectangle {
    color: "transparent"
  }

  Text {
    anchors.centerIn: parent
    text: "󰋘"
    color: Theme.mainColor
    font.pixelSize: Theme.fontSizeXl
  }

  Process {
    id: wofiTrigger
    command: ["wofi", "--show", "drun"]
  }

  onClicked: wofiTrigger.running = true
}
