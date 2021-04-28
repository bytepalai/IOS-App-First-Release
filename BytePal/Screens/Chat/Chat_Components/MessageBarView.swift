//
//  MessageBarView.swift
//  BytePal
//
//  Created by Scott Hom on 11/24/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import SwiftUI
import CoreData
import Speech
import AVKit

enum ActiveSheet: Identifiable {
    case gallary, camera
    var id: Int {
        hashValue
    }
}

struct MessageBarView: View {
    
    // Arguments
    var width: CGFloat?
    var height: CGFloat?
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    // Core Data
    var container: NSPersistentContainer!
    @FetchRequest(entity: Message.entity(), sortDescriptors: []) var MessagesCoreDataRead: FetchedResults<Message>
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var UserInformationCoreDataRead: FetchedResults<User>
    @Environment(\.managedObjectContext) var moc
    
    // Environment Object
    @EnvironmentObject var messages: Messages
    @EnvironmentObject var userInformation: UserInformation
    
    // Observable Objects
    //    @ObservedObject var keyboard = KeyboardResponder()
    
    // States
    @State public var textFieldString: String = ""
    @State public var messageString: String = ""
    @State private var showingSheet = false
    @State private var showingCamera = false
    @State var activeSheet: ActiveSheet = .gallary
    @State private var chatBotCount = 0
    @State var isAudioRecording = false
    @Binding var isWaiting: Bool
    
