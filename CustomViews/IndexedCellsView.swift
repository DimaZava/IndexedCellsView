//
//  IndexedCellsView.swift
//  IndexedCellsView
//
//  Created by Dmitry Zawadsky on 22.04.2021.
//

import AVKit
import Foundation

protocol IndexedCellsViewDelegate: AnyObject {
    func didSelectIndexItem(_ selectedTitle: String)
}

class IndexedCellsView: UIView {
    
    // MARK: Constants
    private let titlesStackView = UIStackView()
    
    // MARK: Properties
    var titles: [String]
    weak var delegate: IndexedCellsViewDelegate?
    private var lastSelectedTitle: String?
    
    // MARK: Lifecycle
    /// Init with Cells or Sections Titles
    /// - Parameter titles: Cells or Sections Titles
    init(titles: [String] = []) {
        self.titles = titles.map { String($0.prefix(1)) }.reduce(into: [String]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
        super.init(frame: .zero)
        setupInitialState()
    }
    
    required init?(coder: NSCoder) {
        titles = .init()
        super.init(coder: coder)
        setupInitialState()
    }
    
    override func didMoveToSuperview() {
        guard superview != nil else { return }
        updateTitles(with: titles)
    }
    
    func updateTitles(with titles: [String]) {
        
        self.titles = titles.map { String($0.prefix(1)) }.reduce(into: [String]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
        
        titlesStackView.subviews.forEach { $0.removeFromSuperview() }
        titlesStackView.arrangedSubviews.forEach { titlesStackView.removeArrangedSubview($0) }
        
        self.titles.forEach { title in
            let label = Label(text: title)
            titlesStackView.addArrangedSubview(label)
        }
    }
}

extension IndexedCellsView {
    
    class Label: UILabel {
        
        convenience init(text: String) {
            self.init()
            self.text = text
            setupInitialState()
        }
        
        func setupInitialState() {
            adjustsFontSizeToFitWidth = true
            minimumScaleFactor = 0.1
            font = .boldSystemFont(ofSize: 12)
            textAlignment = .center
            textColor = .systemBlue
        }
    }
}

// MARK: - Private Extensions
private extension IndexedCellsView {
    
    func setupInitialState() {
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanAction))
        addGestureRecognizer(gestureRecognizer)
        
        backgroundColor = .clear
        
        addSubview(titlesStackView)
        
        titlesStackView.translatesAutoresizingMaskIntoConstraints = false
        titlesStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        titlesStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        titlesStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titlesStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        titlesStackView.axis = .vertical
        titlesStackView.alignment = .fill
        titlesStackView.distribution = .fillEqually
        titlesStackView.spacing = 0
    }
    
    @objc
    func didPanAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        guard let label = getLabel(for: gestureRecognizer.location(in: self)),
              lastSelectedTitle != label.text else { return }
        
        let text = label.text ?? ""
        
        switch gestureRecognizer.state {
        case .possible:
            break
        case .began:
            processSelection(for: text)
        case .changed:
            processSelection(for: text)
        case .ended:
            processSelection(for: text)
        case .cancelled:
            break
        case .failed:
            break
        @unknown default:
            break
        }
    }
    
    func getLabel(for point: CGPoint) -> Label? {
        titlesStackView.arrangedSubviews.first { $0.frame.contains(point) } as? Label
    }
    
    func processSelection(for text: String) {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        
        lastSelectedTitle = text
        delegate?.didSelectIndexItem(text)
    }
}
