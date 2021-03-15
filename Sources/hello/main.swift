import SwiftyGPIO
import Foundation
import Glibc

// setup exit sig
var signalReceived: sig_atomic_t = 0

signal(SIGINT) { signal in
    signalReceived = signal
}

signal(SIGINT) { signal in
    signalReceived = signal
}

// welcome 
print("--------------------------")
print("--+++++-++++---+++-+++++--")
print("----+---+++----+-----+----")
print("----+---++++-+++-----+----")
print("--------------------------")
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
guard let targetGP = gpios[.P3] else {
    fatalError("Could not init target gpio")
}
targetGP.direction = .OUT
//debounce time: garantees that there wil be only 1 transition notified by closures (onraising, onfalling, onchange)
let debounceTime = 0.5
targetGP.bounceTime = debounceTime

/*
targetGP.onRaising{
    gpio in
    print("ONN")
}

targetGP.onFalling{
    gpio in 
    print("OFF")
}

targetGP.onChange{
    gpio in 
    print("value changed, current val: " + String(gpio.value))
}
*/
// loop
targetGP.value = 0
while signalReceived == 0 {
    print("set targetGP to 1")
    targetGP.value = 1
    print("current val: " + String(targetGP.value))
    usleep(5000000)
    print("set targetGP to 0")
    targetGP.value = 0
    print("current val: " + String(targetGP.value))
    usleep(5000000)
}

// cleanup
targetGP.direction = .IN
print("\ncompleted cleanup of GPIO resources.")
exit(signalReceived)
/*
var n = 1
while true {
    print("loop \(n)")
    targetGP.value = 1//(targetGP.value == 0) ? 1 : 0
    print("current val: " + String(targetGP.value))
    sleep(5)
    n += 1
}*/