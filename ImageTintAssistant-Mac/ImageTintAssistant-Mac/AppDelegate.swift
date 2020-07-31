//
//  AppDelegate.swift
//  ImageTintAssistant-Mac
//
//  Created by wangzhi on 2019/11/20.
//  Copyright © 2019 BTStudio. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // 应用程序名称默认为TARGET名称,可以在Building Setting --> Product Name 中修改.
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // 注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWindowWillClose), name: NSWindow.willCloseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWindowWillEnterFullScreen), name: NSWindow.willEnterFullScreenNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWindowWillExitFullScreen), name: NSWindow.willExitFullScreenNotification, object: nil)
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
    
    /// 当关闭最后一个窗口时,退出应用程序
    /// - Parameter sender: 应用程序
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // true: 窗口 和 应用程序 都关闭
        // false: 窗口 关闭
        return true
    }
    
    
    // MARK: - Custom Notification
    
    @objc func applicationWindowWillClose(_ aNotification: Notification) {
        print("NSWindow.willCloseNotification")
        
//        NSApp.terminate(self)
    }
    
    @objc func applicationWindowWillEnterFullScreen(_ aNotification: Notification) {
        print("NSWindow.willEnterFullScreenNotification")
    }
    
    @objc func applicationWindowWillExitFullScreen(_ aNotification: Notification) {
        print("NSWindow.willExitFullScreenNotification")
    }
}

