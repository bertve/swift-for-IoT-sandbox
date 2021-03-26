import SwiftyGPIO
import Foundation 

class DigitDisplay {

    let gpios: [GPIO]
    var currentlyDisplayedNumber = 0 {  
        didSet {
            print("setted display number: \(currentlyDisplayedNumber)")
            self.determineSequence(currentlyDisplayedNumber)
        }
    }

    private let digitSequences : [Int: [Int]] = 
    //               6x  8x9x   12x --> segment gpios (high = off)
    [   
        0: [1,1,0,1,0,1,1,1,1,1,1,1],
        1: [0,0,0,1,0,1,1,1,1,0,0,1],
        2: [1,1,0,0,1,1,1,1,1,0,1,1],
        3: [0,1,0,1,1,1,1,1,1,0,1,1],
        4: [0,0,0,1,1,1,1,1,1,1,0,1],
        5: [0,1,0,1,1,1,0,1,1,1,1,1],
        6: [1,1,0,1,1,1,0,1,1,1,1,1],
        7: [0,0,0,1,0,1,1,1,1,0,1,1],
        8: [1,1,0,1,1,1,1,1,1,1,1,1],
        9: [0,1,0,1,1,1,1,1,1,1,1,1] 
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

    func display() {
        for seq in displaySequences {
            var seqIndex = 0
            for gpio in gpios {
                gpio.value = seq[seqIndex]
                seqIndex += 1
            }
            usleep(2000)
        }
    
    }

    private func determineSequence(_ num: Int) {
        guard num >= 0 && num <= 9999 else {
            reset()
            return 
        }
        
        self.displaySequences = []
        // 12,9,8,6 (not indexed)
        let segmentgpio = [11,8,7,5]
        var numStr = String(num)
        let numberOfPrefixedZeros = 4 - numStr.length
        for _ in 1...numberOfPrefixedZeros {
            numStr = "0" + numStr
        }
        print("numstr: \(numStr)")
        for (i,numChar) in numStr.enumerated() {
            if let digit = Int(String(numChar)),
                let sequence = self.digitSequences[digit] { 
                var varSeq = sequence
                varSeq[segmentgpio[i]] = 0
                displaySequences.append(varSeq)
            }
        }
        print("display seq: \(displaySequences)")
    }

}