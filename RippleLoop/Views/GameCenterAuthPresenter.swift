import SwiftUI
import UIKit

struct GameCenterAuthPresenter: UIViewControllerRepresentable {
    let viewController: UIViewController?

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ host: UIViewController, context: Context) {
        guard let viewController else { return }
        guard host.presentedViewController == nil else { return }
        host.present(viewController, animated: true)
    }
}
