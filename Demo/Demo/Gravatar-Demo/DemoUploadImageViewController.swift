import UIKit
import Gravatar
import AuthenticationServices

class DemoUploadImageViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    let rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        stack.alignment = .fill
        
        return stack
    }()
    
    let emailField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.textContentType = .emailAddress
        textField.textAlignment = .center
        textField.text = "pinarolguc@gmail.com"
        return textField
    }()
    
    let tokenField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Token"
        textField.autocapitalizationType = .none
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        return textField
    }()
    
    lazy var authButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapAuthButton), for: .touchUpInside)
        btn.setTitle("Authorize", for: .normal)
        return btn
    }()
    
    let selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Select Image", for: .normal)
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    let uploadImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Upload Image", for: .normal)
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    let resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Upload Image"
        view.backgroundColor = .white
        
        [authButton, emailField, tokenField, selectImageButton, avatarImageView, uploadImageButton, activityIndicator, resultLabel].forEach(rootStackView.addArrangedSubview)
        view.addSubview(rootStackView)
        
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: rootStackView.topAnchor),
            view.readableContentGuide.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
            view.readableContentGuide.trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor),
        ])
        
        uploadImageButton.addTarget(self, action: #selector(fetchProfileButtonHandler), for: .touchUpInside)
        selectImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
    }
    
    @objc func selectImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func fetchProfileButtonHandler() {
        guard
            activityIndicator.isAnimating == false,
            let email = emailField.text, email.isEmpty == false,
            let token = tokenField.text, token.isEmpty == false,
            let image = avatarImageView.image
        else {
            return
        }
        
        activityIndicator.startAnimating()
        resultLabel.text = nil
        
        let service = Gravatar.AvatarService()
        Task {
            do {
                try await service.upload(image, email: Email(email), accessToken: token)
                uploadResult(with: nil)
            } catch {
                uploadResult(with: error)
            }
        }
    }
    
    func uploadResult(with error: Error?) {
        activityIndicator.stopAnimating()
        if let error = error as? NSError {
            print("Error: \(error)")
            resultLabel.text = "Error \(error.code): \(error.localizedDescription)"
        } else {
            resultLabel.text = "Success! 🎉"
        }
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
    
    @objc func didTapAuthButton() {
        guard let url = URL(string: "https://public-api.wordpress.com/oauth2/authorize?client_id=99719&redirect_uri=wp-oauth-test://authorization-callback&response_type=code&scope=auth") else { return }
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "wp-oauth-test") { callbackURL, error in
            print("callbackURL: \(String(describing: callbackURL))")
            print("error: \(String(describing: error))")
            guard let callbackURL else { return }
            let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true)
            guard let code = components?.queryItems?.filter({ $0.name == "code" }).map({ $0.value }).first else { return }
            guard let tokenURL = URL(string: "https://public-api.wordpress.com/oauth2/token") else { return }
            var tokenRequest = URLRequest(url: tokenURL)
            tokenRequest.httpMethod = "POST"
            guard let code else { return }
            
            struct Params: Encodable {
                let client_id = "99719"
                let redirect_uri = "wp-oauth-test://authorization-callback"
                let client_secret = "won't write here"
                let code: String
                let grant_type = "authorization_code"
                init(code: String) {
                    self.code = code
                }
            }
            let params = Params(code: code)
            
            var components2 = URLComponents()
            components2.queryItems = [
                URLQueryItem(name: "client_id", value: params.client_id),
                URLQueryItem(name: "client_secret", value: params.client_secret),
                
                URLQueryItem(name: "grant_type", value: "authorization_code"),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "redirect_uri", value: params.redirect_uri)
            ]
            
            let basicToken = params.client_id+":"+params.client_secret
            guard let base64EncodedString = basicToken.data(using: .utf8)?.base64EncodedString() else { return }
            
            struct AuthResult: Decodable {
                let access_token: String
            }
            tokenRequest.httpBody = components2.query?.data(using: .utf8)
            tokenRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type") // change as per server requirements
            tokenRequest.setValue("Basic \(base64EncodedString)", forHTTPHeaderField: "Authorization")
            Task {
                do {
                    
                    print(String(describing: tokenRequest))
                    let result: (data: Data, response: URLResponse) = try await URLSession.shared.data(for: tokenRequest)
                    let res = try JSONDecoder().decode(AuthResult.self, from: result.data)
                    //let res = try JSONSerialization.jsonObject(with: result.data)
                    print(res.access_token)
                    self.tokenField.text = res.access_token
                } catch {
                    print(String(describing: error))
                }
            }
        }
        session.presentationContextProvider = self
        session.start()
    }
}

extension DemoUploadImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        avatarImageView.image = image
        
        dismiss(animated: true)
    }
}
