import SwiftyGPIO
import Foundation
import Glibc
import Dispatch

// setup exit sig
var signalReceived: sig_atomic_t = 0

signal(SIGINT) { signal in
    signalReceived = signal
}

// welcome 
print("---------------------------")
print("--+++++-++++---++++-+++++--")
print("----+---+++----++-----+----")
print("----+---++++-++++-----+----")
print("---------------------------")
print("")
print("Press CTRL_C to exit.")

// example for running "swift run <<program_name>> <<argument>>"
if CommandLine.arguments.count != 2 {
    print("starting swift for iot test without args")
} else {
    print("starting swift for iot test with args")
    let name = CommandLine.arguments[1]
    sayHello(name: name) 
}

// setup gpio
let gpios = SwiftyGPIO.GPIOs(for: .RaspberryPi4)
// iterate gpios
/*gpios.compactMap({ $0 })
    .forEach { print($0) }*/

// LED
guard let LED = gpios[.P21] else {
    fatalError("Could not init target gpio")
}
LED.direction = .OUT

// Button
guard let btn = gpios[.P20] else {
    fatalError("Could not init target gpio")
}
btn.direction = .IN
//debounce time: garantees that there wil be only 1 transition notified by closures (onraising, onfalling, onchange)
let debounceTime = 0.5
btn.bounceTime = debounceTime
var count = 0

// digit display
var digitDisplayGPIO = [GPIO]()
guard let gpioOne = gpios[.P14] else {
    fatalError("Could not init target 14 gpio")
}
digitDisplayGPIO.append(gpioOne)
guard let gpioTwo = gpios[.P2] else {
    fatalError("Could not init target 2 gpio")
}
digitDisplayGPIO.append(gpioTwo)
guard let gpioThree = gpios[.P3] else {
    fatalError("Could not init target 3 gpio")
}
digitDisplayGPIO.append(gpioThree)
guard let gpioFour = gpios[.P4] else {
    fatalError("Could not init target 4 gpio")
}
digitDisplayGPIO.append(gpioFour)
guard let gpioFive = gpios[.P5] else {
    fatalError("Could not init target 5 gpio")
}
digitDisplayGPIO.append(gpioFive)
guard let gpioSix = gpios[.P6] else {
    fatalError("Could not init target 6 gpio")
}
digitDisplayGPIO.append(gpioSix)
guard let gpioSeven = gpios[.P7] else {
    fatalError("Could not init target 7 gpio")
}
digitDisplayGPIO.append(gpioSeven)
guard let gpioEight = gpios[.P8] else {
    fatalError("Could not init target 8 gpio")
}
digitDisplayGPIO.append(gpioEight)
guard let gpioNine = gpios[.P9] else {
    fatalError("Could not init target 9 gpio")
}
digitDisplayGPIO.append(gpioNine)
guard let gpioTen = gpios[.P15] else {
    fatalError("Could not init target 15 gpio")
}
digitDisplayGPIO.append(gpioTen)
guard let gpioEleven = gpios[.P18] else {
    fatalError("Could not init target 18 gpio")
}
digitDisplayGPIO.append(gpioEleven)
guard let gpioTwelve = gpios[.P12] else {
    fatalError("Could not init target 12 gpio")
}
digitDisplayGPIO.append(gpioTwelve)

let digitDisplay = DigitDisplay(gpios: digitDisplayGPIO )

/*
btn.onFalling{
    gpio in 
    print("btn released")
}
btn.onChange{
    gpio in 
    print("btn value changed, current val: " + String(gpio.value))
}*/

// display
DispatchQueue.main.async {
    btn.onRaising{
        gpio in
        print("btn pressed")
        digitDisplay.increment()
    }    
}

// main loop
LED.value = 0
while signalReceived == 0 {

    //print("set LED to 1")
    LED.value = 1
    //print("LED current val: " + String(LED.value))
    sleep(1)
    //print("set LED to 0")
    LED.value = 0
    //print("LED current val: " + String(LED.value))
    sleep(1)
}

// cleanup
LED.direction = .IN
btn.clearListeners()
digitDisplay.stopDisplaying()
print("\ncompleted cleanup of GPIO resources.")
exit(signalReceived)
