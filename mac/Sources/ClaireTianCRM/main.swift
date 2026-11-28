// Claire Tian CRM: a mac window around the crm screen (crm.html, crm.js, auth.js from the site, bundled inside the app).
// It reads the same Supabase data as www.claire-tian.com/crm.html, as the person who signs in (email code), so it
// holds no secret: only the publishable key in auth.js. Row level security decides what each account sees.
// The sign-in is kept in the Mac's Keychain; "export" saves a CSV wherever you choose.
import AppKit
import WebKit
import Security

// ---- the sign-in, kept in the Keychain --------------------------------------------------------------
enum Keychain {
    static let service = "com.claire-tian.crm"

    static func read(_ key: String) -> String? {
        let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service,
                                kSecAttrAccount as String: key, kSecReturnData as String: true,
                                kSecMatchLimit as String: kSecMatchLimitOne]
        var out: AnyObject?
        guard SecItemCopyMatching(q as CFDictionary, &out) == errSecSuccess, let d = out as? Data else { return nil }
        return String(data: d, encoding: .utf8)
    }

    static func write(_ key: String, _ value: String?) {
        let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service,
                                kSecAttrAccount as String: key]
        SecItemDelete(q as CFDictionary)
        guard let value = value, let d = value.data(using: .utf8) else { return }
        var add = q
        add[kSecValueData as String] = d
        add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(add as CFDictionary, nil)
    }
}

// ---- the window ---------------------------------------------------------------------------------------
final class CRMWindow: NSObject, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate, NSWindowDelegate {
    let window: NSWindow
    let web: WKWebView
    static let keys = ["ct-auth"]

    override init() {
        let config = WKWebViewConfiguration()
        let content = WKUserContentController()

        // hand the page a store backed by the Keychain (auth.js uses window.ctStore when it is there)
        var saved: [String: String] = [:]
        for k in CRMWindow.keys { if let v = Keychain.read(k) { saved[k] = v } }
        let json = (try? JSONSerialization.data(withJSONObject: saved)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        let bridge = """
        window.__ctData = \(json);
        window.ctStore = {
          get: k => (k in window.__ctData) ? window.__ctData[k] : null,
          set: (k, v) => { window.__ctData[k] = String(v); webkit.messageHandlers.ctStore.postMessage({ k: k, v: String(v) }); },
          del: k => { delete window.__ctData[k]; webkit.messageHandlers.ctStore.postMessage({ k: k, v: null }); }
        };
        """
        content.addUserScript(WKUserScript(source: bridge, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        config.userContentController = content
        config.websiteDataStore = .default()

        web = WKWebView(frame: .zero, configuration: config)
        web.setValue(false, forKey: "drawsBackground")
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        super.init()

        content.add(self, name: "ctStore")
        content.add(self, name: "ctSave")
        web.navigationDelegate = self
        web.uiDelegate = self

        window.title = "claire tian crm"
        window.backgroundColor = NSColor(red: 0xef / 255, green: 0xe8 / 255, blue: 0xd9 / 255, alpha: 1)
        window.minSize = NSSize(width: 900, height: 560)
        window.contentView = web
        window.delegate = self
        window.center()
        window.setFrameAutosaveName("crm")
        load()
    }

    func load() {
        guard let dir = Bundle.main.resourceURL?.appendingPathComponent("web"),
              FileManager.default.fileExists(atPath: dir.appendingPathComponent("crm.html").path) else {
            web.loadHTMLString("<p style='font:14px menlo;padding:40px'>the crm files are missing from this app. rebuild it.</p>", baseURL: nil)
            return
        }
        web.loadFileURL(dir.appendingPathComponent("crm.html"), allowingReadAccessTo: dir)
    }

    // messages from the page
    func userContentController(_ uc: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }
        if message.name == "ctStore", let k = body["k"] as? String, CRMWindow.keys.contains(k) {
            Keychain.write(k, body["v"] as? String)
        } else if message.name == "ctSave", let name = body["name"] as? String, let text = body["text"] as? String {
            let panel = NSSavePanel()
            panel.nameFieldStringValue = name
            panel.canCreateDirectories = true
            panel.beginSheetModal(for: window) { r in
                guard r == .OK, let url = panel.url else { return }
                do { try text.write(to: url, atomically: true, encoding: .utf8) }
                catch { NSAlert(error: error).beginSheetModal(for: self.window) }
            }
        }
    }

    // links (mailto:, the website) open in the Mac's own apps, never inside the crm window
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = action.request.url, url.scheme != "file", url.scheme != "about",
           action.navigationType == .linkActivated || action.targetFrame == nil {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = action.request.url { NSWorkspace.shared.open(url) }
        return nil
    }

    func windowWillClose(_ notification: Notification) { NSApp.terminate(nil) }
}

// ---- the app and its menus (the edit menu is what makes copy and paste work in the text boxes) ---------
final class AppDelegate: NSObject, NSApplicationDelegate {
    var crm: CRMWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.mainMenu = makeMenu()
        crm = CRMWindow()
        crm.window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func reload(_ sender: Any?) { crm.load() }
    @objc func openSite(_ sender: Any?) { NSWorkspace.shared.open(URL(string: "https://www.claire-tian.com")!) }

    func makeMenu() -> NSMenu {
        let main = NSMenu()
        func sub(_ title: String, _ items: [NSMenuItem]) {
            let holder = NSMenuItem(); let m = NSMenu(title: title)
            items.forEach { m.addItem($0) }
            holder.submenu = m; main.addItem(holder)
        }
        func item(_ t: String, _ a: Selector?, _ k: String, _ target: AnyObject? = nil) -> NSMenuItem {
            let i = NSMenuItem(title: t, action: a, keyEquivalent: k); i.target = target; return i
        }
        sub("Claire Tian CRM", [
            item("About Claire Tian CRM", #selector(NSApplication.orderFrontStandardAboutPanel(_:)), ""),
            .separator(),
            item("Hide", #selector(NSApplication.hide(_:)), "h"),
            item("Quit Claire Tian CRM", #selector(NSApplication.terminate(_:)), "q")])
        sub("Edit", [
            item("Undo", Selector(("undo:")), "z"), item("Redo", Selector(("redo:")), "Z"), .separator(),
            item("Cut", #selector(NSText.cut(_:)), "x"), item("Copy", #selector(NSText.copy(_:)), "c"),
            item("Paste", #selector(NSText.paste(_:)), "v"), item("Select All", #selector(NSText.selectAll(_:)), "a")])
        sub("View", [
            item("Reload", #selector(reload(_:)), "r", self),
            item("Open claire-tian.com", #selector(openSite(_:)), "", self)])
        sub("Window", [
            item("Minimize", #selector(NSWindow.performMiniaturize(_:)), "m"),
            item("Close", #selector(NSWindow.performClose(_:)), "w")])
        return main
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
