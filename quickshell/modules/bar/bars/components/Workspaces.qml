import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland

import qs.utils

// A thin vertical strip for the left screen edge: a graduated "ruler" of
// workspace ticks (with the active workspace labelled, e.g. "02"), and a
// battery gauge pinned to the bottom.

Item {
  id: root

  // Grows past 5 once more workspaces are actually active.
  readonly property int workspaceCount: {
    let maxId = 5
    if (Hyprland.focusedWorkspace)
      maxId = Math.max(maxId, Hyprland.focusedWorkspace.id)

    for (const ws of Hyprland.workspaces.values) {
      const windowCount = ws.toplevels?.values?.length ?? 0
      if (windowCount > 0)
        maxId = Math.max(maxId, ws.id)
    }

    return maxId
  }

  // Distance between two tick centers (unchanged from your 220/5 = 44).
  readonly property real tickSpacing: 44

  // Gap from the line's top/bottom edge to the first/last tick.
  // Was tickSpacing/2 (half a cell) when centered in a uniform Column;
  // doubled here to a full tickSpacing.
  readonly property real edgeGap: tickSpacing

  Layout.preferredWidth: parent.width
  // Height now derives from workspaceCount + the doubled edge gaps, so the
  // whole ruler grows instead of squeezing existing ticks closer together.
  Layout.preferredHeight: edgeGap * 2 + (workspaceCount - 1) * tickSpacing
  Layout.alignment: Qt.AlignHCenter

  Rectangle {
    width: parent.width
    height: 4
    anchors.left: parent.horizontalCenter
    anchors.top: parent.top
    anchors.leftMargin: -42
    color: Theme.mainColor
    opacity: 1
  }

  Rectangle {
    width: 4
    height: parent.height
    anchors.left: parent.horizontalCenter
    anchors.leftMargin: -6
    color: Theme.mainColor
    opacity: 1
  }

  Rectangle {
    width: parent.width
    height: 4
    anchors.left: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.leftMargin: -42
    color: Theme.mainColor
    opacity: 1
  }

  // Ticks are now positioned explicitly by y instead of living in a Column,
  // since a Column can only give you uniform cell spacing — it can't make
  // the edge gaps different from the inter-tick gaps.
  Repeater {
    model: root.workspaceCount

    Item {
      width: root.width
      height: root.tickSpacing
      y: root.edgeGap + index * root.tickSpacing - height / 2

      readonly property int wsId: index + 1
      readonly property bool active:
          wsId === (Hyprland.focusedWorkspace?.id ?? 1)

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: active ? -21 : -13
        width: active ? 16 : 8
        height: active ? 4 : 2
        radius: 1
        color: Theme.mainColor
        opacity: 1
      }

      Text {
        visible: active
        text: String(wsId).padStart(2, "0")
        color: Theme.mainColor
        style: (wsId === 1 || wsId === 2) ? Text.Outline : Text.Normal
        styleColor: (wsId === 1 || wsId === 2) ? Theme.accentColor : Theme.mainColor
        font.pixelSize: 18
        font.weight: 600
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
      }

      MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch(
          'hl.dsp.focus({ workspace = ' + wsId + ' })'
        )
        onWheel: {
          if (wheel.angleDelta.y > 0) Hyprland.dispatch("hl.dsp.focus({ workspace = \"r-1\"})")
          else if (wheel.angleDelta.y < 0) Hyprland.dispatch("hl.dsp.focus({ workspace = \"r+1\"})")
        }
      }
    }
  }
}