import Cocoa

@objc extension NSWorkspace {

	@objc func desktopImageSnapshot() -> NSImage {

		let windows = CGWindowListCopyWindowInfo(
			[.optionOnScreenOnly],
			CGWindowID(0))! as NSArray

		var index = 0
		for window in windows as! [[String:Any]]  {
			// we need windows owned by Dock
			let owner = window["kCGWindowOwnerName"] as! String
			if owner != "Dock" {
				continue
			}

			// we need windows named like "Desktop Picture %"
			let name = window["kCGWindowName"] as! String
			if !name.hasPrefix("Desktop Picture") {
				continue
			}

			// wee need the one which belongs to the current screen
			let bounds = window["kCGWindowBounds"] as! NSDictionary
			let x = bounds["X"] as! CGFloat
			if x == NSScreen.main!.frame.origin.x {
				index = window["kCGWindowNumber"] as! Int
				break
			}
		}

		let cgImage = CGWindowListCreateImage(
			CGRectZero,
			CGWindowListOption(arrayLiteral: [.optionIncludingWindow]),
			CGWindowID(index),
			[])!

		let image = NSImage(cgImage: cgImage, size: NSScreen.main!.frame.size)
		return image
	}
}
