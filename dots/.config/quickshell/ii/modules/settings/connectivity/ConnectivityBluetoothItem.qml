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
    property real batteryLevel: device?.battery ?? 0
    property bool hasBattery: device?.batteryAvailable ?? false

    Layout.fillWidth: true
    implicitHeight: contentColumn.implicitHeight + 24
    radius: Appearance.rounding.normal
    color: isConnected ? Appearance.colors.colPrimaryContainer : 
           root.hovered ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer2

    property bool hovered: mouseArea.containsMouse

    Behavior on color {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }
    
    Behavior on implicitHeight {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
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
            margins: 12
        }
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Device icon with connection indicator
            Item {
                implicitWidth: 32
                implicitHeight: 32
                
                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: root.isConnected ? Appearance.colors.colPrimary : Appearance.colors.colLayer3
                    opacity: root.isConnected ? 0.2 : 0.5
                }
                
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: Icons.getBluetoothDeviceMaterialSymbol(root.device?.icon || "")
                    iconSize: 20
                    color: root.isConnected ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer2
                }
            }

            // Device info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                StyledText {
                    Layout.fillWidth: true
                    text: root.device?.name || Translation.tr("Unknown device")
                    elide: Text.ElideRight
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: root.isConnected ? Font.Medium : Font.Normal
                    color: root.isConnected ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer2
                }
                
                RowLayout {
                    spacing: 8
                    
                    // Status badge
                    Rectangle {
                        visible: root.isConnected || root.isPaired
                        implicitWidth: statusRow.implicitWidth + 10
                        implicitHeight: 18
                        radius: 4
                        color: root.isConnected ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer2
                        opacity: root.isConnected ? 0.2 : 0.1
                        
                        RowLayout {
                            id: statusRow
                            anchors.centerIn: parent
                            spacing: 3
                            
                            MaterialSymbol {
                                text: root.isConnected ? "bluetooth_connected" : "bluetooth"
                                iconSize: 12
                                color: root.isConnected ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext
                            }
                            StyledText {
                                text: root.isConnected ? Translation.tr("Connected") : Translation.tr("Paired")
                                font.pixelSize: 10
                                font.weight: Font.Medium
                                color: root.isConnected ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext
                            }
                        }
                    }
                    
                    // Battery indicator
                    RowLayout {
                        visible: root.hasBattery
                        spacing: 4
                        
                        // Battery icon with level
                        Item {
                            implicitWidth: 20
                            implicitHeight: 12
                            
                            Rectangle {
                                anchors.fill: parent
                                anchors.rightMargin: 2
                                radius: 2
                                color: "transparent"
                                border.width: 1.5
                                border.color: batteryColor
                                
                                Rectangle {
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                        bottom: parent.bottom
                                        margins: 2
                                    }
                                    width: (parent.width - 4) * root.batteryLevel
                                    radius: 1
                                    color: batteryColor
                                }
                            }
                            
                            Rectangle {
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }
                                width: 2
                                height: 6
                                radius: 1
                                color: batteryColor
                            }
                            
                            property color batteryColor: {
                                if (root.batteryLevel < 0.2) return Appearance.colors.colError;
                                if (root.batteryLevel < 0.4) return Appearance.colors.colWarning;
                                return root.isConnected ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer2;
                            }
                        }
                        
                        StyledText {
                            text: `${Math.round(root.batteryLevel * 100)}%`
                            font.pixelSize: 10
                            color: root.isConnected ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext
                        }
                    }
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
        ColumnLayout {
            visible: root.expanded
            Layout.fillWidth: true
            Layout.leftMargin: 44
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Appearance.colors.colOutlineVariant
                opacity: 0.5
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Connect/Disconnect button
                RippleButton {
                    implicitWidth: 110
                    implicitHeight: 34
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
                    
                    contentItem: RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        MaterialSymbol {
                            text: root.isConnected ? "bluetooth_disabled" : "bluetooth"
                            iconSize: 16
                            color: root.isConnected ? Appearance.colors.colOnLayer3 : Appearance.colors.colOnPrimary
                        }
                        StyledText {
                            text: root.isConnected ? Translation.tr("Disconnect") : Translation.tr("Connect")
                            color: root.isConnected ? Appearance.colors.colOnLayer3 : Appearance.colors.colOnPrimary
                            font.pixelSize: Appearance.font.pixelSize.small
                        }
                    }
                }

                // Forget button (only for paired devices)
                RippleButton {
                    visible: root.isPaired
                    implicitWidth: 90
                    implicitHeight: 34
                    buttonRadius: Appearance.rounding.full
                    colBackground: Appearance.colors.colError
                    colBackgroundHover: Appearance.colors.colErrorHover
                    
                    onClicked: {
                        root.device?.forget();
                    }
                    
                    contentItem: RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        
                        MaterialSymbol {
                            text: "delete"
                            iconSize: 16
                            color: Appearance.colors.colOnError
                        }
                        StyledText {
                            text: Translation.tr("Forget")
                            color: Appearance.colors.colOnError
                            font.pixelSize: Appearance.font.pixelSize.small
                        }
                    }
                }
            }
        }
    }
}
