//
//  ViewController.swift
//  BetterSleep
//
//  Created by Ieva Burk on 7/21/19.
//  Copyright © 2019 Ieva Burk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var wakeUpTime: UIDatePicker!
    
    var sleepAmountTime: UIStepper!
    var sleepAmountLabel: UILabel!
    
    var coffeeAmountStepper: UIStepper!
    var coffeeAmountLabel: UILabel!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .black
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
        
        let wakeUpTitle = UILabel()
        wakeUpTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        wakeUpTitle.numberOfLines = 0
        wakeUpTitle.text = "When would you like to wake up?"
        wakeUpTitle.textColor = .white
        mainStackView.addArrangedSubview(wakeUpTitle)
        
        wakeUpTime = UIDatePicker()
        wakeUpTime.datePickerMode = .time
        wakeUpTime.minuteInterval = 5
        wakeUpTime.setValue(UIColor.white, forKey: "textColor")
        mainStackView.addArrangedSubview(wakeUpTime)
        
        var components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        components.hour = 8
        components.minute = 0
        wakeUpTime.date = Calendar.current.date(from: components) ?? Date()
        
        let sleepTitle = UILabel()
        sleepTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        sleepTitle.numberOfLines = 0
        sleepTitle.text = "How much sleep do you need?"
        sleepTitle.textColor = .white
        mainStackView.addArrangedSubview(sleepTitle)
        
        sleepAmountTime = UIStepper()
        sleepAmountTime.addTarget(self, action: #selector(sleepAmountChanged), for: .valueChanged)
        sleepAmountTime.stepValue = 0.5
        sleepAmountTime.value = 8 // default value shown
        sleepAmountTime.minimumValue = 4
        sleepAmountTime.maximumValue = 16

        sleepAmountLabel = UILabel()
        sleepAmountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        sleepAmountLabel.textColor = .white

        let sleepStackView = UIStackView()
        sleepStackView.spacing = 20
        sleepStackView.addArrangedSubview(sleepAmountTime)
        sleepStackView.addArrangedSubview(sleepAmountLabel)
        mainStackView.addArrangedSubview(sleepStackView)
        
        let coffeeTitle = UILabel()
        coffeeTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        coffeeTitle.numberOfLines = 0
        coffeeTitle.text = "How many cups of coffee did you drink today?"
        coffeeTitle.textColor = .white
        mainStackView.addArrangedSubview(coffeeTitle)
        
        coffeeAmountStepper = UIStepper()
        coffeeAmountStepper.addTarget(self, action: #selector(coffeeAmountChanged), for: .valueChanged)
        coffeeAmountStepper.minimumValue = 0
        coffeeAmountStepper.maximumValue = 20
        
        coffeeAmountLabel = UILabel()
        coffeeAmountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        coffeeAmountLabel.textColor = .white

        
        let coffeeStackView = UIStackView()
        coffeeStackView.spacing = 20
        coffeeStackView.addArrangedSubview(coffeeAmountStepper)
        coffeeStackView.addArrangedSubview(coffeeAmountLabel)
        mainStackView.addArrangedSubview(coffeeStackView)
        
        mainStackView.setCustomSpacing(10, after: sleepTitle)
        mainStackView.setCustomSpacing(20, after: sleepStackView)
        mainStackView.setCustomSpacing(10, after: coffeeTitle)
        mainStackView.setCustomSpacing(20, after: coffeeStackView)
        
        /*
         The following is for adding the default amounts as placeholders until the user selects their own values
         */
        sleepAmountChanged()
        coffeeAmountChanged()

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "BetterSleep"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Calculate", style: .plain, target: self, action: #selector(calculateBedTime))

    }

    @objc func sleepAmountChanged() {
        sleepAmountLabel.text = String(format: "%g hours", sleepAmountTime.value)
    }
    
    @objc func coffeeAmountChanged() {
        if coffeeAmountStepper.value == 1 {
            // take care of the singular case
            coffeeAmountLabel.text = "1 cup"
        } else {
            /*
             Cast an integer value for the text so that it doesn't say something like "3.0 cups"
             */
            coffeeAmountLabel.text = "\(Int(coffeeAmountStepper.value)) cups"
        }
    }
    
    @objc func calculateBedTime() {
        let model = SleepCalculator() // using the class that Swift created in file.mlmodel
        let title: String
        let message: String
        
        do {
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime.date)
            // convert the hours and minutes to seconds
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            // then use the model to give us the predicted wake values
            let prediction = try model.prediction(coffee: coffeeAmountStepper.value, estimatedSleep: sleepAmountTime.value, wake: Double(hour + minute))
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let wakeDate = wakeUpTime.date - prediction.actualSleep
            message = formatter.string(from: wakeDate)
            
            title = "Your ideal bedtime is: "
        } catch {
            title = "Error"
            message = "Sorry, we ran into an issue while trying to calculate your optimal bedtime."
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    

}

