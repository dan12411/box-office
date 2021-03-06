//
//  NowPlayingViewAdapter.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeMedia
import BoxOfficeNowPlaying
import BoxOfficeCommon

final class NowPlayingViewAdapter {

  private weak var controller: NowPlayingViewController?
  private let imageLoader: ImageDataLoader
  private let onSelectCallback: (Int) -> Void

  init(controller: NowPlayingViewController, imageLoader: ImageDataLoader, onSelectCallback: @escaping (Int) -> Void) {
    self.controller = controller
    self.imageLoader = imageLoader
    self.onSelectCallback = onSelectCallback
  }

}

extension NowPlayingViewAdapter: NowPlayingView {
  func display(_ viewModel: NowPlayingViewModel) {
    let newItems = viewModel.items.map(makeCellController)
    
    if viewModel.pageNumber == 1 {
      controller?.set(newItems)
    } else {
      controller?.append(newItems)
    }
  }
}

private extension NowPlayingViewAdapter {
  func makeCellController(for model: NowPlayingCard) -> NowPlayingCardCellController {
    let adapter = NowPlayingImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<NowPlayingCardCellController>, UIImage>(
      baseURL: URL(string: "https://image.tmdb.org/t/p/w500/")!, // TODO: Create URL factory
      model: model,
      imageLoader: imageLoader
    )
    
    let view = NowPlayingCardCellController(id: model.id, delegate: adapter)

    view.didSelect = { [weak self] in
      self?.onSelectCallback(model.id)
    }

    adapter.presenter = NowPlayingImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)

    return view
  }
}

extension WeakRefVirtualProxy: NowPlayingImageView where T: NowPlayingImageView, T.Image == UIImage {
  public func display(_ model: NowPlayingImageViewModel<UIImage>) {
    object?.display(model)
  }
}
