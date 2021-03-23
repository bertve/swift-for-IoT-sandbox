import SwiftyGPIO
import Foundation 

class DigitDisplay {

    let gpios: [GPIO]
    var currentlyDisplayedNumber = 0 {  
        didSet {
            self.display(currentlyDisplayedNumber)
        }
    }

    private var isDisplaying = false
    private let digitSequences : [Int: [Int]] = 
    //               6x  8x9x   12x --> segment gpios (high = off)
    [   
        0: [1,1,0,1,0,1,1,1,1,1,1,1],
        1: [0,0,0,1,0,1,1,1,1,0,0,1],
        2: [1,1,0,0,1,1,1,1,1,0,1,1],
        3: [1,1,0,1,1,1,1,1,1,0,0,1],
        4: [0,0,0,1,1,1,1,1,1,1,0,1],
        5: [0,1,0,1,1,1,0,1,1,1,1,1],
        6: [1,1,0,1,1,1,0,1,1,1,1,1],
        7: [0,0,0,1,0,1,1,1,1,0,1,1],
        8: [1,1,0,1,1,1,1,1,1,1,1,1],
        9: [0,1,1,1,1,1,1,1,1,1,1,1] 
    ]
 
    private var displaySequences: [[Int]] = []

    init(gpios: [GPIO]) {
        for gpio in gpios {
            gpio.direction = .OUT
        }
        self.gpios = gpios
    }

    func reset(){
        currentlyDisplayedNumber = 0
    }

    func increment(){
        currentlyDisplayedNumber += 1
    }

    func decrement(){
        currentlyDisplayedNumber -= 1
    }

    func stopDisplaying() {
        self.isDisplaying = false
    }

    private func display(_ number: Int){
        guard number >= 0 && number <= 9999 else {
            reset()
            return 
        }

        print("display: \(number)")
        
        self.isDisplaying = true
        self.determineSequence(number)

        while isDisplaying {
            for seq in displaySequences {
                var seqIndex = 0
                for gpio in gpios {
                    gpio.value = seq[seqIndex]
                    seqIndex += 1
                }
                usleep(2000)
            }
        }
        print("display stopped")
    }

    private func determineSequence(_ num: Int) {
        self.displaySequences = []  
        var number = num
        var digit : Int
        var rest : Int
        let segmentgpio = [5,7,8,11]
        for index in stride(from: 3, to: 0, by: -1){
            digit = number / (10 * index)
            rest = digit * (10 * index)
            if let sequence = self.digitSequences[digit] { 
                var varSeq = sequence
                varSeq[segmentgpio[index]] = 0
                displaySequences.append(varSeq)
            }
            number -= rest
        }

        if let lastSequence = self.digitSequences[number] {
            var varSeq = lastSequence
            varSeq[segmentgpio[0]] = 0
            displaySequences.append(varSeq)
        }

        print("display seq: \(displaySequences)")
    }

}