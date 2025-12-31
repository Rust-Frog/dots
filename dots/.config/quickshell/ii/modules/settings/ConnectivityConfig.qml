import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Bluetooth
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import "connectivity"

Item {
    id: root
    // Read initialTab from the root ApplicationWindow (for deep-linking)
    property int initialTab: {
        const win = Window.window;
        return win?.initialTab ?? 0;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SecondaryTabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.topMargin: 10
            currentIndex: root.initialTab

            SecondaryTabButton {
                buttonIcon: "wifi"
                buttonText: Translation.tr("Wi-Fi")
            }
            SecondaryTabButton {
                buttonIcon: "bluetooth"
                buttonText: Translation.tr("Bluetooth")
            }
        }

        SwipeView {
            id: swipeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex
            clip: true

            onCurrentIndexChanged: {
                tabBar.currentIndex = swipeView.currentIndex;
            }

            Loader {
                active: SwipeView.isCurrentItem || SwipeView.isPreviousItem || SwipeView.isNextItem
                sourceComponent: WifiView {}
            }

            Loader {
                active: SwipeView.isCurrentItem || SwipeView.isPreviousItem || SwipeView.isNextItem
                sourceComponent: BluetoothView {}
            }
        }
    }

    component WifiView: Item {
        id: wifiView
        
        ContentPage {
            anchors.fill: parent
            forceWidth: true
            
            ContentSection {
                icon: "wifi"
                title: Translation.tr("Wi-Fi")
                
                ConfigRow {
                    ConfigSwitch {
                        text: Translation.tr("Enable Wi-Fi")
                        checked: Network.wifiEnabled
                        onCheckedChanged: {
                            Network.enableWifi(checked);
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    RippleButton {
                        implicitWidth: 100
                        implicitHeight: 36
                        enabled: Network.wifiEnabled && !Network.wifiScanning
                        buttonRadius: Appearance.rounding.full
                        colBackground: Appearance.colors.colLayer2
                        colBackgroundHover: Appearance.colors.colLayer2Hover
                        onClicked: Network.rescanWifi()
                        
                        contentItem: RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            MaterialSymbol {
                                text: "refresh"
                                iconSize: 18
                                color: Appearance.colors.colOnLayer2
                            }
                            StyledText {
                                text: Translation.tr("Scan")
                                color: Appearance.colors.colOnLayer2
                            }
                        }
                    }
                }
                
                StyledIndeterminateProgressBar {
                    visible: Network.wifiScanning
                    Layout.fillWidth: true
                }
            }
            
            ContentSection {
                icon: "wifi_find"
                title: Translation.tr("Available Networks")
                visible: Network.wifiEnabled
                
                // Empty state
                RowLayout {
                    visible: Network.friendlyWifiNetworks.length === 0
                    Layout.fillWidth: true
                    spacing: 12
                    
                    MaterialSymbol {
                        text: "wifi_off"
                        iconSize: 32
                        color: Appearance.colors.colSubtext
                    }
                    StyledText {
                        text: Translation.tr("No networks found")
                        color: Appearance.colors.colSubtext
                    }
                }
                
                // Network list
                Repeater {
                    model: Network.friendlyWifiNetworks
                    
                    ConnectivityWifiItem {
                        required property var modelData
                        wifiNetwork: modelData
                        Layout.fillWidth: true
                    }
                }
            }
            
            ContentSection {
                icon: "wifi_add"
                title: Translation.tr("Hidden Network")
                visible: Network.wifiEnabled
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    MaterialTextField {
                        id: hiddenSsidField
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Network name (SSID)")
                    }
                    
                    MaterialTextField {
                        id: hiddenPasswordField
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Password (optional)")
                        echoMode: TextInput.Password
                        inputMethodHints: Qt.ImhSensitiveData
                    }
                    
                    RippleButton {
                        Layout.alignment: Qt.AlignRight
                        implicitWidth: 140
                        implicitHeight: 40
                        buttonRadius: Appearance.rounding.full
                        enabled: hiddenSsidField.text.length > 0
                        colBackground: Appearance.colors.colPrimary
                        colBackgroundHover: Appearance.colors.colPrimaryHover
                        
                        onClicked: {
                            const ssid = hiddenSsidField.text;
                            const password = hiddenPasswordField.text;
                            if (password.length > 0) {
                                Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", ssid, "password", password]);
                            } else {
                                Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", ssid]);
                            }
                            hiddenSsidField.text = "";
                            hiddenPasswordField.text = "";
                        }
                        
                        contentItem: RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            MaterialSymbol {
                                text: "add"
                                iconSize: 18
                                color: Appearance.colors.colOnPrimary
                            }
                            StyledText {
                                text: Translation.tr("Connect")
                                color: Appearance.colors.colOnPrimary
                            }
                        }
                    }
                }
            }
        }
    }

    component BluetoothView: Item {
        id: bluetoothView
        
        ContentPage {
            anchors.fill: parent
            forceWidth: true
            
            ContentSection {
                icon: "bluetooth"
                title: Translation.tr("Bluetooth")
                
                ConfigRow {
                    ConfigSwitch {
                        text: Translation.tr("Enable Bluetooth")
                        checked: Bluetooth.defaultAdapter?.enabled ?? false
                        onCheckedChanged: {
                            if (Bluetooth.defaultAdapter) {
                                Bluetooth.defaultAdapter.enabled = checked;
                            }
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    RippleButton {
                        implicitWidth: 100
                        implicitHeight: 36
                        enabled: Bluetooth.defaultAdapter?.enabled ?? false
                        buttonRadius: Appearance.rounding.full
                        colBackground: Appearance.colors.colLayer2
                        colBackgroundHover: Appearance.colors.colLayer2Hover
                        onClicked: {
                            if (Bluetooth.defaultAdapter) {
                                Bluetooth.defaultAdapter.discovering = !Bluetooth.defaultAdapter.discovering;
                            }
                        }
                        
                        contentItem: RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            MaterialSymbol {
                                text: Bluetooth.defaultAdapter?.discovering ? "bluetooth_searching" : "search"
                                iconSize: 18
                                color: Appearance.colors.colOnLayer2
                            }
                            StyledText {
                                text: Bluetooth.defaultAdapter?.discovering ? Translation.tr("Stop") : Translation.tr("Scan")
                                color: Appearance.colors.colOnLayer2
                            }
                        }
                    }
                }
                
                StyledIndeterminateProgressBar {
                    visible: Bluetooth.defaultAdapter?.discovering ?? false
                    Layout.fillWidth: true
                }
            }
            
            // Connected devices
            ContentSection {
                icon: "bluetooth_connected"
                title: Translation.tr("Connected Devices")
                visible: (Bluetooth.defaultAdapter?.enabled ?? false) && BluetoothStatus.connectedDevices.length > 0
                
                Repeater {
                    model: BluetoothStatus.connectedDevices
                    
                    ConnectivityBluetoothItem {
                        required property var modelData
                        device: modelData
                        Layout.fillWidth: true
                    }
                }
            }
            
            // Paired devices
            ContentSection {
                icon: "bluetooth"
                title: Translation.tr("Paired Devices")
                visible: (Bluetooth.defaultAdapter?.enabled ?? false) && BluetoothStatus.pairedButNotConnectedDevices.length > 0
                
                Repeater {
                    model: BluetoothStatus.pairedButNotConnectedDevices
                    
                    ConnectivityBluetoothItem {
                        required property var modelData
                        device: modelData
                        Layout.fillWidth: true
                    }
                }
            }
            
            // Available devices
            ContentSection {
                icon: "devices"
                title: Translation.tr("Available Devices")
                visible: (Bluetooth.defaultAdapter?.enabled ?? false)
                
                // Empty state
                RowLayout {
                    visible: BluetoothStatus.friendlyDeviceList.length === 0
                    Layout.fillWidth: true
                    spacing: 12
                    
                    MaterialSymbol {
                        text: "bluetooth_disabled"
                        iconSize: 32
                        color: Appearance.colors.colSubtext
                    }
                    StyledText {
                        text: Translation.tr("No Bluetooth devices found")
                        color: Appearance.colors.colSubtext
                    }
                }
                
                Repeater {
                    model: BluetoothStatus.unpairedDevices
                    
                    ConnectivityBluetoothItem {
                        required property var modelData
                        device: modelData
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
