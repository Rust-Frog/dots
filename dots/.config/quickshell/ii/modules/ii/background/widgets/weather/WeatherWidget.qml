import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.common.widgets.widgetCanvas
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root

    configEntryName: "weather"

    implicitHeight: card.implicitHeight
    implicitWidth: card.implicitWidth

    StyledDropShadow {
        target: card
    }

    // Card background with theme colors
    Rectangle {
        id: card
        implicitWidth: 180
        implicitHeight: contentLayout.implicitHeight + 24
        radius: Appearance.rounding.large
        color: Appearance.colors.colSurfaceContainer
        border.width: 1
        border.color: Appearance.colors.colOutlineVariant

        ColumnLayout {
            id: contentLayout
            anchors {
                fill: parent
                margins: 12
            }
            spacing: 8

            // Weather icon + Temperature row
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                MaterialSymbol {
                    iconSize: 48
                    color: Appearance.colors.colOnSurface
                    text: Icons.getWeatherIcon(Weather.data.wCode) ?? "cloud"
                }

                StyledText {
                    font {
                        pixelSize: 42
                        family: Appearance.font.family.expressive
                        weight: Font.Medium
                    }
                    color: Appearance.colors.colOnSurface
                    text: Weather.data?.temp ?? "--°"
                }
            }

            // Weather condition
            StyledText {
                font {
                    pixelSize: Appearance.font.pixelSize.normal
                    weight: Font.Medium
                }
                color: Appearance.colors.colOnSurfaceVariant
                text: Weather.data?.wText ?? "Loading..."
            }

            // Location row
            RowLayout {
                spacing: 4

                MaterialSymbol {
                    iconSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnSurfaceVariant
                    text: "location_on"
                }

                StyledText {
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSurfaceVariant
                    text: Weather.data?.city ?? "Unknown"
                }
            }
        }
    }
}
