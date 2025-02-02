//
//  AlarmScreen.swift
//  HackRU
//
//  Created by Azhar Pathan on 2/1/25.
//

import SwiftUI
import AVFoundation
import AudioToolbox

struct AlarmScreen: View {
    @State private var isAlarmActive = true
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack {
            Spacer()

            // Alarm Icon
            Image(systemName: "bell.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.black)
                .padding()

            Spacer()

            // End Alarm Button
            Button(action: {
                isAlarmActive = false
                stopAlarm()
            }) {
                Text("End Alarm")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(width: 200, height: 60)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 4))
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.red.ignoresSafeArea())
        .onAppear {
            startAlarm()
        }
        .navigationBarBackButtonHidden(true) // Prevents back navigation
    }

    // Function to play alarm sound and vibrate
    func startAlarm() {
        // Play Alarm Sound
        if let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.play()
            } catch {
                print("Error playing alarm sound: \(error)")
            }
        }

        // Vibrate Continuously
        DispatchQueue.global().async {
            while isAlarmActive {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                usleep(700_000) // Delay for vibration loop
            }
        }
    }

    // Function to stop alarm sound and vibration
    func stopAlarm() {
        audioPlayer?.stop()
        isAlarmActive = false
    }
}

struct AlarmScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlarmScreen()
    }
}
