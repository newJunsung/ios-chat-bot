//
//  GPTChattingViewController.swift
//  ChatBot
//
//  Created by Tacocat on 1/1/24.
//

import UIKit
import Combine

final class GPTChattingViewController: UIViewController {
    enum Section {
        case main
    }
    
    enum Row: Hashable {
        case forMain(message: Model.GPTMessage)
    }
    
    private lazy var chatCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GPTChattingCell.self, forCellWithReuseIdentifier: "\(type(of: GPTChattingCell.self))")
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
         stackView.axis = .horizontal
         stackView.translatesAutoresizingMaskIntoConstraints = false
         stackView.distribution = .fill
         stackView.addArrangedSubview(commentTextView)
         stackView.addArrangedSubview(sendButton)
         return stackView
     }()
    
    private lazy var commentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.layer.cornerRadius = ((textView.font?.pointSize ?? 24) / 2)
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 32)
        let uiImage = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: imageConfiguration)
        button.setImage(uiImage, for: .normal)
        button.contentMode = .scaleToFill
        button.addTarget(nil, action: #selector(tapSendButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private let viewModel: any GPTChattingVMProtocol
    
    private var chattingDataSource: UICollectionViewDiffableDataSource<Section, Row>!
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: any GPTChattingVMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        bind(to: viewModel)
        configureDataSource()
        viewModel.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.onViewWillDisappear()
    }
    
    private func bind(to viewModel: any GPTChattingVMProtocol) {
        viewModel.updateChattings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (messages, indexToUpdate) in
                self?.updateCollectionView(messages.map { Row.forMain(message: $0) }, indexToUpdate: indexToUpdate)
            }
            .store(in: &cancellables)
        
        viewModel.error
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] error in
                guard let self = self else { return Empty<Void, Never>().eraseToAnyPublisher() }
                return UIAlertController.presentErrorPublisher(on: self, with: error)
            }
            .sink { _ in }
            .store(in: &cancellables)
    }
}

// MARK: - set Views
extension GPTChattingViewController {
    private func configureUI() {
        view.addSubview(chatCollectionView)
        view.addSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            chatCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            chatCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            chatCollectionView.bottomAnchor.constraint(equalTo: horizontalStackView.topAnchor),
            horizontalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
            horizontalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            horizontalStackView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -4)
        ])
    }
}

// MARK: - configure Collection View
extension GPTChattingViewController {
    private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func updateCollectionView(_ updatedMessages: [Row], indexToUpdate: Int) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        snapshot.appendItems(updatedMessages)
        chattingDataSource.apply(snapshot)
        
        chatCollectionView.scrollToItem(at: IndexPath(row: indexToUpdate, section: 0), at: .bottom, animated: true)
    }
}

// MARK: - configure Diffable Data Source
extension GPTChattingViewController {
    private func configureDataSource() {
        let cellResistration = UICollectionView.CellRegistration<GPTChattingCell, Row> { cell, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .forMain(let message):
                cell.configureCell(to: message)
            }
        }
        
        chattingDataSource = UICollectionViewDiffableDataSource<Section, Row>(
            collectionView: chatCollectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                collectionView.dequeueConfiguredReusableCell(using: cellResistration, for: indexPath, item: itemIdentifier)
            }
        )
    }
}

 // MARK: - set UIRespond
extension GPTChattingViewController {
    @objc
    private func tapSendButton(_ sender: Any) {
        viewModel.sendChat(commentTextView.text)
        commentTextView.text = nil
    }
}
