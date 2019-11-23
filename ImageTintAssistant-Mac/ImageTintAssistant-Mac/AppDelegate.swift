//
//  AppDelegate.swift
//  ImageTintAssistant-Mac
//
//  Created by hadlinks on 2019/11/20.
//  Copyright © 2019 BTStudio. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // 应用程序名称默认为TARGET名称,可以在Building Setting --> Product Nmae 中修改.
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // 1. 点击关闭按钮时,直接让应用程序退出
        // 注册 willCloseNotification 通知,然后在通知方法中退出应用程序
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWindowWillClose), name: NSWindow.willCloseNotification, object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        print("applicationWillTerminate")
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        print("applicationShouldTerminate")
        
        // 返回 .terminateCancel 时,终止进程将会停止,并将控制权交回给主事件循环
        // 返回 .terminateNow 时,该方法会向通知中心发布 willTerminateNotification 消息
        // 返回 .terminateLater 时,则该应用程序将以modalPanel模式运行其RunLoop,直到调用toApplicationShouldTerminate:方法为止
        return NSApplication.TerminateReply.terminateNow
    }
    
    func applicationWillBecomeActive(_ notification: Notification) {
        // 打开本应用程序 / 切换至本应用程序
        print("applicationWillBecomeActive")
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        // 点击最小化按钮 / command + H / 切换至其他应用程序
        print("applicationWillResignActive")
    }
    
    func applicationWillHide(_ notification: Notification) {
        // command + H
        print("applicationWillHide")
    }
    
    
    // MARK: - Notification
    
    @objc func applicationWindowWillClose(_ aNotification: Notification) {
        NSApp.terminate(self)
    }
}

