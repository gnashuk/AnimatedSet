//
//  SetViewController.swift
//  Animated Set
//
//  Created by Oleg Gnashuk on 3/10/18.
//  Copyright © 2018 Oleg Gnashuk. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {
    
    private var game = SetGame()
    private var selectedCards = [CardView]()
    private var setsFound = 0
    
    lazy private var grid: Grid = self.createGrid()
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var flyawayBehavior = FlyawayCardBehavior(in: animator)
    
    @IBOutlet weak var boardView: UIView! {
        didSet {
            let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(shuffleCards(sender:)))
            rotateRecognizer.rotation = 1.5
            boardView.addGestureRecognizer(rotateRecognizer)
        }
    }
    
    @IBOutlet weak var deckView: UIView! {
        didSet {
            deckView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchDeck(_:))))
        }
    }
    
    @IBOutlet weak var setsView: DeckView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var stackSuperview: UIView!
    
    @objc func touchCard(_ recognizer: UITapGestureRecognizer) {
        if let cardView = recognizer.view as? CardView {
            if let cardIndex = game.cardsOnTable.index(of: cardView.card) {
                game.chooseCard(at: cardIndex)
                choose(card: cardView)
                updateViewFromModel()
            } else {
                print("The chosen card was not in cardButtons")
            }
        }
    }
    
    @objc func touchDeck(_ recognizer: UITapGestureRecognizer) {
        game.draw()
        updateViewFromModel()
    }
    
    @IBAction func newGamePressed(_ sender: UIButton) {
        game = SetGame()
        resetView()
        updateViewFromModel()
        hideButtonIfNeeded()
        selectedCards.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(SetViewController.performRearrangeAnimation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        grid = createGrid()
        grid.cellCount = game.cardsOnTable.count
        updateViewFromModel()
    }
    
    @objc private func shuffleCards(sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .ended:
            game.shuffle()
            updateViewFromModel()
        default:
            break
        }
    }
    
    private func choose(card selectedCard: CardView) {
        if selectedCards.contains(selectedCard) {
            selectedCard.isSelected = false
            selectedCards.remove(at: selectedCards.index(of: selectedCard)!)
            return
        }
        selectedCards.append(selectedCard)
        if selectedCards.count == 3 {
            setsFound += 1
            cardViews.forEach { cardView in
                cardView.isSelected = false
                cardView.isHinted = false
            }
        } else {
            selectedCard.isSelected = true
            selectedCard.isHinted = false
        }
    }
    
    private func updateViewFromModel() {
        grid.cellCount = game.cardsOnTable.count
        if cardViews.count == game.cardsOnTable.count {
            if selectedCards.count == 3 {
                if !game.lastDealtCards.isEmpty {
                    var delay = 0.0
                    selectedCards.forEach({ cardView in
                        cardView.alpha = 0
                        
                        let flyawayCard = CardView()
                        flyawayCard.card = cardView.card
                        flyawayCard.isFaceUp = true
                        flyawayCard.isPlaceholder = true
                        flyawayCard.contentMode = .redraw
                        flyawayCard.isOpaque = false
                        flyawayCard.layer.cornerRadius = 8.0
                        flyawayCard.frame = cardView.frame
                        boardView.addSubview(flyawayCard)
                        flyawayCard.layer.zPosition = .greatestFiniteMagnitude
                        
                        let dealCard = CardView()
                        dealCard.card = game.lastDealtCards.popLast()!
                        cardView.card = dealCard.card
                        dealCard.isPlaceholder = true
                        dealCard.contentMode = .redraw
                        dealCard.isOpaque = false
                        dealCard.layer.cornerRadius = 8.0
                        dealCard.frame = stackView.convert(deckView.frame, to: stackSuperview)
                        dealCard.center = CGPoint(x: dealCard.frame.midX, y: deckMidY)
                        boardView.addSubview(dealCard)
                        dealCard.layer.zPosition = .greatestFiniteMagnitude
                        
                        performDealAnimation(
                            on: dealCard,
                            rect: cardView.frame,
                            after: delay,
                            completion: {
                                UIView.transition(
                                    with: dealCard,
                                    duration: 0.5,
                                    options: [.transitionFlipFromLeft],
                                    animations: {
                                        dealCard.isFaceUp = !dealCard.isFaceUp
                                    }
                                )
                                Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false, block: { timer in
                                    dealCard.removeFromSuperview()
                                    
                                    cardView.alpha = 1
                                })
                                self.setsView.labelText = "\(self.setsFound) Set\(self.setsFound != 1 ? "s" : "")"
                            }
                        )
                        performFlyawayAnimation(on: flyawayCard)
                        delay += 0.6
                    })
                } else {
                    selectedCards.forEach({ cardView in
                            let colorAnimation = CABasicAnimation(keyPath: "borderColor")
                            colorAnimation.fromValue = UIColor.red.cgColor
                            colorAnimation.toValue = UIColor.red.cgColor
                        
                            let widthAnimation = CABasicAnimation(keyPath: "borderWidth")
                            widthAnimation.fromValue = cardView.layer.borderWidth
                            widthAnimation.toValue = 7.0
                            widthAnimation.duration = 0.5
                        
                            let bothAnimations = CAAnimationGroup()
                            bothAnimations.duration = 0.5
                            bothAnimations.animations = [colorAnimation, widthAnimation]
                            bothAnimations.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        
                            cardView.layer.add(bothAnimations, forKey: "color and width")
                        })
                    }
                selectedCards.removeAll()
            }
        } else {
            if cardViews.count > game.cardsOnTable.count {
                removeCards()
            } else if cardViews.count < game.cardsOnTable.count {
                addMoreCards(animationDelay: 0.6)
            }
            performRearrangeAnimation()
        }
        hideButtonIfNeeded()
    }
    
    @objc private func performRearrangeAnimation() {
        var index = 0
        for cardView in cardViews {
            if let rect = grid[index] {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.6,
                    delay: 0,
                    options: [],
                    animations: { cardView.frame = rect.insetBy(dx: self.inset, dy: self.inset) }
                )
                index += 1
            }
        }
    }
    
    private func addMoreCards(animationDelay initDelay: Double = 0) {
        var delay = initDelay
        for index in cardViews.count..<game.cardsOnTable.count {
            let cardView = CardView()
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchCard(_:))))
            if let rect = grid[index] {
                cardView.card = game.cardsOnTable[index]
                cardView.frame = stackView.convert(deckView.frame, to: stackSuperview)
                cardView.center = CGPoint(x: cardView.frame.midX, y: deckMidY)
                cardView.contentMode = .redraw
                cardView.isOpaque = false
                cardView.layer.cornerRadius = 8.0
                self.boardView.addSubview(cardView)
                performDealAnimation(
                    on: cardView,
                    rect: rect.insetBy(dx: inset, dy: inset),
                    after: delay,
                    completion: {
                        cardView.isFaceUp = !cardView.isFaceUp
                    }
                )
                delay += 0.3
            }
        }
    }
    
    private func removeCards() {
        cardViews.forEach({ (cardView) in
            if !game.cardsOnTable.contains(cardView.card) {
                cardView.layer.zPosition = .greatestFiniteMagnitude
                cardView.isPlaceholder = true
                performFlyawayAnimation(on: cardView)
            }
        })
        selectedCards.removeAll()
        self.setsView.labelText = "\(self.setsFound) Set\(self.setsFound != 1 ? "s" : "")"
    }
    
    private func performDealAnimation(on cardView: CardView, rect frame: CGRect, after delay: TimeInterval, completion animation: (() -> Void)?) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.6,
            delay: delay,
            options: [.curveEaseIn],
            animations: {
                cardView.frame = frame
            },
            completion: { finished in
                UIView.transition(
                    with: cardView,
                    duration: 0.5,
                    options: [.transitionFlipFromLeft],
                    animations: animation
                )
            }
        )
    }
    
    private func performFlyawayAnimation(on cardView: CardView) {
        flyawayBehavior.addItem(cardView)
        Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false, block: { timer in
            self.flyawayBehavior.removeItem(cardView)
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 0.0,
                options: [],
                animations: {
                    cardView.frame = self.stackView.convert(self.setsView.frame, to: self.stackSuperview)
                    cardView.center = CGPoint(x: cardView.frame.midX, y: self.deckMidY)
                },
                completion: { finished in
                    cardView.removeFromSuperview()
                }
            )
        })
        
    }
    
    private func createGrid() -> Grid {
        return Grid(layout: Grid.Layout.aspectRatio(2.0), frame: boardView.bounds)
    }
    
    private func hideButtonIfNeeded() {
        if game.deck.count == 0 {
            deckView.isHidden = true
        } else {
            deckView.isHidden = false
        }
    }
    
    private func resetView() {
        cardViews.forEach { $0.removeFromSuperview() }
    }
    
}

extension SetViewController {
    private var cardViews: [CardView] {
        return (boardView.subviews as! [CardView]).filter( { !$0.isPlaceholder } )
    }
    
    private var inset: CGFloat {
        return CGFloat(120 / (game.cardsOnTable.count > 0 ? game.cardsOnTable.count : 1))
    }
    
    private var deckMidY: CGFloat {
        let stackMidY = stackSuperview.frame.minY + stackSuperview.frame.height / 2
        if #available(iOS 11.0, *) {
            return stackMidY - view.safeAreaLayoutGuide.layoutFrame.minY
        } else {
            return stackMidY - 20
        }
    }
}



