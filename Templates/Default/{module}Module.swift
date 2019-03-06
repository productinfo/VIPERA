//
//  {module}DefaultBuilder.swift
//  {project}
//
//  Created by {author} on {date}.
//

import Foundation
import UIKit

class {module}Module {

    func buildDefault() -> UIViewController {
        let view = {module}DefaultView()
        let interactor = {module}DefaultInteractor()
        let presenter = {module}DefaultPresenter()
        let router = {module}DefaultRouter()

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
