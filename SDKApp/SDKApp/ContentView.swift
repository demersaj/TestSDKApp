//  SDKApp
//  Created by Andrew Demers on 12/09/25 using Swift 6.0.
//  Copyright © 2025 webAI, Inc. All rights reserved.

import SwiftUI
import webAISDK

struct ContentView: View {
	
	@State var viewModel = ContentViewModel()

    var body: some View {
		VStack(spacing: 25) {

			Text("WebframeCPP version: \(viewModel.inferenceVersion)")
			
			Button {
				Task { await viewModel.downloadModel(modelURLString) }
			} label: {
				Text("Prepare Model")
			}

			if let modelName = viewModel.modelName {
				Text("Model: \(modelName)")
			}

			List(viewModel.downloadStatus, id: \.self) { status in
				HStack {
					Circle()
						.fill(colorForStatus(status))
						.frame(width: 12, height: 12)
					Text("\(status.description)")
				}
			}
			
			Spacer()
			
			HStack {
				TextField("Enter a prompt", text: $viewModel.promptString)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.padding()
				
				Button {
					Task { await viewModel.generateText() }
				} label: {
					Text("Send")
				}
				.disabled(viewModel.promptString.isEmpty)
			}
			.padding()
			
			if viewModel.isGenerating {
				ProgressView()
			}
			
			if let responseString = viewModel.responseString {
				ScrollView {
					Text(responseString)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding()
				}
				.frame(maxHeight: 300)
				.background(Color.gray.opacity(0.1))
				.cornerRadius(8)
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(Color.gray.opacity(0.3), lineWidth: 1)
				)
				.padding(.horizontal)
			}
						
			if let downloadProgress = viewModel.downloadProgress {
				ProgressView(downloadProgress)
					.padding()
					.transition(.move(edge: .bottom))
			}
			
			if let errorString = viewModel.errorString {
				Text(errorString)
					.foregroundColor(.red)
			}
			
        }
        .padding()
		.task {
			viewModel.initSDK()
		}
    }
	
	let modelURLString = "https://huggingface.co/TinyLlama/TinyLlama-1.1B-Chat-v1.0"
    
	/// Returns a color indicator based on the model readiness status
	private func colorForStatus(_ status: Model.ReadinessStatus) -> Color {
		switch status {
		case .notOnDevice:
			return .gray
		case .metadataSaved:
			return .blue
		case .downloading:
			return .orange
		case .downloadComplete:
			return .green
		case .initializing:
			return .yellow
		case .initializationFailed:
			return .red
		case .ready:
			return .green
		case .processingPrompt:
			return .purple
		}
	}
}

#Preview {
    ContentView()
}


