import QtQuick 2.15
import QtQuick.Controls 2.15

import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui

import org.maui.cask 1.0 as Cask
import QtQuick.Templates 2.15 as T

import org.mauicore.audio 1.0 as MauiCore

import ".."
import "../../../../templates" as Template

Template.SliderToggle
{
    id: control
    property var defaultSourceValue: defaultSource ? defaultSource.volume / MauiCore.PulseAudio.MaximalVolume * 100.0 : -1
    property var defaultSource: paSourceModel.defaultSource
    readonly property bool muted : defaultSource ?  defaultSource.muted : true

    enabled: !muted

    slider.iconSource: {
        if (defaultSourceValue <= 0)
            return "microphone-sensitivity-muted"
        else if (defaultSourceValue <= 25)
            return "microphone-sensitivity-low"
        else if (defaultSourceValue <= 75)
            return "microphone-sensitivity-medium"
        else
            return "microphone-sensitivity-high"
    }

    page: MicPage
    {

    }

    slider.from: MauiCore.PulseAudio.MinimalVolume
    slider.to: MauiCore.PulseAudio.MaximalVolume
    slider.stepSize: slider.to / (slider.to / MauiCore.PulseAudio.MaximalVolume * 100.0)

    slider.value: defaultSource ? defaultSource.volume : 0
    Connections
    {
        target: control.slider
        function onValueChanged()
        {
            if (!defaultSource)
                return

            defaultSource.volume = target.value
            defaultSource.muted = (target.value === 0)
        }
    }

    // Input devices
    MauiCore.SourceModel
    {
        id: paSourceModel
    }

    // active input devices
    MauiCore.PulseObjectFilterModel
    {
        id: paSourceFilterModel
        sortRole: "SortByDefault"
        sortOrder: Qt.DescendingOrder
        filterOutInactiveDevices: true
        sourceModel: paSourceModel
    }

    MauiCore.CardModel
    {
        id: paCardModel
    }

    function muteMic()
    {
        for (var i = 0; i < paSourceModel.rowCount(); i++) {

            paSourceModel.setData(paSourceModel.index(i, 0), true, paSourceModel.role("Muted"));

        }
    }

    function unmuteMic()
    {
        for (var i = 0; i < paSourceModel.rowCount(); i++) {

            paSourceModel.setData(paSourceModel.index(i, 0), false, paSourceModel.role("Muted"));

        }
    }

    function toggleMute()
    {
        if (control.muted)
        {
            control.unmuteMic()
        }else
        {
            control.muteMic()
        }
    }
}
