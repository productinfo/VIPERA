
import Foundation
import UIKit

class ___VARIABLE_SERVICENAME___Module {

    func buildDefault() -> UIViewController {
        let view = ___VARIABLE_SERVICENAME___DefaultView()
        let interactor = ___VARIABLE_SERVICENAME___DefaultInteractor()
        let presenter = ___VARIABLE_SERVICENAME___DefaultPresenter()
        let router = ___VARIABLE_SERVICENAME___DefaultRouter()

        view.presenter = presenter

        presenter.interactor = interactor
        presenter.view = view
        presenter.router = router

        interactor.presenter = presenter

        router.presenter = presenter
        router.viewController = view
        
        return view
    }
}