    var body: some View {
        
        DividerCustom(color: Color(UIColor.systemGray3), length: Float(width ?? CGFloat(100)), width: 1)
            .shadow(color: Color(UIColor.systemGray4), radius: 1, x: 0, y: -1)
        
        // Message bar
        HStack {
            
            // Send message button
            Button(action: {
                DispatchQueue.main.async {
                    self.showingSheet = true
                }
            }){
                Image("cameraBackground")
                    .font(.system(size: 24))
                    .foregroundColor(convertHextoRGB(hexColor: greenColor))
                    .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 6)
                    .scaledToFit()
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
            .actionSheet(isPresented: $showingSheet) {
                ActionSheet(title: Text("Select Option"), message: nil, buttons: [.default(Text("Camera"), action: {
                    DispatchQueue.main.async {
                        self.activeSheet = .camera
                        self.showingCamera = true
                    }
                }),
                .default(Text("Gallery"), action: {
                    DispatchQueue.main.async {
                        self.activeSheet = .gallary
                        self.showingCamera = true
                    }
                }),
                .cancel(Text("Cancel"))])
            }
            .sheet(isPresented: $showingCamera, content: {
                if self.activeSheet == .gallary {
                    ImagePicker(sourceType: .photoLibrary) { (img) in
                        self.sendImage(image: img)
                    }
                } else {
                    ImagePicker(sourceType: .camera) { (img) in
                        self.sendImage(image: img)
                    }
                }
            })
            
            // Send message button
            Button(action: {
                self.requestTranscribePermissions()
            }){
                Image(self.isAudioRecording ? "pause" : "mic")
                    .font(.system(size: 24))
                    .foregroundColor(convertHextoRGB(hexColor: greenColor))
                    .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 6)
                    .scaledToFit()
            }
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0))
            
            // Text field
            ZStack{
                RoundedRectangle(cornerRadius: 25, style: .continuous)                           // Text box border
                    .fill(Color(UIColor.white))
                    .frame(width: (width ?? CGFloat(66)) - 160 , height: 40)
                    .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0))
                    .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 3)
                // Text box entry area
                // Single Line Text Field
                TextField("Enter text here", text: self.$textFieldString)
                    .padding(EdgeInsets(top: 4, leading: 20, bottom: 8, trailing: 48))
            }
            .padding([.top], 8)
            
            // Send button
            Button(action: {
                if !(self.textFieldString.trimmingCharacters(in: .whitespaces).isEmpty) {
                    // Send message
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.sendUserMessage(self.textFieldString)
                        self.sendChatbotMessage(self.textFieldString)
                        self.textFieldString = ""
                        if isAudioRecording {
                            isAudioRecording = false
                            self.audioEngine.stop()
                            self.recognitionRequest?.endAudio()
                        }
                    }
                }
            }){
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 24))
                    .foregroundColor(convertHextoRGB(hexColor: greenColor))
                    .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 6)
            }
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 16))
            
        }
        .frame(
            width: width,
            height: (height ?? CGFloat(200))*0.02,
            alignment: .top
        )
        .padding([.bottom], (height ?? CGFloat(200))*0.06)
        
    }
    
    func sendUserMessage(_ text: String) {
        // Save user information and message to cache
        let messageListCoreData = Message(context: self.moc)
        messageListCoreData.id = UUID()
        messageListCoreData.isCurrentUser = true
        messageListCoreData.content = text
        try? self.moc.save()
        if text != "" {
            // Update message history with user message
            DispatchQueue.main.async {
                // Store message in RAM
                self.messages.list.insert(["id": UUID(), "content": text, "isCurrentUser": true], at: self.messages.list.startIndex)
                // Store in temporary variable
                self.messageString = text
            }
        } else {
            print("Error: User message is blank")
        }
    }
    
    func sendChatbotMessage(_ text: String){
        let messageListCoreData = Message(context: self.moc)
        var message: String = ""
        print("Sent message: ", text)
        withAnimation {
            self.isWaiting = true
        }
        MakeRequest.sendMessage(message: text, userID: self.userInformation.id){
            response1, response2 in
            
            message = response1
            Sounds.playSounds(soundfile: response2)
//            ZHAudio.sharedInstance.playSound(soundFilePath: response2)
            //Save bot message to cache
            messageListCoreData.id = UUID()
            messageListCoreData.content = message
            messageListCoreData.isCurrentUser = false
            try? self.moc.save()
            self.chatBotCount += 1
            self.sendEmojiMessage(text: text)
            DispatchQueue.main.async {
                withAnimation {
                    self.isWaiting = false
                }
                self.messages.list.insert(["id": UUID(), "content": message, "isCurrentUser": false], at: self.messages.list.startIndex)
            }
        }
    }
    
    func sendImage(image: UIImage) {
        sendThanksMessage()
        let messageListCoreData = Message(context: self.moc)
        
        let data = image.jpegData(compressionQuality: 0.1)
        withAnimation {
            self.isWaiting = true
        }
        APIViewModel.shared.imageInteract(imageData: data) {(message) in
            //Save bot message to cache
            messageListCoreData.id = UUID()
            messageListCoreData.content = message
            messageListCoreData.isCurrentUser = false
            try? self.moc.save()
            self.chatBotCount += 1
            self.sendEmojiMessage(text: message)
//            self.sendResponseToInteract(message)
            DispatchQueue.main.async {
                withAnimation {
                    self.isWaiting = false
                }
                self.messages.list.insert(["id": UUID(), "content": message, "isCurrentUser": false], at: self.messages.list.startIndex)
            }
        } onFailure: { (error) in
            withAnimation {
                self.isWaiting = false
            }
            print(error)
        }
    }
    
    func sendEmojiMessage(text: String) {
        if self.chatBotCount >= 3 {
            let messageListCoreData = Message(context: self.moc)
            APIViewModel.shared.sendEmoji(text: text) {(message) in
                //Save bot message to cache
                messageListCoreData.id = UUID()
                messageListCoreData.content = message
                messageListCoreData.isCurrentUser = false
                try? self.moc.save()
                self.chatBotCount = 0
                DispatchQueue.main.async {
                    self.messages.list.insert(["id": UUID(), "content": message, "isCurrentUser": false], at: self.messages.list.startIndex)
                }
            } onFailure: { (error) in
                print(error)
            }
        }
    }
    
    func sendThanksMessage() {
        let message = "Thanks for sharing the image"
        let messageListCoreData = Message(context: self.moc)
        messageListCoreData.id = UUID()
        messageListCoreData.content = message
        messageListCoreData.isCurrentUser = false
        try? self.moc.save()
//        self.sendResponseToInteract(message)
        DispatchQueue.main.async {
            self.messages.list.insert(["id": UUID(), "content": message, "isCurrentUser": false], at: self.messages.list.startIndex)
        }
        sendResponseToHistory()
    }
    
    func sendResponseToHistory() {
        APIViewModel.shared.historyMessage {
            print("Uploaded to history")
        } onFailure: { (error) in
            print(error)
        }
        
    }
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                    self.checkRecording()
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }
    }
    
    func checkRecording() {
        isAudioRecording.toggle()
        if audioEngine.isRunning {
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
//            audioEngine.inputNode.removeTap(onBus: 0)
//            self.recognitionRequest = nil
//            do {
//
//                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//            } catch let error {
//                print(error.localizedDescription)
//            }
        } else {
            self.startRecording()
        }
    }
    
    func startRecording() {
        // Clear all previous session data and cancel task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        // Create instance of audio session to record voice
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .mixWithOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch (let e) {
            print("audioSession properties weren't set because of an error.", e.localizedDescription)
        }
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            if result != nil {
                if self.isAudioRecording {
                    self.textFieldString = result?.bestTranscription.formattedString ?? ""
                }
                isFinal = (result?.isFinal)!
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        self.audioEngine.prepare()
        do {
            try self.audioEngine.start()
        } catch (let e){
            print("audioEngine couldn't start because of an error.", e.localizedDescription)
        }
    }
    
    
}


struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    
    final class Coordinator: NSObject,
                             UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate {
        
        @Binding
        private var presentationMode: PresentationMode
        private let sourceType: UIImagePickerController.SourceType
        private let onImagePicked: (UIImage) -> Void
        
        init(presentationMode: Binding<PresentationMode>,
             sourceType: UIImagePickerController.SourceType,
             onImagePicked: @escaping (UIImage) -> Void) {
            _presentationMode = presentationMode
            self.sourceType = sourceType
            self.onImagePicked = onImagePicked
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            onImagePicked(uiImage)
            presentationMode.dismiss()
            
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode,
                           sourceType: sourceType,
                           onImagePicked: onImagePicked)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
}
