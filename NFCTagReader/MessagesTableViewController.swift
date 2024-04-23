/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The view controller that scans and displays NDEF messages.
*/

import UIKit
import CoreNFC

extension NFCTypeNameFormat: CustomStringConvertible {
    public var description: String {
        switch self {
        case .nfcWellKnown: return "NFC Well Known type"
        case .media: return "Media type"
        case .absoluteURI: return "Absolute URI type"
        case .nfcExternal: return "NFC External type"
        case .unknown: return "Unknown type"
        case .unchanged: return "Unchanged type"
        case .empty: return "Empty payload"
        @unknown default: return "Invalid data"
        }
    }
}
/// - Tag: MessagesTableViewController
@available(iOS 17.0, *)
class MessagesTableViewController: UITableViewController, NFCNDEFReaderSessionDelegate {

    // MARK: - Properties
    var tickers = Tickers.shared

    let reuseIdentifier = "reuseIdentifier"
    var selecteds = [Bool]()
    var session: NFCNDEFReaderSession?
    @IBOutlet var table: UITableView?;

    // MARK: - Actions
    
    override func viewWillAppear(_ animated: Bool) {
        Task {
            try await tickers.refresh()
            self.selecteds = [Bool]()
            for ticker in self.tickers.tickers {
                self.selecteds.append(true)
            }
            tableView.reloadData()
        }
    }

    /// - Tag: beginWriting
    @IBAction func beginWrite(_ sender: Any) {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        print("writing")
        session?.alertMessage = "Hold your iPhone near the NFC tag to write data!"
        session?.begin()
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    }
    
    private func handleError(e: String) {
      session?.alertMessage = e
      session?.invalidate()
    }
    
    /// - Tag: writeToTag
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            // Restart polling in 500 milliseconds.
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        print("writing...")
        var msg = ""
        for (i, ticker) in self.tickers.tickers.enumerated() {
            if (self.selecteds[i]) {
                msg += ticker + ","
            }
        }
        print(msg)
        
        // TODO: remove return and thats about it
        return;
        // Connect to the found tag and write an NDEF message to it.
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.alertMessage = "Unable to query the NDEF status of tag."
                    session.invalidate()
                    return
                }

                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = "Tag is not NDEF compliant."
                    session.invalidate()
                case .readOnly:
                    session.alertMessage = "Tag is read only."
                    session.invalidate()
                case .readWrite:
                    guard let payload = NFCNDEFPayload
                          .wellKnownTypeTextPayload(string: msg, locale: Locale.current)
                          else {
                            self.handleError(e: "Could not create payload")
                            return
                        }

                        // 2
                        let message = NFCNDEFMessage(records: [payload])

                        // 3
                        tag.writeNDEF(message) { error in
                          if let error = error {
                              self.handleError(e: error.localizedDescription)
                            return
                          }

                          self.session?.alertMessage = "Successfully wrote data."
                          self.session?.invalidate()
                    }
                @unknown default:
                    session.alertMessage = "Unknown NDEF tag status."
                    session.invalidate()
                }
            })
        })
    }
    
    /// - Tag: sessionBecomeActive
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        
    }
    
    /// - Tag: endScanning
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a success read
            // during a single tag read mode, or user canceled a multi-tag read mode session
            // from the UI or programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
