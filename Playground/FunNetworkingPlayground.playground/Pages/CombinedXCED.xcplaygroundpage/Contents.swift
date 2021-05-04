//: [Previous](@previous)

import Foundation
import FunNetworking
import Funswift
import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

final class ImageViewController: UIViewController {

	private let requestWithCachePolicy = flip(curry(URLRequest.init(url:cachePolicy:timeoutInterval:)))
	private lazy var requestWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))


	struct XcedModel: Codable {
		let month, title, day, imgUrl: String
		let num: Int

		enum CodingKeys: String, CodingKey {
			case month, num, title, day
			case imgUrl = "img"
		}
	}

	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.distribution = .fillProportionally
		return stackView
	}()

	private func createRequest(itemNumber: Int) -> String {
		"https://xkcd.com/\(itemNumber)/info.0.json"
	}

	private func requestXcedInfo(itemNumber: Int) -> Deferred<Either<Error, XcedModel>> {
		return createRequest(itemNumber: itemNumber)
			|> URL.init(string:)
			>=> requestWithTimeout(10)
			|> requestAsyncE
			<&> decodeJsonData(result:)
	}

	private func setupSubview() {
		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: view.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupSubview()

		requestXcedInfo(itemNumber: 1)
			.run { result in
				print(result)
		}
	}
}

let controller = ImageViewController()
controller.view.frame = .init(x: 0, y: 0, width: 320, height: 600)
PlaygroundPage.current.liveView = controller
//: [Next](@next)
