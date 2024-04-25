import UIKit
@testable import GravatarUI

class DemoRemoteSVGViewController: UITableViewController {
    
    var paletteType: PaletteType = .dark
    
    enum Row: String, CaseIterable {
        case tumblr
        case facebook
        case twitter
        case twitch
        case fediverse
        case invalid = "invalid URL"
        
        var urlString: String {
            switch self {
            case .tumblr:
                 "https://secure.gravatar.com/icons/tumblr.svg"
            case .facebook:
                "https://secure.gravatar.com/icons/facebook.svg"
            case .twitter:
                "https://secure.gravatar.com/icons/twitter-alt.svg"
            case .twitch:
                "https://secure.gravatar.com/icons/twitch.svg"
            case .fediverse:
                "https://secure.gravatar.com/icons/fediverse.svg"
            case .invalid:
                "https://secure.gravatar.com/icons/nosuchicon.svg"
            }
        }
        
        var url: URL? { URL(string: urlString) }
    }
    
    private static let reuseID =  "DefaultCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SVGImageCell.self, forCellReuseIdentifier: Self.reuseID)
        tableView.backgroundColor = paletteType.palette.background.primary
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.reuseID, for: indexPath) as? SVGImageCell else { return UITableViewCell() }
        let row = Row.allCases[indexPath.row]
        cell.update(with: row.url, name: row.rawValue, paletteType: paletteType)
        return cell
    }
}

class SVGImageCell: UITableViewCell {
    static let iconSize = CGSize(width: 50, height: 50)
    let logoView: AccountIconWebView = {
        let view = AccountIconWebView(iconSize: iconSize, paletteType: .dark) {
            print("Tapped!")
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: iconSize.height).isActive = true
        view.widthAnchor.constraint(equalToConstant: iconSize.width).isActive = true
        return view
    }()
    
    let iconNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(logoView)
        contentView.addSubview(iconNameLabel)
        NSLayoutConstraint.activate([
            logoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            logoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            iconNameLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 20),
            iconNameLabel.centerYAnchor.constraint(equalTo: logoView.centerYAnchor)
        ])
    }
    
    func update(with url: URL?, name: String, paletteType: PaletteType) {
        guard let url else { return }
        logoView.paletteType = paletteType
        logoView.load(from: url)
        iconNameLabel.text = name
        iconNameLabel.textColor = paletteType.palette.foreground.primary
        contentView.backgroundColor = paletteType.palette.background.primary
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
