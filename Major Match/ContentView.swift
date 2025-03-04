//
//  ContentView.swift
//  ApiTest
//
//  Created by Joseph Brinker on 10/12/24.
//
import SwiftUI

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var responseText: String = "Response will appear here."
    @State private var selectedState = "Michigan"
    @State private var selectedProgram = "Bachelor's"
    @State private var isLoading = false
    @State private var showingSheet = false
    
    // Use personal API Key from OpenAI API here in api_key.
    private let api_key = ""
    
    let states = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut",
        "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
        "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan",
        "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
        "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
        "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
        "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia",
        "Wisconsin", "Wyoming"
    ]
    
    let programs = ["Assoicate's","Bachelor's", "Master's"]
    
    var body: some View {
        ScrollView{
            
            VStack(alignment: .center) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                VStack(alignment: .center){
                    Text("1. Type in a major")
                    Text("2. Select your state")
                    Text("3. Press OK")
                }
                .padding()
                .foregroundStyle(.gray)
                VStack(alignment: .center){
                    Text("Enter your desired major:")
                        .foregroundStyle(.teal)
                    TextField("",text: $userInput)
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.black).opacity(0.1))  // Set custom background
                    
                        .foregroundColor(Color.black)  // Set fixed text color
                        .accentColor(.blue)
                    Menu {
                        ForEach(states, id: \.self) { state in
                            Button(action: {
                                selectedState = state
                            }) {
                                Text(state)
                            }
                        }
                    } label: {
                        HStack {
                            Text("State: ")
                                .foregroundStyle(.gray)
                            Text(selectedState)
                                .padding(3)
                                .background(.teal)
                                .cornerRadius(8)
                                .foregroundStyle(.beige)
                            Image(systemName: "chevron.down") // Dropdown arrow
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                        }
                        .font(.system(size: 18))
                        .foregroundColor(.ourTeal)
                    }
                    HStack{
                        Menu{
                            ForEach(programs, id: \.self) {
                                program in
                                Button(action: {
                                    selectedProgram = program
                                }) {
                                    Text(program)
                                }
                            }
                        } label: {
                            HStack {
                                Text("Program: ")
                                    .foregroundStyle(.gray)
                                Text(selectedProgram)
                                    .padding(3)
                                    .background(.teal)
                                    .cornerRadius(8)
                                    .foregroundStyle(.beige)
                                Image(systemName: "chevron.down") // Dropdown arrow
                                    .font(.system(size: 14))
                                    .foregroundStyle(.gray)
                            }
                            .font(.system(size: 18))
                            .foregroundColor(.ourTeal)
                        }
                    }
                }
                Button(action: {
                    isLoading.toggle()
                    sendMessageToGPT(input: "List the top 5 colleges in \(selectedState) for \(userInput). Also include their cost for their \(selectedProgram) program. After you list those, list another 5 colleges that are also in \(selectedState) that are the most affordable. Rank the affordable colleges by cost and dont output any un needed text. Only include annual estimated in state tuition for both lists. Make sure the tuition that is being listed is based on the annual cost. If you can only find the semester tuition, just multiply it by 2 and output that as the a annual tuition. At the end add text that reads, Note: The estimated tuition costs may be subject to change. Before enrollment, please check the institutions official website for the most up to date information. If the input does not correlate remotely to any major please say: Major not found please try again.") { response in
                        responseText = response
                        isLoading.toggle()
                        showingSheet.toggle()
                    }
                }) {
                    Text("Ok  ")
                        .padding(5)
                        .background(.black.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(.ourTeal)
                        .padding()
                }
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                        .padding()
                }
                Text(responseText)
                    .foregroundStyle(.ourTeal)
                    .padding()
            }
        }
        .ignoresSafeArea()
        .padding()
        .background(.beige)
    }

    func sendMessageToGPT(input: String, completion: @escaping (String) -> Void) {
        // Set up the OpenAI API URL
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion("Invalid URL")
            return
        }

        // Set up the HTTP request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(api_key)", forHTTPHeaderField: "Authorization")

        // Create the request body
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": input]
            ],
            "max_tokens": 500
        ]

        // Serialize the body as JSON
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // Perform the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("Network error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Parse the response
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                completion(content)
            } else {
                completion("Failed to decode response")
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
