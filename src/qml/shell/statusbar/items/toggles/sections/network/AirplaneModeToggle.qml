import QtQuick 2.15
import QtQuick.Controls 2.5

import org.mauikit.controls 1.2 as Maui
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

import org.maui.cask 1.0 as Cask
import "../.."

ToggleTemplate
{
    id: control
    checked: PlasmaNM.Configuration.airplaneModeEnabled
    checkable: true
    icon.name: "network-flightmode-on"
    text: i18n("Airplane Mode")

    visible: availableDevices.modemDeviceAvailable || availableDevices.wirelessDeviceAvailable

    onToggled:
    {
        handler.enableAirplaneMode(checked);
        PlasmaNM.Configuration.airplaneModeEnabled = checked;
    }

    PlasmaNM.AvailableDevices {
        id: availableDevices
    }

    PlasmaNM.Handler
    {
        id: handler
    }

}
