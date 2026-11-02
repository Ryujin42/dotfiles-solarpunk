import Quickshell
import Quickshell.Io 
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.utils
import "bars" as B


PanelWindow {
  id: bar

  visible: false

  anchors {
    top: true
    left: true
    bottom: true
    right: true
  }

  color: "transparent"

  B.BarLeft {}
  B.BarTop {}
}