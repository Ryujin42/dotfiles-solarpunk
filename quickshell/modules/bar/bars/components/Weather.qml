import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import QtQuick.Effects

import qs.utils

// Current weather + temperature (°C), pulled from wttr.in — no API key
// needed, it geolocates you by IP when no location is given.
//
// Icons are loaded as images from Theme.weatherIcons (a folder path),
// expecting these exact filenames:
//   thunderstorm.png, snow.png, rain.png, fog.png,
//   partly-cloudy.png, cloudy.png, sunny.png, default.png
Item {
  id: root

  Layout.preferredWidth: row.implicitWidth
  Layout.preferredHeight: Theme.iconSizeMd
  Layout.alignment: Qt.AlignVCenter

  property real tempC: NaN
  property string description: ""

  function iconFile() {
    const d = root.description.toLowerCase()
    if (d.includes("thunder")) return "thunderstorm.png"
    if (d.includes("snow") || d.includes("sleet") || d.includes("ice"))
      return "snow.png"
    if (d.includes("rain") || d.includes("drizzle") || d.includes("shower"))
      return "rain.png"
    if (d.includes("fog") || d.includes("mist") || d.includes("haze"))
      return "fog.png"
    if (d.includes("partly")) return "partly-cloudy.png"
    if (d.includes("cloud") || d.includes("overcast")) return "cloudy.png"
    if (d.includes("clear") || d.includes("sunny")) return "sunny.png"
    return "default.png"
  }

  Process {
    id: weatherProc
    command: ["curl", "-s", "https://wttr.in/?format=j1"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          const data = JSON.parse(this.text)
          const cur = data.current_condition[0]
          root.tempC = parseFloat(cur.temp_C)
          root.description = cur.weatherDesc[0].value
        } catch (e) {
          console.warn("Weather: failed to parse wttr.in response", e)
        }
      }
    }
  }

  Timer {
    interval: 15 * 60 * 1000 // refresh every 15 minutes
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: weatherProc.running = true
  }

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: 4

    Item {
      id: iconWrap
      Layout.preferredWidth: Theme.iconSizeMd
      Layout.preferredHeight: Theme.iconSizeMd

      Image {
        id: rawIcon
        anchors.fill: parent
        source: Theme.weatherIcons + "/" + root.iconFile()
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: false // only used as the alpha mask below
        onStatusChanged: if (status === Image.Error)
          console.warn("Weather: failed to load icon", source)
      }

      Rectangle {
        id: colorFill
        anchors.fill: parent
        color: "#94e2ff"
        visible: false // only used as the solid-color source below
      }

      // MultiEffect.colorization blends toward a target color based on
      // the source's luminance — since these icons are pure black
      // (luminance 0), there's nothing for it to tint, so colorization
      // silently does nothing on black-on-transparent PNGs. Masking a
      // solid-color rect with the icon's alpha channel instead sidesteps
      // that entirely: it doesn't care what color the source icon is,
      // only which pixels are opaque vs transparent.
      MultiEffect {
        anchors.fill: parent
        source: colorFill
        maskEnabled: true
        maskSource: rawIcon
        maskThresholdMin: 0.5
        maskSpreadAtMin: 0.05
      }
    }

    Text {
      text: isNaN(root.tempC) ? "--°C" : Math.round(root.tempC) + "°C"
      color: Theme.mainColor
      font.pixelSize: 13
      font.weight: 600
    }
  }
}
