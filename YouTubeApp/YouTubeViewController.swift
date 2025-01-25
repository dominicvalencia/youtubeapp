//
//  YouTubeViewController.swift
//  YouTubeApp
//
//  Created by Domini Valencia on 1/21/25.
//

import UIKit
import SnapKit
import Combine
import SDWebImage

// MARK: - YouTubeViewController
class YouTubeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    private let viewModel = YouTubeViewModel()
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.searchVideos(query: "iOS Development")
    }

    private func setupUI() {
        view.backgroundColor = .white

        searchBar.placeholder = "Search YouTube"
        searchBar.delegate = self
        view.addSubview(searchBar)

        tableView.register(VideoCell.self, forCellReuseIdentifier: "VideoCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120
        view.addSubview(tableView)

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func bindViewModel() {
        viewModel.$videos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .sink { [weak self] message in
                guard let message = message else { return }
                self?.showError(message: message)
            }
            .store(in: &cancellables)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        viewModel.searchVideos(query: query)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        let video = viewModel.videos[indexPath.row]
        cell.configure(with: video)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = viewModel.videos[indexPath.row]
        let playerVC = VideoPlayerViewController(videoId: video.videoId)
        self.navigationController?.pushViewController(playerVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - VideoCell
class VideoCell: UITableViewCell {
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true

        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 2

        thumbnailImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(120)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(8)
            make.trailing.top.bottom.equalToSuperview().inset(8)
        }
    }

    func configure(with video: Video) {
        titleLabel.text = video.title
        if let url = URL(string: video.thumbnailURL) {
            thumbnailImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
    }
}
