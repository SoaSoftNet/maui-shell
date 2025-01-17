import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Templates 2.15 as T

import org.mauikit.controls 1.2 as Maui
import org.maui.cask 1.0 as Cask

import "volume"
import "brightness"

Cask.PanelItem
{
    id: control
    property alias micItem : _micSlider

    Cask.IconLabel
    {
        icon.source: _audioSlider.slider.iconSource
        icon.color: control.icon.color
        text: Math.round(_audioSlider.defaultSinkValue)
        height: control.iconSize
        labelVisible: labelsVisible
    }

    Cask.IconLabel
    {
        icon.source: _micSlider.slider.iconSource
        height: control.iconSize
        icon.color: control.icon.color
        text: Math.round(_micSlider.defaultSourceValue)
        labelVisible: labelsVisible
    }

    Cask.IconLabel
    {
        visible: _brightnessSlider.available
        icon.source: "high-brightness"
        height: control.iconSize
        icon.color: control.icon.color
        text: Math.round(_brightnessSlider.slider.value)
        labelVisible: labelsVisible
    }

    card: Cask.PanelCard
    {
        width: ListView.view.width
        onClosed: _togglesStack.pop()

        T.StackView
        {
            id : _togglesStack
            width: parent.width
            height: currentItem.implicitHeight
            clip: true
            padding: 0

            initialItem: Column
            {
                spacing: control.card.spacing

                VolumeSlider
                {
                    id: _audioSlider
                    width: parent.width
                    onClicked: _togglesStack.push(page)
                }

                MicSlider
                {
                    id: _micSlider
                    width: parent.width
                    onClicked: _togglesStack.push(page)
                }

                BrightnessSlider
                {
                    id: _brightnessSlider
                    width: parent.width
                    onClicked: _togglesStack.push(page)
                }
            }
        }
    }
}
