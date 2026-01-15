import QtQuick
import Quickshell.Io

Item {
    id: root
    visible: false

    property var pluginApi: null
    property int currentThreshold: 80
    property bool isAvailable: false
    property bool isWritable: false

    readonly property string thresholdFile: "/sys/class/power_supply/BAT0/charge_control_end_threshold"

    Component.onCompleted: {
        batteryChecker.running = true
    }

    function refresh() {
        if (thresholdFileView.path !== "") {
            thresholdFileView.reload()
        }
    }

    function restoreSavedThreshold() {
        if (!pluginApi?.pluginSettings)
            return
        const saved = pluginApi.pluginSettings.chargeThreshold
        if (saved >= 1 && saved <= 100 && isWritable) {
            thresholdWriter.command = ["/bin/bash", "-c", `echo ${saved} > ${thresholdFile}`]
            thresholdWriter.running = true
        }
    }

    Process {
        id: batteryChecker
        command: ["test", "-f", root.thresholdFile]
        running: false

        onExited: function (exitCode) {
            if (exitCode === 0) {
                root.isAvailable = true
                thresholdFileView.path = root.thresholdFile
                writeAccessChecker.running = true
            }
        }
    }

    Process {
        id: writeAccessChecker
        command: ["/bin/bash", "-c", `test -w ${root.thresholdFile} && echo 1 || echo 0`]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.isWritable = text.trim() === "1"
                if (root.isWritable) {
                    root.restoreSavedThreshold()
                }
            }
        }
    }

    FileView {
        id: thresholdFileView
        path: ""
        printErrors: false

        onLoaded: {
            const value = parseInt(text().trim())
            if (!isNaN(value) && value >= 0 && value <= 100) {
                root.currentThreshold = value
            }
        }
    }

    Process {
        id: thresholdWriter
        running: false
    }
}
