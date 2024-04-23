/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Message table view controller
*/

import UIKit
import CoreNFC

@available(iOS 17.0, *)
extension MessagesTableViewController {
    

    // MARK: - Table View Functions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tickers.tickers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        let message = self.tickers.tickers[indexPath.row]
        cell.textLabel?.text = message
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cell = tableView.cellForRow(at: indexPath)
        if (cell?.accessoryType == .checkmark) {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
        cell?.setSelected(false, animated: true)
        self.selecteds[indexPath.row] = !self.selecteds[indexPath.row]
        print(self.selecteds)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let indexPath = tableView.indexPathForSelectedRow,
//            let payloadsTableViewController = segue.destination as? PayloadsTableViewController else {
//            return
//        }
//        payloadsTableViewController.message = detectedMessages[indexPath.row]
//    }

}
