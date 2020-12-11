//
//  ViewController.swift
//  Apple Pie
//
//  Created by Uji Saori on 2020-12-10.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var treeImageView: UIImageView!
    @IBOutlet var guessTextField: UITextField!
    @IBOutlet var correctWordLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var letterButtons: [UIButton]!
    
    var listOfWords = ["a", "ab", "abc", "abcd", "abcde"]
    let incorrectMovesAllowed = 7
    var totalWins = 0 {
        didSet {
            newRound()
        }
    }
    var totalLosses = 0 {
        didSet {
            newRound()
        }
    }
    var currentGame: Game!
    var activeTextField : UITextField? = nil
    let defaultTextField = "Type your guess here..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBehaivour()
        newRound()
    }
    
    func setBehaivour() {
        // add delegate to all textfields to self (this view controller)
        guessTextField.delegate = self
        
        // enable to dismiss focus whenever tap
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        // call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        var shouldMoveViewUp = false
        
        // if active text field is not nil
        if let activeTextField = activeTextField {
            
            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
            
            let topOfKeyboard = self.view.frame.height - keyboardSize.height
            
            // if the bottom of Textfield is below the top of keyboard, move up
            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
        }
        
        if(shouldMoveViewUp) {
            self.view.frame.origin.y = 0 - keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.view.frame.origin.y = 0
    }
    

    @IBAction func letterButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        let letterString = sender.title(for: .normal)!
        let letter = Character(letterString.lowercased())
        currentGame.playerGuessed(letter: letter)
        updateUIBeforeResult()
        updateGameState()
    }
    
    func newRound() {
        resetTextField()
        if !listOfWords.isEmpty {
            let newWord = listOfWords.removeFirst()
            currentGame = Game(word: newWord, incorrectMovesRemaining: incorrectMovesAllowed, guessedLetters: [])
            enableControllers(true)
            updateUI()
        } else {
            enableControllers(false)
        }
    }
    
    func enableControllers(_ enable: Bool) {
        guessTextField.isEnabled = enable
        for button in letterButtons {
            button.isEnabled = enable
        }
        correctWordLabel.isEnabled = enable
    }
    
    func resetTextField() {
        guessTextField.text = defaultTextField
        guessTextField.textColor = .gray
    }
    
    func updateUIBeforeResult() {
        updateRevealLabel()
        treeImageView.image = UIImage(named: "Tree \(currentGame.incorrectMovesRemaining)")
    }
    
    func updateUI() {
        updateRevealLabel()
        treeImageView.image = UIImage(named: "Tree \(currentGame.incorrectMovesRemaining)")
        scoreLabel.text = "Wins: \(totalWins), Losses: \(totalLosses)"
    }
    
    func updateRevealLabel() {
        var letters = [String]()
        // loop through all characters in a stirng
        // way1. map with append(contentsOf:)
        letters.append(contentsOf: currentGame.formattedWord.map { String($0)} )
        // way2. loop
//        for letter in currentGame.formattedWord {
//            letters.append(String(letter))
//        }
        let wordWithSpacing = letters.joined(separator: " ")
        
        correctWordLabel.text = wordWithSpacing
    }
    
    func updateGameState(isInputTextField: Bool = false) {
        if !checkResult(isInputTextField: isInputTextField) {
            updateUI()
        }
    }
    
    func checkResult(isInputTextField: Bool) -> Bool {
        if isInputTextField {
//            print("correct word: \(currentGame.word), guess: \(String(describing: guessTextField.text))")
            if currentGame.word == guessTextField.text {
                displayWin()
                return true
            } else {
                displayLose(guessWord: guessTextField.text)
                return true
            }
        } else {
            if currentGame.word == currentGame.formattedWord {
                displayWin()
                return true
            } else if currentGame.incorrectMovesRemaining == 0 {
                displayLose()
                return true
            }
        }
        return false
    }

    // handler: { action in <call func>}: pause the code till get back from alert
    func displayWin() {
        let alert = UIAlertController(title: "Win!", message: "You've got the correct word: \(currentGame.word)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.afterPopUp(isWin: true)
        }))
        self.present(alert, animated: true)
    }
    
    func displayLose(guessWord: String? = nil) {
        var msg = "Correct Word was: \(currentGame.word)"
        if let guess = guessWord {
            msg += "\n" + "Your guess was: " + guess
        }
        
        let alert = UIAlertController(title: "Lose!", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.afterPopUp(isWin: false)
        }))
        self.present(alert, animated: true)
    }

    // run after alert is closed
    func afterPopUp(isWin: Bool) {
        if isWin {
            self.totalWins += 1
        } else {
            self.totalLosses += 1
        }
    }
}

extension ViewController : UITextFieldDelegate {
    // when user select a textfield, this method will be called
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // set the activeTextField to the selected textfield
        self.activeTextField = textField
        textField.text = nil
        textField.textColor = .black
    }

    // when user click 'done' or dismiss the keyboard
    func textFieldDidEndEditing(_ textField: UITextField) {
//        resetTextField()
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == guessTextField {
            textField.resignFirstResponder()
            updateGameState(isInputTextField: true)
            return false
        }
        return true
    }
}
