import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import qs.utils

// Volume readout + control via pactl (works against PulseAudio directly,
// or PipeWire's pipewire-pulse compatibility layer — same CLI pavucontrol
// itself drives).
// Scroll up/down: ±5% volume. Left-click: toggle mute. Right-click: open
// pavucontrol for the full mixer.
Item {
  id: root

  Layout.preferredWidth: col.implicitWidth
  Layout.preferredHeight: Theme.iconSizeMd
  Layout.alignment: Qt.AlignVCenter

  property real volume: 0     // 0-1, synced from pactl
  property bool muted: false  // synced from pactl

  // Accumulates raw wheel delta so a single physical scroll notch (worth
  // 120 in Qt's angleDelta units) triggers exactly one bump — not a bump
  // per individual event. Smooth/high-precision scrolling (many mice and
  // most trackpads) fires several small wheel events per notch instead
  // of one clean event, so without this, one scroll gesture could call
  // bump() 5-10+ times and stack into a huge jump.
  property real wheelAccum: 0

  function refresh() {
    volProc.running = true
    muteProc.running = true
  }

  Process {
    id: volProc
    command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        const match = this.text.match(/(\d+)%/)
        if (match) root.volume = parseInt(match[1]) / 100
      }
    }
  }

  Process {
    id: muteProc
    command: ["pactl", "get-sink-mute", "@DEFAULT_SINK@"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.muted = this.text.trim().endsWith("yes")
      }
    }
  }

  // Periodic resync, in case volume changes elsewhere (media keys, other
  // apps, pavucontrol itself). 2s is plenty now that scroll no longer
  // relies on rapid polling to "catch up" — 100ms was spawning ~20
  // processes/sec for no real benefit.
  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  function bump(deltaPercent) {
    const sign = deltaPercent > 0 ? "+" : "-"
    Quickshell.execDetached([
      "pactl", "set-sink-volume", "@DEFAULT_SINK@",
      sign + Math.abs(deltaPercent) + "%"
    ])
    // Optimistic local update so the UI feels instant; corrected by the
    // next poll regardless.
    root.volume = Math.max(0, Math.min(1, root.volume + deltaPercent / 100))
    root.muted = false

    if (root.volume >= 1) {
      root.volume = 1
      Quickshell.execDetached([
        "pactl", "set-sink-volume", "@DEFAULT_SINK@",
        "100%"
      ])
    }
  }

  function toggleMute() {
    Quickshell.execDetached(["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"])
    root.muted = !root.muted
  }

  // volume is a 0-1 fraction — thresholds must match that scale (was
  // comparing against 40/75 instead of 0.4/0.75, so these branches never
  // actually fired).
  function glyph() {
    if (root.muted || root.volume === 0) return "\udb83\ude08"
    if (root.volume < 0.4) return "\udb81\udd7f"
    if (root.volume < 0.75) return "\udb81\udd80"
    return "\udb81\udd7e"
  }

  RowLayout {
    id: col
    anchors.centerIn: parent
    spacing: 2

    Text {
      Layout.alignment: Qt.AlignHCenter
      text: root.glyph()
      font.pixelSize: Theme.fontSizeLg
      color: Theme.mainColor
      opacity: root.muted ? 0.4 : 1
    }

    // Text {
    //   Layout.alignment: Qt.AlignHCenter
    //   text: root.muted ? "mute" : Math.round(root.volume * 100) + "%"
    //   color: Theme.mainColor
    //   opacity: root.muted ? 0.4 : 1
    //   font.pixelSize: 12
    //   font.weight: 600
    // }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: mouse => {
      // if (mouse.button === Qt.RightButton) {
      //   Quickshell.execDetached(["pavucontrol"])
      // } else {
      root.toggleMute()
      // }
    }
    onWheel: wheel => {
      root.wheelAccum += wheel.angleDelta.y
      while (Math.abs(root.wheelAccum) >= 120) {
        if (root.wheelAccum > 0) {
          root.bump(5)
          root.wheelAccum -= 120
        } else {
          root.bump(-5)
          root.wheelAccum += 120
        }
      }
    }
  }
}
