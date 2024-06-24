import UIKit

public final class FeedRefreshViewController: NSObject {
	public lazy var view = binded(UIRefreshControl())
	public lazy var errorView = ErrorView()

	var viewModel: FeedViewModel

	init(viewModel: FeedViewModel) {
		self.viewModel = viewModel
	}

	@IBAction func refresh() {
		errorView.hideMessage()
		viewModel.loadFeed()
	}

	private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
		viewModel.onLoadingStateChange = { [weak self] isLoading in
			if isLoading {
				self?.view.beginRefreshing()
			} else {
				self?.view.endRefreshing()
			}
		}
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
}
