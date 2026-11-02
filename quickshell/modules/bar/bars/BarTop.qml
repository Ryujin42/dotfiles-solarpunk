import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.utils
import "components" as C

PanelWindow {
  id: bartop

  implicitHeight: Theme.barWidth // reuse the same thickness as the left bar
  color: "transparent"
  visible: true

  anchors {
    top: true
    left: true
    right: true
  }

  RowLayout {
    anchors {
      fill: parent
      margins: Theme.spacingMd
      // Avoid overlapping the left sidebar. Drop this if barleft doesn't
      // reserve screen space (e.g. it's set to an overlay/exclusive-zone-0
      // layer), since in that case nothing needs to shift right.
      leftMargin: Theme.barWidth + Theme.spacingLg
      rightMargin: Theme.spacingLg
    }
    spacing: Theme.spacingSm

    // Pushes everything that follows to the right-hand side of the bar.
    Item { Layout.fillWidth: true }

    C.Weather {
      Layout.preferredHeight: Theme.iconSizeMd
      Layout.alignment: Qt.AlignVCenter
    }

    C.Clock {
      Layout.preferredHeight: Theme.iconSizeMd
      Layout.alignment: Qt.AlignVCenter
    }

    C.Volume {
      Layout.preferredHeight: Theme.iconSizeMd
      Layout.preferredWidth: Theme.iconSizeMd
      Layout.alignment: Qt.AlignVCenter
    }

    C.Wifi {
      Layout.preferredHeight: Theme.iconSizeMd
      Layout.preferredWidth: Theme.iconSizeMd
      Layout.alignment: Qt.AlignVCenter
    }

    C.Bluetooth {
      Layout.preferredHeight: Theme.iconSizeMd
      Layout.preferredWidth: Theme.iconSizeMd
      Layout.alignment: Qt.AlignVCenter
    }

    C.Notification {
      Layout.preferredHeight: Theme.iconSizeMd
      Layout.preferredWidth: Theme.iconSizeMd
      Layout.alignment: Qt.AlignVCenter
    }

    // Kept last in the RowLayout so it lands at the far right edge.
    C.Power {
      Layout.preferredHeight: Theme.iconSizeMd
      Layout.preferredWidth: Theme.iconSizeMd
      Layout.alignment: Qt.AlignVCenter
    }
  }
}
