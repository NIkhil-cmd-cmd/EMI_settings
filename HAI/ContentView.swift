//
//  ContentView.swift
//  Created by Nikhil Krishnaswamy on 4/14/23.

import SwiftUI
import AudioToolbox

struct CustomButtonStyle: ButtonStyle {
    @Binding var selectedColor: Color
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.clear : Color.blue)
    }
}

struct ContentView: View {
    
    @State private var messageText = ""
    @State private var messages: [String] = ["Welcome! My name is Emi!"]
    @ObservedObject private var viewModel = ViewModel()
    @State private var showSettings = false
    @State private var selection = 1
    @State private var messagesAppear = false
    
    enum FontOption: String, CaseIterable {
        case sfProDisplay = "SFProDisplay-Regular"
        case futura = "Futura-Medium"
        case timesNewRoman = "TimesNewRomanPSMT"
        case helvetica = "Helvetica"
        case avenir = "Avenir-Medium"
        case georgia = "Georgia"
        case hoefler = "HoeflerText-Regular"
        case verdana = "Verdana"
        
        
        var displayName: String {
            switch self {
            case .sfProDisplay:
                return "SF Pro Display"
            case .futura:
                return "Futura"
            case .timesNewRoman:
                return "Times New Roman"
            case .helvetica:
                return "Helvetica"
            case .avenir:
                return "Avenir"
            case .georgia:
                return "Georgia"
            
            case .hoefler:
                return "Hoefler Text"
            case .verdana:
                return "Verdana"
            
            }
        }
    }


    
    

    @State private var selectedFont = FontOption.sfProDisplay
    @State private var selectedColor = Color.blue

    var body: some View {
        TabView(selection: $selection) {
            VStack {
                HStack {
                    Text("EMI")
                        .bold()
                        .padding(.horizontal, 15)
                        .padding(.top, 30)
                        .font(.custom(selectedFont.rawValue, size: 50))
                    Spacer()
                }
                
                Form {
                    Picker(selection: $selectedFont, label: Text("Font").bold()) {
                        ForEach(FontOption.allCases, id: \.self) { font in
                            Text(font.displayName)
                                .tag(font)
                                .font(.custom(font.rawValue, size: 30))
                            
                        }
                    }
                    
                    
                ColorPicker("Color", selection: $selectedColor)
                        .bold()
                }
            }.tag(2)
            
            VStack {
                ZStack {
                    HStack{
                        Image("Title")
                    }
                }
                

                ScrollView {
                    ForEach(messages, id: \.self) { message in
                        // If the message contains [USER], that means it's us
                        if message.contains("[USER]") {
                            let newMessage = message.replacingOccurrences(of: "[USER]", with: "")
                            // User message styles
                            HStack {
                                Spacer()
                                Text(newMessage)
                                    .padding()
                                    .background(selectedColor.opacity(0.5))
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 10)
                                    .font(.custom(selectedFont.rawValue, size: 18))
                                    .opacity(messagesAppear ? 1 : 0)
                                    .scaleEffect(messagesAppear ? 1 : 0.5)
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            self.messagesAppear = true
                                        }
                                    }
                            }
                        } else {
                            // Bot message styles
                            HStack {
                                Text(message)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 10)
                                    .font(.custom(selectedFont.rawValue, size: 18))
                                    .opacity(messagesAppear ? 1 : 0)
                                    .scaleEffect(messagesAppear ? 1 : 0.5)
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            self.messagesAppear = true
                                        }
                                    }
                                Spacer()
                            }
                        }
                    }
                    .rotationEffect(.degrees(180))
                }
                .rotationEffect(.degrees(180))


                // Contains the Message bar
                HStack {
                    
                    TextField("Type here...", text: $messageText)
                       
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(30)
                        .font(.custom(selectedFont.rawValue, size: 17))
                        .onSubmit {
                            sendMessage(message: messageText)
                            AudioServicesPlaySystemSound(1004)
                        }
                    Button {
                        sendMessage(message: messageText)
                        AudioServicesPlaySystemSound(1004)
                    } label: {
                        Image(systemName: "paperplane.fill").buttonStyle(CustomButtonStyle(selectedColor: $selectedColor)).foregroundColor(selectedColor)
                    }
                    .font(.system(size: 20))
                    .padding(.horizontal, 10)
                }
                .padding()
            }
            .tag(1)
            .onAppear {
                viewModel.setup()
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    func sendMessage(message: String) {
        withAnimation {
            messages.append("[USER]" + message)
            self.messageText = ""
            
            withAnimation {
                viewModel.getBotResponse(text: message) { response in
                    DispatchQueue.main.async {
                        messages.append(response)
                        AudioServicesPlaySystemSound(1003)
                    }
                }
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
