import UIKit

protocol NotificationManagerProtocol: AnyObject
{
    func send(_ notification: String?)
    func send(_ notification: String?, withData data: [AnyHashable: Any]?)
}

class NotificationManager: NSObject, NotificationManagerProtocol
{
    func send(_ notification: String?)
    {
        dispatchMain
        {
            NotificationCenter.default.post(name: NSNotification.Name(notification ?? ""), object: nil)
        }
    }

    func send(_ notification: String?, withData data: [AnyHashable: Any]?)
    {
        dispatchMain
        {
            NotificationCenter.default.post(name: NSNotification.Name(notification ?? ""), object: nil, userInfo: data)
        }
    }

    private func dispatchMain(_ callback: @escaping () -> Void)
    {
        if Thread.isMainThread
        {
            callback()
        }
        else
        {
            let queue = DispatchQueue.main

            queue.async
            {
                callback()
            }
        }
    }
}
