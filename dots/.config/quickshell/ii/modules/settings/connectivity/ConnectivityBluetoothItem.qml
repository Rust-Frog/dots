import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

Rectangle {
    id: root
    required property BluetoothDevice device
    
    property bool isConnected: device?.connected ?? false
    property bool isPaired: device?.paired ?? false
    property bool expanded: false

    Layout.fillWidth: true
    implicitHeight: contentColumn.implicitHeight + 20
    radius: Appearance.rounding.normal
    color: isConnected ? Appearance.colors.colPrimaryContainer : 
           root.hovered ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer2

    property bool hovered: mouseArea.containsMouse

    Behavior on color {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            root.expanded = !root.expanded;
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
        }
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Device icon
            MaterialSymbol {
                text: Icons.getBluetoothDeviceMaterialSymbol(root.device?.icon || "")
                iconSize: 24
                color: root.isConnected ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer2
            }

            // Device info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                StyledText {
                    Layout.fillWidth: true
                    text: root.device?.name || Translation.tr("Unknown device")
                    elide: Text.ElideRight
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: root.isConnected ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer2
                }
                
                StyledText {
                    visible: root.isConnected || root.isPaired
                    text: {
                        let statusText = root.isConnected ? Translation.tr("Connected") : Translation.tr("Paired");
                        if (root.device?.batteryAvailable) {
                            statusText += ` • ${Math.round(root.device.battery * 100)}%`;
                        }
                        return statusText;
                    }
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.isConnected ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext
                    opacity: 0.8
                }
            }

            // Expand indicator
            MaterialSymbol {
                text: "keyboard_arrow_down"
                iconSize: 20
                color: root.isConnected ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer2
                rotation: root.expanded ? 180 : 0
                
                Behavior on rotation {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
            }
        }

        // Expanded actions
        RowLayout {
            visible: root.expanded
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 10

            Item { Layout.fillWidth: true }

            // Connect/Disconnect button
            RippleButton {
                implicitWidth: 100
                implicitHeight: 32
                buttonRadius: Appearance.rounding.full
                colBackground: root.isConnected ? Appearance.colors.colLayer3 : Appearance.colors.colPrimary
                colBackgroundHover: root.isConnected ? Appearance.colors.colLayer3Hover : Appearance.colors.colPrimaryHover
                
                onClicked: {
                    if (root.isConnected) {
                        root.device.disconnect();
                    } else {
                        root.device.connect();
                    }
                }
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: root.isConnected ? Translation.tr("Disconnect") : Translation.tr("Connect")
                    color: root.isConnected ? Appearance.colors.colOnLayer3 : Appearance.colors.colOnPrimary
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }

            // Forget button (only for paired devices)
            RippleButton {
                visible: root.isPaired
                implicitWidth: 80
                implicitHeight: 32
                buttonRadius: Appearance.rounding.full
                colBackground: Appearance.colors.colError
                colBackgroundHover: Appearance.colors.colErrorHover
                
                onClicked: {
                    root.device?.forget();
                }
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: Translation.tr("Forget")
                    color: Appearance.colors.colOnError
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }
        }
    }
}
