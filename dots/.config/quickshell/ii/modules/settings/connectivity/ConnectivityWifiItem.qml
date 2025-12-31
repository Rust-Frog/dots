import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.services.network
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property WifiAccessPoint wifiNetwork
    
    property bool isConnecting: Network.wifiConnectTarget === root.wifiNetwork && !wifiNetwork?.active
    property bool isActive: wifiNetwork?.active ?? false
    property bool isAskingPassword: wifiNetwork?.askingPassword ?? false
    
    Layout.fillWidth: true
    implicitHeight: contentColumn.implicitHeight + 20
    radius: Appearance.rounding.normal
    color: isActive ? Appearance.colors.colPrimaryContainer : 
           root.hovered ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer2
    
    property bool hovered: mouseArea.containsMouse

    Behavior on color {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: isAskingPassword ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !isConnecting && !isAskingPassword
        
        onClicked: {
            if (!isActive) {
                Network.connectToWifiNetwork(wifiNetwork);
            }
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

            // Signal strength icon
            MaterialSymbol {
                property int strength: root.wifiNetwork?.strength ?? 0
                text: strength > 80 ? "signal_wifi_4_bar" : 
                      strength > 60 ? "network_wifi_3_bar" : 
                      strength > 40 ? "network_wifi_2_bar" : 
                      strength > 20 ? "network_wifi_1_bar" : "signal_wifi_0_bar"
                iconSize: 24
                color: root.isActive ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer2
            }

            // Network name
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                StyledText {
                    Layout.fillWidth: true
                    text: root.wifiNetwork?.ssid ?? Translation.tr("Unknown")
                    elide: Text.ElideRight
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: root.isActive ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer2
                }
                
                StyledText {
                    visible: root.isActive || root.isConnecting
                    text: root.isConnecting ? Translation.tr("Connecting...") : 
                          root.isActive ? Translation.tr("Connected") : ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.isActive ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext
                    opacity: 0.8
                }
            }

            // Security/status icon
            MaterialSymbol {
                text: root.isActive ? "check_circle" : 
                      root.isConnecting ? "sync" : 
                      root.wifiNetwork?.isSecure ? "lock" : ""
                visible: text.length > 0
                iconSize: 20
                color: root.isActive ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer2
                
                RotationAnimator on rotation {
                    running: root.isConnecting
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                }
            }

            // Disconnect button for active network
            RippleButton {
                visible: root.isActive
                implicitWidth: 100
                implicitHeight: 32
                buttonRadius: Appearance.rounding.full
                colBackground: Appearance.colors.colError
                colBackgroundHover: Appearance.colors.colErrorHover
                
                onClicked: Network.disconnectWifiNetwork()
                
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: Translation.tr("Disconnect")
                    color: Appearance.colors.colOnError
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }
        }

        // Password entry section
        ColumnLayout {
            visible: root.isAskingPassword
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 10

            MaterialTextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: Translation.tr("Enter password")
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData
                
                onAccepted: {
                    Network.changePassword(root.wifiNetwork, passwordField.text);
                    passwordField.text = "";
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                Item { Layout.fillWidth: true }
                
                RippleButton {
                    implicitWidth: 80
                    implicitHeight: 32
                    buttonRadius: Appearance.rounding.full
                    colBackground: Appearance.colors.colLayer3
                    colBackgroundHover: Appearance.colors.colLayer3Hover
                    
                    onClicked: {
                        root.wifiNetwork.askingPassword = false;
                        passwordField.text = "";
                    }
                    
                    contentItem: StyledText {
                        anchors.centerIn: parent
                        text: Translation.tr("Cancel")
                        color: Appearance.colors.colOnLayer3
                    }
                }
                
                RippleButton {
                    implicitWidth: 80
                    implicitHeight: 32
                    buttonRadius: Appearance.rounding.full
                    colBackground: Appearance.colors.colPrimary
                    colBackgroundHover: Appearance.colors.colPrimaryHover
                    enabled: passwordField.text.length > 0
                    
                    onClicked: {
                        Network.changePassword(root.wifiNetwork, passwordField.text);
                        passwordField.text = "";
                    }
                    
                    contentItem: StyledText {
                        anchors.centerIn: parent
                        text: Translation.tr("Connect")
                        color: Appearance.colors.colOnPrimary
                    }
                }
            }
        }
    }
}
