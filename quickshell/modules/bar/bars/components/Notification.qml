import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

import qs.utils

// Bell glyph with an unread-count badge.
//
// IMPORTANT: only one process on the system can register as the active
// notification daemon (org.freedesktop.Notifications). If you already run
// a NotificationServer somewhere else in your config (e.g. a dedicated
// qs.services.Notifications singleton, which is the common pattern), do
// NOT instantiate a second one here — instead swap the `NotificationServer
// { ... }` block below for a reference to your existing service, e.g.:
//
//   import qs.services as Services
//   readonly property int unread: Services.Notifications.list.values.length
//
// The self-contained version below is a drop-in fallback if you don't
// have one yet.
Item {
  id: root

  Layout.preferredWidth: parent.width
  Layout.preferredHeight: 40
  Layout.alignment: Qt.AlignHCenter

  signal togglePanel()

  NotificationServer {
    id: notifServer
    keepOnReload: false
    actionsSupported: true
  }

  readonly property int unread: notifServer.trackedNotifications?.values?.length ?? 0

  ColumnLayout {
    anchors.centerIn: parent
    spacing: 2

    Item {
      Layout.preferredWidth: 20
      Layout.preferredHeight: 20
      Layout.alignment: Qt.AlignHCenter

      Text {
        anchors.centerIn: parent
        text: root.unread > 0 ? "\uf0f3" : "\uf0a2" // filled vs outline bell
        font.pixelSize: Theme.fontSizeLg
        color: Theme.mainColor
      }

      Rectangle {
        visible: root.unread > 0
        width: 14
        height: 14
        radius: 7
        color: Theme.accentColor
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: -4
        anchors.rightMargin: -6

        Text {
          anchors.centerIn: parent
          text: root.unread > 9 ? "9+" : root.unread
          color: "#ffffff"
          font.pixelSize: 8
          font.weight: 700
        }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.togglePanel()
  }
}
