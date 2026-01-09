# This Python file uses the following encoding: utf-8
from PySide6.QtCore import QtMsgType, qInstallMessageHandler

class PyMessageHandler:
    def __init__(self):
        super().__init__()

        qInstallMessageHandler(self.qml_message_handler)

    @staticmethod
    def qml_message_handler(mode, context, message):
        """Перехват логов из QML"""
        if mode == QtMsgType.QtDebugMsg:
            prefix = "[QML-DEBUG]"
        elif mode == QtMsgType.QtInfoMsg:
            prefix = "[QML-INFO]"
        elif mode == QtMsgType.QtWarningMsg:
            prefix = "[QML-WARNING]"
        elif mode == QtMsgType.QtCriticalMsg:
            prefix = "[QML-CRITICAL]"
        elif mode == QtMsgType.QtFatalMsg:
            prefix = "[QML-FATAL]"
        else:
            prefix = "[QML]"

        # print(f"{prefix} {message}")
        # print(f"{prefix} {context.file}:{context.line} — {message}")
        print(f"{prefix} {context.file}:{context.line} — {message}")
