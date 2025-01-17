import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Templates 2.15 as T

import org.mauikit.controls 1.3 as Maui

import org.maui.cask 1.0 as Cask

import QtGraphicalEffects 1.15

T.Slider
{
    id: control
    implicitHeight: 16 + topPadding + bottomPadding
    opacity: enabled ? 1 : 0.7

    property alias iconSource : _icon.source
    property alias animatedRec : _animatedRec

    Behavior on implicitHeight
    {
        NumberAnimation
        {
            duration: Maui.Style.units.shortDuration
            easing.type: Easing.OutQuad
        }
    }

    background: Rectangle
    {
        radius: height/2
        color: control.enabled ? Qt.darker(Maui.Theme.backgroundColor, 1.2) : "transparent"
        border.color: control.enabled ? "transparent" : Maui.Theme.textColor

        Rectangle
        {
            id: _bg

            width: Math.max(height, control.visualPosition * parent.width)
            height: control.height
            anchors.verticalCenter: parent.verticalCenter
            color: control.enabled ? Maui.Theme.highlightColor : "transparent"
            border.color: control.enabled ? "transparent" : Maui.Theme.highlightColor
            radius: height/2
            clip: true

            Rectangle
            {
                id: _animatedRec
                visible: control.enabled
                height: parent.height
                color: Qt.lighter(parent.color)
                opacity: 0.5
                Behavior on width
                {
                    NumberAnimation
                    {
                        id: animation
                        duration: Maui.Style.units.shortDuration
                        easing.type: Easing.OutQuad
                    }
                }
            }

            Behavior on color
            {
                ColorAnimation
                {
                    easing.type: Easing.InQuad
                    duration: Maui.Style.units.shortDuration
                }
            }

            layer.enabled: _animatedRec.visible
            layer.effect: OpacityMask
            {
                maskSource: Rectangle
                {
                    width: _bg.width
                    height: _bg.height
                    radius: _bg.radius
                }
            }
        }

        Behavior on color
        {
            ColorAnimation
            {
                easing.type: Easing.InQuad
                duration: Maui.Style.units.shortDuration
            }
        }
    }

    handle: Rectangle
    {
        x: Math.max(0,(control.visualPosition * parent.availableWidth) - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: control.height
        implicitHeight: control.height
        color: control.enabled ? Maui.Theme.highlightColor : "transparent"
        radius: height/2

        Maui.Icon
        {
            id: _icon
            height: 16
            width : 16
            isMask: true
            color: Maui.Theme.highlightedTextColor
            anchors.centerIn: parent
            Behavior on color
            {
                ColorAnimation
                {
                    easing.type: Easing.InQuad
                    duration: Maui.Style.units.shortDuration
                }
            }
        }

        Behavior on color
        {
            ColorAnimation
            {
                easing.type: Easing.InQuad
                duration: Maui.Style.units.shortDuration
            }
        }
    }
}
