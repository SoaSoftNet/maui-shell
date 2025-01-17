/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Copyright (C) 2020 Shawn Rutledge
**
** This file is free software; you can redistribute it and/or
** modify it under the terms of the GNU Lesser General Public
** License version 3 as published by the Free Software Foundation
** and appearing in the file LICENSE included in the packaging
** of this file.
**
** This code is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU Lesser General Public License for more details.
**
****************************************************************************/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import QtQml 2.15

import QtWayland.Compositor 1.15
import QtGraphicalEffects 1.15

import org.mauikit.controls 1.3 as Maui
import org.maui.cask 1.0 as Cask
import Zpaces 1.0 as ZP

Cask.StackableItem
{
    id: rootChrome

    objectName: "Chrome"
    readonly property bool intersects : toplevel ? (y+height > rootChrome.parent.height+20 || formFactor !== Cask.Env.Desktop) && activated : false

    property alias shellSurface: surfaceItem.shellSurface

    property bool overviewMode : false

    property ZP.XdgWindow window
    property XdgSurface xdgSurface: window.xdgSurface
    property XdgToplevel toplevel: window.toplevel
    property WaylandSurface surface: xdgSurface.surface
    property WaylandSurface parentSurface: toplevel.parentToplevel.xdgSurface.surface

    readonly property string appId: window.appId
    readonly property string title: window.title

    property bool activated : toplevel.activated
    property bool resizing : toplevel.resizing


    property alias moveItem: surfaceItem.moveItem

    readonly property bool decorationVisible: win.formFactor === Cask.Env.Desktop && toplevel.decorationMode === XdgToplevel.ServerSideDecoration

    property bool moving: surfaceItem.moveItem ? surfaceItem.moveItem.moving : false

    property int marginWidth : window.fullscreen ? 0 : (surfaceItem.isPopup ? 1 : 6)
    //    property int titlebarHeight : surfaceItem.isPopup || surfaceItem.isFullscreen ? 0 : 25

    readonly property int titlebarHeight : decorationVisible ? 36 : 0
    property string screenName: ""

    property real resizeAreaWidth: 12

    property rect previousRect

    y: surfaceItem.moveItem.y - surfaceItem.output.geometry.y

    x: surfaceItem.moveItem.x - surfaceItem.output.geometry.x


    height: surfaceItem.height + titlebarHeight
    width: surfaceItem.width

    visible: surfaceItem.valid && surfaceItem.paintEnabled

    MouseArea
    {
        anchors.fill: parent
        propagateComposedEvents: false
        preventStealing: true
        onPressed:
        {
            mouse.accepted = true
        }
    }
    //    Binding on y
    //    {
    //        when: toplevel.decorationMode !== XdgToplevel.ServerSideDecoration
    //        value:  surfaceItem.moveItem.y - surfaceItem.output.geometry.y
    ////        delayed: true
    //        restoreMode: Binding.RestoreBindingOrValue
    //    }

    //    onYChanged:
    //    {
    //        if( y < 0 && toplevel.decorationMode !== XdgToplevel.ServerSideDecoration)
    //        {
    //            rootChrome.y = 0
    //        }
    //    }

    onIntersectsChanged:
    {
        if(intersects)
            dock.hide()
        else
            dock.show()
    }

    property rect oldPos : Qt.rect(0, 0, rootChrome.width * 0.6, rootChrome.height*0.6)

    function performActiveWindowAction(type)
    {
        if (type === Maui.CSDButton.Close)
        {
            window.close()

        } else if (type === Maui.CSDButton.Maximize)
        {
            window.maximize()
        }
        else if (type === Maui.CSDButton.Restore)
        {
            window.unmaximize()
        }
        if (type ===  Maui.CSDButton.Minimize) {
            window.minimize()
        }
    }

    Connections
    {
        target: rootChrome.window

        function onSetMinimized()
        {
            rootChrome.visible = false
            window.deactivate()
            focusTopWindow(1)
        }

        function onUnsetMinimized()
        {
            rootChrome.visible = true;
            surfaceItem.forceActiveFocus();
            window.activate()
        }

        function onSetMaximized()
        {
            console.log("SET MAX", toplevel.maximized, oldPos)

            oldPos.x = rootChrome.x
            oldPos.y = rootChrome.y
            oldPos.width = rootChrome.width
            oldPos.height = rootChrome.height

            rootChrome.x = 0
            rootChrome.y = 0

            toplevel.sendMaximized(Qt.size(rootChrome.parent.width, rootChrome.parent.height - titlebarHeight))


            //            window.activate()

        }

        function onUnsetMaximized()
        {
            console.log("SET UNMAX", toplevel.maximized, oldPos)
            if(oldPos.width === -1)
            {
                oldPos = Qt.rect(0, 0, rootChrome.width * 0.6, rootChrome.height*0.6)
            }

            rootChrome.x = oldPos.x
            rootChrome.y = oldPos.y
            toplevel.sendUnmaximized(Qt.size(oldPos.width, oldPos.height))

        }

        function onSetFullScreen()
        {

        }
    }

    Connections
    {
        target: rootChrome.toplevel
        ignoreUnknownSignals: true

        function onActivatedChanged ()
        { // xdg_shell only
            console.log("ACTIVATED CHANGED", toplevel.activated)
            if (target.activated)
            {
                surfaceItem.forceActiveFocus()
                //                rootChrome.window.activate()
                //                receivedFocusAnimation.start();
            }
        }

        function onMaximizedChanged()
        {
            console.log("REQUESTED", target.maximized)

        }

        function onFullscreenChanged()
        {
            console.log("REQUESTED FULLSCREEN", target.fullscreen)
        }
    }

    Component.onCompleted:
    {
        rootChrome.window.chrome = rootChrome
        surfaceItem.forceActiveFocus()
    }

    //    Component.onDestruction: intersects = false



    Rectangle
    {
        id: decoration

        visible: rootChrome.decorationVisible || radiusValue > -1
        property int radiusValue :  Cask.Server.chrome.blurFor(rootChrome.appId)

        Maui.Theme.inherit: false
        Maui.Theme.colorSet: Maui.Theme.Header

        anchors.fill: parent

        radius: window.maximized ? 0 : (rootChrome.decorationVisible ? Maui.Style.radiusV : radiusValue)

        color: Maui.Theme.backgroundColor

//        FastBlur
//        {
//            anchors.fill: parent
//            radius: 64
//            opacity: 0.4
//            source: ShaderEffectSource
//            {
//                id: _shader
//                property rect area : sourceItem.mapToItem(rootChrome, rootChrome.x, rootChrome.y, rootChrome.width, rootChrome.height)
//                format: ShaderEffectSource.RGB
//                sourceItem: surfaceArea
//                recursive: false
//                sourceRect: Qt.rect(rootChrome.x, rootChrome.y, rootChrome.width, rootChrome.height)

//            }

//            layer.enabled: true
//            layer.effect: Desaturate
//            {
//                desaturation: -1.2
//            }
//        }

        Loader
        {
            asynchronous: true
            active: rootChrome.decorationVisible
            anchors.fill: parent
            sourceComponent: Item
            {
                Item
                {
                    id:  titleBar
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Maui.Style.space.medium
                    anchors.rightMargin: Maui.Style.space.medium
                    height: titlebarHeight
                    visible: !surfaceItem.isPopup

                    MouseArea
                    {
                        anchors.fill: parent
                        onPressed:
                        {
                            rootChrome.window.activate()
                            mouse.accepted= false
                        }
                    }

                    DragHandler
                    {
                        id: titlebarDrag
                        //                enabled: rootChrome.activated
                        grabPermissions: PointerHandler.TakeOverForbidden
                        target: rootChrome
                        yAxis.maximum: rootChrome.parent.height
                        yAxis.minimum: 0
                        //                enabled: rootChrome.activated
                        cursorShape: Qt.ClosedHandCursor
                        onActiveChanged:
                        {
                            if(toplevel.maximized)
                            {
                                window.unmaximize()
                            }

                            if(!rootChrome.activated)
                            {
                                rootChrome.window.activate()
                            }
                        }

                        //                property var movingBinding: Binding
                        //                {
                        //                    target: surfaceItem.moveItem
                        //                    property: "moving"
                        //                    value: titlebarDrag.active
                        //                }
                    }

                    HoverHandler
                    {
                        enabled: rootChrome.activated
                        cursorShape: Qt.OpenHandCursor
                    }

                    RowLayout
                    {
                        anchors.fill: parent

                        Item
                        {
                            Layout.maximumWidth: _rightControlsLoader.implicitWidth
                            Layout.minimumWidth: 0
                        }

                        Label
                        {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: rootChrome.title
                            horizontalAlignment: Qt.AlignHCenter
                            elide: Text.ElideMiddle
                            wrapMode: Text.NoWrap
                            color: Maui.Theme.textColor
                        }

                        Loader
                        {
                            id: _rightControlsLoader

                            sourceComponent: Maui.CSDControls
                            {
                                onButtonClicked: performActiveWindowAction(type)
                                isActiveWindow: rootChrome.activated
                                maximized: rootChrome.toplevel.maximized
                            }
                        }
                    }
                }


                // TODO write a ResizeHandler for this purpose? otherwise there are up to 8 components for edges and corners
                Item
                {
                    enabled: !window.maximized  && rootChrome.activated

                    focus: false
                    id: rightEdgeResizeArea
                    x: parent.width - resizeAreaWidth / 2;
                    width: resizeAreaWidth; height: parent.height - resizeAreaWidth

                    onXChanged:
                        if (horzDragHandler.active)
                        {
                            var size = toplevel.sizeForResize(horzDragHandler.initialSize,
                                                              Qt.point(horzDragHandler.translation.x,
                                                                       horzDragHandler.translation.y),
                                                              Qt.RightEdge);
                            toplevel.sendResizing(size)
                        }

                    DragHandler
                    {
                        id: horzDragHandler
                        property size initialSize
                        onActiveChanged: if (active) initialSize = Qt.size(rootChrome.width, rootChrome.height)
                        yAxis.enabled: false
                    }

                    HoverHandler {
                        id: rightEdgeHover
                        cursorShape: Qt.SizeHorCursor // problem: this so far only sets the EGLFS cursor, not WaylandCursorItem
                    }
                }

                Item
                {
                    enabled: !window.maximized && rootChrome.activated

                    focus: false
                    id: bottomEdgeResizeArea
                    y: parent.height - resizeAreaWidth / 2; height: resizeAreaWidth; width: parent.width - resizeAreaWidth
                    onYChanged:
                        if (vertDragHandler.active) {
                            var size = toplevel.sizeForResize(vertDragHandler.initialSize,
                                                              Qt.point(vertDragHandler.translation.x, vertDragHandler.translation.y),
                                                              Qt.BottomEdge);
                            toplevel.sendResizing(size)
                        }
                    DragHandler {
                        id: vertDragHandler
                        property size initialSize
                        onActiveChanged: if (active) initialSize = Qt.size(rootChrome.width, rootChrome.height)
                        xAxis.enabled: false
                    }
                    HoverHandler {
                        id: bottomEdgeHover
                        cursorShape: Qt.SizeVerCursor
                    }
                }

                Item
                {
                    enabled: !window.maximized  && rootChrome.activated

                    focus: false
                    id: bottomRightResizeArea
                    x: parent.width - resizeAreaWidth / 2; y: parent.height - resizeAreaWidth / 2
                    width: resizeAreaWidth; height: parent.height - resizeAreaWidth
                    onXChanged: resize()
                    onYChanged: resize()
                    function resize() {
                        if (bottomRightDragHandler.active) {
                            var size = toplevel.sizeForResize(bottomRightDragHandler.initialSize,
                                                              Qt.point(bottomRightDragHandler.translation.x, bottomRightDragHandler.translation.y),
                                                              Qt.BottomEdge | Qt.RightEdge);
                            toplevel.sendResizing(size)
                        }
                    }
                    DragHandler {
                        id: bottomRightDragHandler
                        property size initialSize
                        onActiveChanged: if (active) initialSize = Qt.size(rootChrome.width, rootChrome.height)
                    }
                    HoverHandler {
                        id: bottomRightHover
                        cursorShape: Qt.SizeFDiagCursor
                    }
                }
                // end of resizing components

            }
        }




        layer.enabled: rootChrome.decorationVisible || radiusValue > -1
        layer.effect:  DropShadow
        {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 3
            radius: 12
            samples: 17
            color: "#000000"
        }

    }



    Connections
    {
        target: rootChrome.parent
        ignoreUnknownSignals: true
        enabled: win.formFactor !== Cask.Env.Desktop

        function onWidthChanged()
        {
            if(formFactor !== Cask.Env.Desktop)
            {
                window.maximize()
            }
        }

        function onHeightChanged()
        {
            if(formFactor !== Cask.Env.Desktop)
            {
                window.maximize()
            }
        }
    }

    Connections
    {
        target: win
        ignoreUnknownSignals: true
        function onFormFactorChanged()
        {
            if(win.formFactor === Cask.Env.Desktop)
            {
                rootChrome.shellSurface.toplevel.sendConfigure(Qt.size(previousRect.width, previousRect.height), [3,4])
                rootChrome.x = previousRect.x
                rootChrome.y = previousRect.y
            }else
            {
                previousRect = Qt.rect(rootChrome.x, rootChrome.y, rootChrome.width, rootChrome.height)
                rootChrome.x = output.geometry.x
                rootChrome.y = output.geometry.y
            }
        }
    }



    transform: [
        Scale {
            id:scaleTransform
            origin.x: rootChrome.width / 2
            origin.y: rootChrome.height / 2
        }
    ]

    //    FastBlur
    //    {
    //        id: fastBlur
    //        anchors.fill: parent
    //        source: _cask
    //        radius: 100
    //        transparentBorder: false
    //        cached: true
    //    }

    ShellSurfaceItem
    {
        id: surfaceItem
        property bool valid: false
        property bool isPopup: false
        property bool isTransient: false

        objectName: "SurfaceItem-"+rootChrome.objectName

        y: titlebarHeight
        sizeFollowsSurface: false
        opacity: moving || pinch4.activeScale <= 0.5 ? 0.5 : 1.0
        inputEventsEnabled: !rootChrome.overviewMode
        touchEventsEnabled: !pinch3.active && !pinch4.active
        //        paintEnabled: visible

        focusOnClick:  !altDragHandler.active && !rootChrome.overviewMode
        autoCreatePopupItems: true

        onActiveFocusChanged:
        {
            if(activeFocus)
            {
                rootChrome.raise()
                rootChrome.window.activate()
            }else
            {
                rootChrome.window.deactivate()
            }
        }

        DragHandler {
            id: metaDragHandler
            acceptedModifiers: Qt.MetaModifier
            target: surfaceItem.moveItem
            property var movingBinding: Binding {
                target: surfaceItem.moveItem
                property: "moving"
                value: metaDragHandler.active
            }
        }

        DragHandler {
            id: altDragHandler
            acceptedModifiers: Qt.AltModifier
            target: surfaceItem.moveItem
            property var movingBinding: Binding {
                target: surfaceItem.moveItem
                property: "moving"
                value: altDragHandler.active
            }
        }

        Connections
        {
            target: shellSurface
            ignoreUnknownSignals: true



            //            onSetPopup: {
            //                surfaceItem.isPopup = true
            //                decoration.visible = false
            //            }

            //            onSetTransient: {
            //                surfaceItem.isTransient = true
            //            }

            //            onSetFullScreen: {
            //                surfaceItem.isFullscreen = true
            //                rootChrome.x = 0
            //                rootChrome.y = 0
            //            }

            onSetMaximized:
            {
                console.log("EVENT SEND MAXIMIZED CATCHED <<<<<<<<<<")


            }

            onUnsetMaximized:
            {

            }

            onSetMinimized:
            {

            }
        }

        onWidthChanged: {
            valid =  !surface.cursorSurface && surface.size.width > 0 && surface.size.height > 0
        }

        //        onValidChanged: if (valid) {
        //                            if (isFullscreen) {
        //                                toplevel.sendFullscreen(output.geometry)
        //                            } else if (decorationVisible) {
        //                                createAnimationImpl.start()
        //                            }
        //                        }

        layer.enabled: rootChrome.decorationVisible
        layer.effect: OpacityMask
        {
            maskSource: Maui.ShadowedRectangle
            {
                width: Math.floor(rootChrome.width)
                height: Math.floor(rootChrome.height)

                corners
                {
                    topLeftRadius: 0
                    topRightRadius: 0
                    bottomLeftRadius: decoration.radius
                    bottomRightRadius: decoration.radius
                }
            }
        }
    }


    Loader
    {
        asynchronous: true
        anchors.fill: parent
        active: win.formFactor === Cask.Env.Desktop ? (rootChrome.decorationVisible && !window.maximized) : (rootChrome.height < availableGeometry.height || rootChrome.width < availableGeometry.width || pinch4.active)
        z: surfaceItem.z +9999999999

        sourceComponent: Rectangle
        {
            id: _borders
            radius: decoration.radius
            color: "transparent"
            border.color: Qt.darker(Maui.Theme.backgroundColor, 2.7)
            opacity: 0.8
            border.width: 1

            Rectangle
            {
                anchors.fill: parent
                anchors.margins: 1
                color: "transparent"
                radius: parent.radius - 0.5
                border.width: 1
                border.color: Qt.lighter(Maui.Theme.backgroundColor, 2)
                opacity: 0.4
            }

            DragHandler {
                id: pinch3
                enabled: _borders.visible
                objectName: "3-finger pinch"
                minimumPointCount: 3
                maximumPointCount: 3
                grabPermissions: PointerHandler.CanTakeOverFromAnything

            }

        }
    }


    //    NumberAnimation on x{
    //    id: anim
    //    running: pinch4.activeScale <= 0.5
    //    to: 60
    //    duration: 100
    //    onStopped: {
    //    if(anim.to===60) { anim.from=60; anim.to=50; } else { anim.from=50; anim.to=60 }
    //    start()
    //    }
    //    }


    PinchHandler
    {
        id: pinch4
        objectName: "4-finger pinch"
        minimumPointCount: 4
        maximumPointCount: 4
        minimumScale: 0.5
        maximumScale: 2
        minimumRotation: 0
        maximumRotation: 0

        onActiveChanged: if (!active) {
                             // just a silly way of getting a QSize for sendConfigure()

                             if(activeScale <= minimumScale)
                             {
                                 surfaceItem.surface.client.close()
                             }

                             if(width * scale > availableGeometry.width*0.9 && height * scale > availableGeometry.height*0.9)
                             {
                                 window.maximize()
                                 rootChrome.scale = 1
                                 rootChrome.x =0
                                 rootChrome.y = 0

                                 return;
                             }

                             var minWidth = availableGeometry.width/2
                             var minHeight = availableGeometry.height/2
                             if(width*scale <= minWidth && height *scale < minHeight)
                             {

                                 rootChrome.scale = 1


                                 return;
                             }

                             var size = toplevel.sizeForResize(Qt.size(width * scale, height * scale), Qt.point(0, 0), 0);
                             toplevel.sendConfigure(size, [3] /*XdgShellToplevel.ResizingState*/);
                             rootChrome.scale = 1
                             rootChrome.x = pinch4.centroid.scenePosition.x -(size.width/2)
                             rootChrome.y = pinch4.centroid.scenePosition.y-(size.height/2)
                         }
    }

    DragHandler
    {
        enabled: rootChrome.overviewMode
        xAxis.enabled: true
        onActiveChanged:
        {
            if(!active && (target.y * -1) > 100)
                window.close()
            //            else target.y = 0
        }
    }



    Rectangle
    {
        z: surfaceItem.z + 9999999999
        visible: true
        border.color: "white"
        color: "black"
        radius: Maui.Style.radiusV
        anchors.centerIn: parent
        width: height * 10
        height: moveGeometryText.implicitHeight * 1.5
        Text {
            id: moveGeometryText
            color: "white"
            anchors.centerIn: parent
            //                text: Math.round(rootChrome.x) + "," + Math.round(rootChrome.y) + " on " + rootChrome.screenName + "\n" + Math.round(surfaceItem.output.geometry.height) + "," + Math.round(rootChrome.height) + " ," + rootChrome.scale + " / " + pinch4.activeScale
            //            text: rootChrome.parent.objectName
            text:  rootChrome.appId + Cask.Server.chrome.blurFor(rootChrome.appId)
        }
    }





}
