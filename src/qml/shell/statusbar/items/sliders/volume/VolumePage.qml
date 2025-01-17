import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Templates 2.15 as T

import org.mauikit.controls 1.2 as Maui

import org.maui.cask 1.0 as Cask
import "../../../../templates"

StackPage
{
    id: control
    implicitHeight: _layout.implicitHeight + topPadding + bottomPadding + headerContainer.implicitHeight + footerContainer.implicitHeight + Maui.Style.space.big
    title: i18n("Audio")
    spacing: _listView.spacing

    Maui.Holder
    {
        anchors.fill: parent
        visible: _listView.count === 0 && _appsList.count === 0
        title: i18n("Nothing here")
        body: i18n("No output or input devices found.")
        emoji: "code-context"
    }

    Column
    {
        id: _layout
        spacing: control.spacing
        anchors.fill: parent

        Maui.ListBrowser
        {
            id: _listView
            width: parent.width
            padding: 0
            model: paSinkFilterModel

            delegate: DeviceItem
            {
                width: ListView.view.width
                type: "sink"
                label2.text: percent+"%"
            }
        }

        Maui.ListBrowser
        {
            id: _appsList
            width: parent.width
            padding: 0
            model: paSinkInputModel

            delegate: DeviceItem
            {
                width: ListView.view.width
                type: "source"
            }
        }
    }
}
