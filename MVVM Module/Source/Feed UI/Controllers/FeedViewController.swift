//
//  Copyright © Essential Developer. All rights reserved.
//

import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
	private var onViewIsAppearing: (() -> Void)?

	var viewModel: FeedViewModel? {
		didSet { bind() }
	}

	var tableModel = [FeedImageCellController]() {
		didSet { tableView.reloadData() }
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		onViewIsAppearing = { [weak self] in
			self?.refresh()
			self?.onViewIsAppearing = nil
		}
	}

	public override func viewIsAppearing(_ animated: Bool) {
		super.viewIsAppearing(animated)

		onViewIsAppearing?()
	}

	@IBAction private func refresh() {
		viewModel?.loadFeed()
	}

	func bind() {
		title = viewModel?.title
		viewModel?.onLoadingStateChange = { [weak self] isLoading in
			if isLoading {
				self?.refreshControl?.beginRefreshing()
			} else {
				self?.refreshControl?.endRefreshing()
			}
		}
	}

	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.sizeTableHeaderToFit()
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}

	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return cellController(forRowAt: indexPath).view(in: tableView)
	}

	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cancelCellControllerLoad(forRowAt: indexPath)
	}

	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			cellController(forRowAt: indexPath).preload()
		}
	}

	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach(cancelCellControllerLoad)
	}

	private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
		return tableModel[indexPath.row]
	}

	private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
		cellController(forRowAt: indexPath).cancelLoad()
	}
}
