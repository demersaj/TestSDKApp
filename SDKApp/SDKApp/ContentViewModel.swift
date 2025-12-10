//  SDKApp
//  Created by Andrew Demers on 12/09/25 using Swift 6.0.
//  Copyright © 2025 webAI, Inc. All rights reserved.

import Foundation
import webAISDK

@Observable
final class ContentViewModel: Sendable {
	
	var downloadProgress: Progress?
	var downloadStatus = [Model.ReadinessStatus]()
	var model: Model?
	var modelName: String?
	var errorString: String?
	var promptString: String = ""
	var responseString: String?
	var isGenerating: Bool = false
	var inferenceVersion: String { LocalInferenceService.version }
	var key: String? {
		Bundle.main.infoDictionary?["HF_API_KEY"] as? String
	}
    
	@MainActor
	func initSDK() {
		webAISDKLogger.setConfigurations(debugConfiguration: LoggerConfiguration(logTypes: [.all]))

		let config = WebAISDKConfiguration(huggingFaceAPIKey: key)
		WebAISDK.configuration = config
	}
		
	func downloadModel(_ modelURLString: String) async {
		
		downloadStatus.removeAll()
		downloadProgress = nil
		modelName = nil
		
		guard let modelURL = URL(string: modelURLString) else { return }

		model = try? await ModelManager.shared.prepareModelFromUrl(modelURL, deleteFirst: false, statusChangeHandler: handleModelStatusChange)

		modelName = modelURL.lastPathComponent
	}

	@Sendable
	func handleModelStatusChange(_ readinessStatus: Model.ReadinessStatus) {
		//				print("\(readinessStatus)")
		if case let .downloading(downloadStatus) = readinessStatus, case let .downloading(progress) = downloadStatus {
			self.downloadProgress = progress
		} else {
			downloadStatus.append(readinessStatus)
		}
		
		if readinessStatus == .downloadComplete {
			downloadProgress = nil
		}
		
		if readinessStatus == .ready {
			promptString = "Your prompt here"
		}
		
	}
	
	func generateText() async {
		
		guard !promptString.isEmpty else { return }

		isGenerating = true

		let generateResult = LocalInferenceService.generateResponse(promptString: promptString)

		if let error = generateResult.0.errorMessage {
			errorString = "Error: \(error)"
			return
		}
		
		responseString = generateResult.1
		isGenerating = false
	}

}

