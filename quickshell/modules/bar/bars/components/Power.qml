import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import qs.utils
import qs.popups

// Power glyph that toggles the PowerMenu popup (see popups/PowerMenu.qml).
Item {
  id: root

  Layout.preferredWidth: Theme.iconSizeMd
  Layout.preferredHeight: Theme.iconSizeMd
  Layout.alignment: Qt.AlignHCenter

  property bool expanded: false

  Text {
    id: icon
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    text: "\u23fb" // power glyph
    font.pixelSize: 22
    color: root.expanded ? Theme.accentColor : Theme.mainColor

    MouseArea {
      anchors.fill: parent
      anchors.margins: -8
      onClicked: PowerMenu.toggle()
    }
  }
}
