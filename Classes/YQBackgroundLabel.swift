//
//  YQBackgroundLabel.swift
//  Pods
//
//  Created by 王叶庆 on 2023/7/13.
//

import Foundation
class YQBackgroundLabel: UIView {
   
    private let label = UILabel()
    private let backgroundView = UIView()
    private var contentInsets = UIEdgeInsets.zero
    @IBInspectable public var text: String? {
        didSet {
            label.text = text
            invalidateIntrinsicContentSize()
        }
    }

    public var color: UIColor? {
        didSet {
            backgroundView.backgroundColor = color
        }
    }

    public init(_ text: String? = nil, contentInsets: UIEdgeInsets = .zero, configure: ((UIView, UILabel) -> Void)? = nil) {
        self.text = text
        self.contentInsets = contentInsets
        super.init(frame: CGRect.zero)
        label.text = text
        commonInit()
        configure?(backgroundView, label)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        backgroundColor = UIColor.clear
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.textAlignment = .center
        addSubview(label)
        let bgConstraints = [
            leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            topAnchor.constraint(equalTo: backgroundView.topAnchor),
            trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
        ]
        addConstraints(bgConstraints)
        NSLayoutConstraint.activate(bgConstraints)
        var labelConstraints = [
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left),
            label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: contentInsets.top),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right),
            label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -contentInsets.bottom),
        ]
        for constraint in labelConstraints {
            constraint.priority = .required
        }
        labelConstraints.append(label.centerYAnchor.constraint(equalTo: centerYAnchor))
        addConstraints(labelConstraints)
        NSLayoutConstraint.activate(labelConstraints)
    }

//    public override var intrinsicContentSize: CGSize {
//        guard let text = text, !text.isBlank else {
//            return .zero
//        }
//        let labelSize = label.intrinsicContentSize
//        let size = CGSize(width: labelSize.width + contentInsets.left + contentInsets.right, height: labelSize.height + contentInsets.top + contentInsets.bottom)
//        return size
//    }
}
