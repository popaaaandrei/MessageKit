/*
 MIT License

 Copyright (c) 2017-2018 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

open class MessagesViewController: UIViewController {
    
    // MARK: - Properties [Public]

    /// The `MessagesCollectionView` managed by the messages view controller object.
    open var messagesCollectionView = MessagesCollectionView()

    /// The `MessageInputBar` used as the `inputAccessoryView` in the view controller.
    open var messageInputBar = MessageInputBar()
    var messageInputBarBottomConstraint : NSLayoutConstraint?

    /// A Boolean value that determines whether the `MessagesCollectionView` scrolls to the
    /// bottom whenever the `InputTextView` begins editing.
    ///
    /// The default value of this property is `false`.
    open var scrollsToBottomOnKeybordBeginsEditing: Bool = false
    
    /// A Boolean value that determines whether the `MessagesCollectionView`
    /// maintains it's current position when the height of the `MessageInputBar` changes.
    ///
    /// The default value of this property is `false`.
    open var maintainPositionOnKeyboardFrameChanged: Bool = false

    open override var canBecomeFirstResponder: Bool {
        return true
    }

//    open override var inputAccessoryView: UIView? {
//        return messageInputBar
//    }

    open override var shouldAutorotate: Bool {
        return false
    }

    /// A Boolean value used to determine if `viewDidLayoutSubviews()` has been called.
    private var isFirstLayout: Bool = true
    
    /// Indicated selected indexPath when handle menu action
    var selectedIndexPathForMenu: IndexPath?

    var messageCollectionViewBottomInset: CGFloat = 0 {
        didSet {
            messagesCollectionView.contentInset.bottom = messageCollectionViewBottomInset
            messagesCollectionView.scrollIndicatorInsets.bottom = messageCollectionViewBottomInset
        }
    }

    // MARK: - View Life Cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        setupSubviews()
        setupConstraints()
        registerReusableViews()
        setupDelegates()
        addMenuControllerObservers()
    }

    open override func viewDidLayoutSubviews() {
        // Hack to prevent animation of the contentInset after viewDidAppear
        if isFirstLayout {
            defer { isFirstLayout = false }
            addKeyboardObservers()
            messageCollectionViewBottomInset = keyboardOffsetFrame.height
        }
        adjustScrollViewInset()
    }

    // MARK: - Initializers

    deinit {
        removeKeyboardObservers()
        removeMenuControllerObservers()
    }

    // MARK: - Methods [Private]

    /// Sets the default values for the MessagesViewController
    private func setupDefaults() {
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
        messagesCollectionView.keyboardDismissMode = .interactive
        messagesCollectionView.alwaysBounceVertical = true
    }

    /// Sets the delegate and dataSource of the messagesCollectionView property.
    private func setupDelegates() {
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
    }

    /// Adds the messagesCollectionView to the controllers root view.
    private func setupSubviews() {
        view.addSubview(messagesCollectionView)
        view.addSubview(messageInputBar)
    }

    /// Registers all cells and supplementary views of the messagesCollectionView property.
    private func registerReusableViews() {
        messagesCollectionView.register(TextMessageCell.self)
        messagesCollectionView.register(MediaMessageCell.self)
        messagesCollectionView.register(LocationMessageCell.self)

        messagesCollectionView.register(MessageFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter)
        messagesCollectionView.register(MessageHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        messagesCollectionView.register(MessageDateHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }

    
    /// Sets the constraints of the `MessagesCollectionView`.
    private func setupConstraints() {
        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        

        if #available(iOS 11.0, *) {
            
            messagesCollectionView.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            messagesCollectionView.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            messagesCollectionView.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            messagesCollectionView.bottomAnchor
                .constraint(equalTo: messageInputBar.topAnchor).isActive = true
            
            messageInputBar.topAnchor
                .constraint(equalTo: messagesCollectionView.bottomAnchor).isActive = true
            messageInputBar.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            messageInputBar.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            messageInputBarBottomConstraint = messageInputBar.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            messageInputBarBottomConstraint?.isActive = true
            
        } else {
            
            messagesCollectionView.topAnchor
                .constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            messagesCollectionView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor).isActive = true
            messagesCollectionView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor).isActive = true
            messagesCollectionView.bottomAnchor
                .constraint(equalTo: messageInputBar.topAnchor).isActive = true
            
            messageInputBar.topAnchor
                .constraint(equalTo: messagesCollectionView.bottomAnchor).isActive = true
            messageInputBar.leadingAnchor
                .constraint(equalTo: view.leadingAnchor).isActive = true
            messageInputBar.trailingAnchor
                .constraint(equalTo: view.trailingAnchor).isActive = true
            messageInputBarBottomConstraint = messageInputBar.bottomAnchor
                .constraint(equalTo: bottomLayoutGuide.topAnchor)
            messageInputBarBottomConstraint?.isActive = true

        }
        
    }
}
