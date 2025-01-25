//
//  VideoPlayerViewController.swift
//  YouTubeApp
//
//  Created by Domini Valencia on 1/21/25.
//


import UIKit
import WebKit

// MARK: - VideoPlayerViewController
class VideoPlayerViewController: UIViewController {
    private let videoId: String
    private let webView = WKWebView()
    private let commentsTableView = UITableView()
    private let viewModel = YouTubeViewModel()

    init(videoId: String) {
        self.videoId = videoId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadVideo()
        bindComments()
        viewModel.fetchComments(videoId: videoId)
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.snp.height).multipliedBy(0.6)
        }

        view.addSubview(commentsTableView)
        commentsTableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        commentsTableView.dataSource = self
        commentsTableView.snp.makeConstraints { make in
            make.top.equalTo(webView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func loadVideo() {
        let embedHTML = """
        <html>
        <body style=\"margin:0;padding:0;\">
        <iframe width=\"100%\" height=\"100%\" src=\"https://www.youtube.com/embed/\(videoId)?playsinline=1\" frameborder=\"0\" allow=\"autoplay; encrypted-media\" allowfullscreen></iframe>
        </body>
        </html>
        """
        webView.loadHTMLString(embedHTML, baseURL: nil)
    }

    private func bindComments() {
        viewModel.$comments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.commentsTableView.reloadData()
            }
            .store(in: &viewModel.cancellables)
    }
}

extension VideoPlayerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let comment = viewModel.comments[indexPath.row]
        cell.configure(with: comment)
        return cell
    }
}

// MARK: - CommentCell
class CommentCell: UITableViewCell {
    private let authorLabel = UILabel()
    private let commentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(authorLabel)
        contentView.addSubview(commentLabel)

        authorLabel.font = UIFont.boldSystemFont(ofSize: 14)
        commentLabel.font = UIFont.systemFont(ofSize: 12)
        commentLabel.numberOfLines = 0

        authorLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
        }

        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview().inset(8)
        }
    }

    func configure(with comment: CommentSnippet) {
        authorLabel.text = comment.authorDisplayName
        commentLabel.text = comment.textDisplay
    }
}
