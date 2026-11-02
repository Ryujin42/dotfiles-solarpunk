pragma Singleton

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import qs.utils

// A HUD-styled power menu: four standalone angular boxes (not one shared
// panel), each with its own accent border + corner brackets, stacked
// under the top bar's power button. Boxes slide in from the right on
// open and slide back out on close, staggered per item.
//
// Singleton — toggle from anywhere via:
//   PowerMenu.toggle()
// (don't set PowerMenu.visible directly — that unmaps the window
// instantly with no time for the exit animation to play; requestedVisible
// is the state to drive instead, and toggle()/open()/close() manage it.)
//
// Needs a qmldir entry in this folder for the `qs.popups` import to
// resolve it as a singleton:
//   singleton PowerMenu PowerMenu.qml
PanelWindow {
  id: menu

  visible: false
  color: "transparent"

  // The "is this actually requested open" state, decoupled from the
  // real `visible` (which controls the Wayland surface directly and
  // can't be un-done mid-animation). Opening sets `visible = true`
  // immediately so there's a surface to animate into. Closing instead
  // starts the exit animation and only flips `visible = false` once
  // closeTimer fires, after every box has had time to finish sliding out.
  property bool requestedVisible: false

  function open() { requestedVisible = true }
  function close() { requestedVisible = false }
  function toggle() { requestedVisible = !requestedVisible }

  onRequestedVisibleChanged: {
    if (requestedVisible) {
      visible = true
    } else {
      closeTimer.start()
    }
  }

  Timer {
    id: closeTimer
    // Covers the slowest box's stagger delay + its slide duration, plus
    // a small buffer. If you change the per-box stagger (70) or slide
    // duration (220) below, update this to match or the window will
    // unmap slightly before/after the animation actually finishes.
    interval: (menu.actions.length - 1) * 70 + 220 + 30
    onTriggered: menu.visible = false
  }

  anchors {
    top: true
    right: true
  }

  margins {
    top: Theme.spacingMd
    right: Theme.spacingMd
  }

  implicitWidth: 220
  implicitHeight: content.implicitHeight

  readonly property var actions: [
    { glyph: "\uf456",       label: "LOCK",     cmd: ["hyprlock"] },
    { glyph: "\uf4ee",       label: "SUSPEND",  cmd: ["systemctl", "suspend"] },
    { glyph: "\uf2f1",       label: "REBOOT",   cmd: ["systemctl", "reboot"] },
    { glyph: "\u23FB",       label: "SHUTDOWN", cmd: ["systemctl", "poweroff"] },
  ]

  ColumnLayout {
    id: content
    anchors.fill: parent
    spacing: 10

    Repeater {
      model: menu.actions

      Rectangle {
        id: box
        Layout.fillWidth: true
        Layout.preferredHeight: 54
        color: hoverArea.containsMouse
          ? Qt.rgba(0.58, 0.886, 1, 0.8)
          : Qt.rgba(0.58, 0.886, 1, 0.3)
        border.color: Theme.accentColor
        border.width: 1
        radius: 2

        // Slide in/out via a Translate transform (rather than animating
        // x directly) so it doesn't fight with ColumnLayout, which
        // manages this item's real x/width itself.
        transform: Translate {
          id: slideTransform
          x: 60
        }

        SequentialAnimation {
          id: entrance
          PauseAnimation { duration: index * 70 }
          NumberAnimation {
            target: slideTransform
            property: "x"
            to: 0
            duration: 220
            easing.type: Easing.OutCubic
          }
        }

        SequentialAnimation {
          id: exit
          PauseAnimation { duration: (menu.actions.length - 1 - index) * 70 }
          NumberAnimation {
            target: slideTransform
            property: "x"
            to: 300
            duration: 220
            easing.type: Easing.InCubic
          }
        }

        Connections {
          target: menu
          function onRequestedVisibleChanged() {
            if (menu.requestedVisible) {
              slideTransform.x = 300
              entrance.start()
            } else {
              exit.start()
            }
          }
        }

        // Corner brackets for this box.
        Item {
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.topMargin: -2
          anchors.leftMargin: -2
          width: 12
          height: 12
          Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 8; height: 2; color: Theme.accentColor }
          Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 2; height: 8; color: Theme.accentColor }
        }
        Item {
          anchors.top: parent.top
          anchors.right: parent.right
          anchors.topMargin: -2
          anchors.rightMargin: -2
          width: 12
          height: 12
          Rectangle { anchors.top: parent.top; anchors.right: parent.right; width: 8; height: 2; color: Theme.accentColor }
          Rectangle { anchors.top: parent.top; anchors.right: parent.right; width: 2; height: 8; color: Theme.accentColor }
        }
        Item {
          anchors.bottom: parent.bottom
          anchors.left: parent.left
          anchors.bottomMargin: -2
          anchors.leftMargin: -2
          width: 12
          height: 12
          Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; width: 8; height: 2; color: Theme.accentColor }
          Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; width: 2; height: 8; color: Theme.accentColor }
        }
        Item {
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          anchors.bottomMargin: -2
          anchors.rightMargin: -2
          width: 12
          height: 12
          Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 8; height: 2; color: Theme.accentColor }
          Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 2; height: 8; color: Theme.accentColor }
        }

        // Sliding accent bar on hover.
        Rectangle {
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          width: 3
          color: Theme.accentColor
          opacity: hoverArea.containsMouse ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: 120 } }
        }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 16
          anchors.rightMargin: 12
          spacing: 12

          Text {
            text: modelData.glyph
            font.pixelSize: 18
            color: Theme.mainColor
          }

          Text {
            text: modelData.label
            color: hoverArea.containsMouse ? Theme.accentColor : Theme.mainColor
            font.pixelSize: 13
            font.letterSpacing: 1.5
            font.weight: 600
            Layout.fillWidth: true
          }
        }

        MouseArea {
          id: hoverArea
          anchors.fill: parent
          hoverEnabled: true
          onClicked: {
            Quickshell.execDetached(modelData.cmd)
            menu.close()
          }
        }
      }
    }
  }
}
