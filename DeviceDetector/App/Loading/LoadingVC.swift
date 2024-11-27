//
//  LoadingVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/20/24.
//
import UIKit
import AVKit

class LoadingVC: BaseVC {
    
    // MARK: - UI Elements
    private let videoPlayerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.alpha = 0 // Initially hidden
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var blurView: UIVisualEffectView?
    
    private let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0 // Initially hidden
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        playVideo()
        showDismissButtonAfterDelay()
        addBlurLayerWithButtonAfterDelay()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    // MARK: - Show Dismiss Button After Delay
    private func showDismissButtonAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 0.3) {
                self.dismissButton.alpha = 1
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure playerLayer fits the videoPlayerView
        playerLayer?.frame = videoPlayerView.bounds
        blurView?.frame = videoPlayerView.bounds // Ensure blur view matches videoPlayerView bounds
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Add subviews
        view.addSubview(videoPlayerView)
        view.addSubview(dismissButton)
        
        // Set up button actions
        dismissButton.addTarget(self, action: #selector(dismissLoading), for: .touchUpInside)
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Video Player View
            videoPlayerView.topAnchor.constraint(equalTo: view.topAnchor),
            videoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoPlayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Dismiss Button
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dismissButton.widthAnchor.constraint(equalToConstant: 40),
            dismissButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Looping the Video
    @objc private func videoDidFinishPlaying(_ notification: Notification) {
        player?.seek(to: .zero)
        player?.play()
    }
    
    // MARK: - Video Playback
    private func playVideo() {
        // Ensure the video file exists in the bundle
        guard let videoPath = Bundle.main.path(forResource: "loading-video", ofType: "mp4") else {
            print("Video not found in the app bundle.")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        let videoURL = URL(fileURLWithPath: videoPath)
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        
        // Ensure playerLayer is added to videoPlayerView
        if let playerLayer = playerLayer {
            videoPlayerView.layer.addSublayer(playerLayer)
        }
        
        // Start playing the video
        player?.play()
    }
    
    // MARK: - Add Blur Layer and Button After Delay
    private func addBlurLayerWithButtonAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Add the blur view
            let blurEffect = UIBlurEffect(style: .dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.alpha = 0 // Start with invisible blur
            
            self.videoPlayerView.addSubview(blurView)
            self.blurView = blurView
            
            // Set constraints for the blur view
            NSLayoutConstraint.activate([
                blurView.topAnchor.constraint(equalTo: self.videoPlayerView.topAnchor),
                blurView.leadingAnchor.constraint(equalTo: self.videoPlayerView.leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: self.videoPlayerView.trailingAnchor),
                blurView.bottomAnchor.constraint(equalTo: self.videoPlayerView.bottomAnchor)
            ])
            
            // Add the "Get Started" button to the blur view
            blurView.contentView.addSubview(self.getStartedButton)
            
            // Set constraints for the "Get Started" button
            NSLayoutConstraint.activate([
                self.getStartedButton.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
                self.getStartedButton.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -50),
                self.getStartedButton.widthAnchor.constraint(equalToConstant: 200),
                self.getStartedButton.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            UIView.animate(withDuration: 0.3) {
                if let token = KeychainHelper.retrieveRefreshToken() {
                    SessionData.refreshToken = token
                    self.makeAPICall(path: "/users/cred-check", method: .POST, parameters: ["":""], responseType: UserTokens.self) { result in
                        switch result {
                        case .success(let data):
                            if let user = data.user, let tokens = data.tokens {
                                if !user.phoneVerification {
                                    self.goToVC(vc: EnterPhoneVC())
                                    return
                                } else if (!user.emailVerification) {
                                    self.goToVC(vc: EnterEmailVC())
                                    return
                                } else if (user.firstName.isEmpty || user.lastName.isEmpty) {
                                    self.goToVC(vc: EnterNameVC())
                                    return
                                }
                                self.saveUserSession(user: user, tokens: tokens)
                                self.goToVC(vc: MainTabBarController())
                                return
                            }
                            self.goToVC(vc: LandingVC())
                        case .failure(let error):
                            print("error: \(error)")
                            self.goToVC(vc: LandingVC())
                        }
                    }
                } else {
                    print("No token found.")
                    self.goToVC(vc: LandingVC())
                }
            }
        }
    }
    
    // MARK: - Dismiss Loading
    @objc private func dismissLoading() {
        goToVC(vc: LandingVC(), animated: false)
    }
    
    @objc private func getStartedTapped() {
        print("Get Started button tapped")
    }
}
