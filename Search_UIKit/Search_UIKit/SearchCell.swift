
import UIKit

final class SearchCell: UITableViewCell {
    
    private let cityLabel = UILabel().then {
        $0.textColor = .systemBlue
    }
    
    let indicator = UIActivityIndicatorView(style: .medium).then {
        $0.startAnimating()
        $0.isHidden = true
    }
    
    private let detailLabel = UILabel().then {
        $0.isHidden = true
        $0.textColor = .label
        $0.numberOfLines = 0
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        selectionStyle = .none
        
        let hStack = UIStackView(arrangedSubviews: [cityLabel, indicator])
        hStack.spacing = 10
        
        let vStack = UIStackView(arrangedSubviews: [hStack, detailLabel])
        vStack.axis = .vertical
        vStack.spacing = 10
        
        contentView.addSubview(vStack)
        vStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }
    
    func setData(_ model: GeocodingSearch.Result) {
        cityLabel.text = model.name
    }
    
    func setWeather(_ model: Search.State.Weather?) {
        guard let model else {
            detailLabel.text = nil
            detailLabel.isHidden = true
            return
        }
        
        let days = model.days.enumerated().map { index, weather in
            formattedWeather(day: weather, isToday: index == 0)
        }.joined(separator: "\n")
        
        detailLabel.text = days
        detailLabel.isHidden = false
    }
}

// MARK: - Helper

private func formattedWeather(day: Search.State.Weather.Day, isToday: Bool) -> String {
    let date = isToday
        ? "Today"
        : dateFormatter.string(from: day.date).capitalized
    let min = "\(day.temperatureMin)\(day.temperatureMinUnit)"
    let max = "\(day.temperatureMax)\(day.temperatureMaxUnit)"
    
    return "\(date), \(min) – \(max)"
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    return formatter
}()
