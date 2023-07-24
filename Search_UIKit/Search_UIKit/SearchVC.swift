import UIKit

import CombineCocoa
import ComposableArchitecture
import Then
import SnapKit

struct Search: ReducerProtocol {
    struct State: Equatable {
        var results: [GeocodingSearch.Result] = []
        var resultForecastRequestInFlight: GeocodingSearch.Result?
        var searchQuery = ""
        var weather: Weather?
        
        struct Weather: Equatable {
            var id: GeocodingSearch.Result.ID
            var days: [Day]
            
            struct Day: Equatable {
                var date: Date
                var temperatureMax: Double
                var temperatureMaxUnit: String
                var temperatureMin: Double
                var temperatureMinUnit: String
            }
        }
    }
    
    enum Action {
        case forecastResponse(GeocodingSearch.Result.ID, TaskResult<Forecast>)
        case searchQueryChanged(String)
        case searchResponse(TaskResult<GeocodingSearch>)
        case searchResultTapped(GeocodingSearch.Result)
    }
    
    @Dependency(\.weatherClient) var weatherClient
    private enum CancelID { case location, weather }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .forecastResponse(_, .failure):
            state.weather = nil
            state.resultForecastRequestInFlight = nil
            return .none
            
        case let .forecastResponse(id, .success(forecast)):
            state.weather = State.Weather(
                id: id,
                days: forecast.daily.time.indices.map {
                    State.Weather.Day(
                      date: forecast.daily.time[$0],
                      temperatureMax: forecast.daily.temperatureMax[$0],
                      temperatureMaxUnit: forecast.dailyUnits.temperatureMax,
                      temperatureMin: forecast.daily.temperatureMin[$0],
                      temperatureMinUnit: forecast.dailyUnits.temperatureMin
                    )
                }
            )
            state.resultForecastRequestInFlight = nil
            return .none
            
        case let .searchQueryChanged(query):
            state.searchQuery = query
            
            if query.isEmpty {
                state.results = []
                state.weather = nil
                return .cancel(id: CancelID.location)
            }
            
            return .run { [query = state.searchQuery] send in
                await send(.searchResponse(TaskResult {
                    try await self.weatherClient.search(query)
                }))
            }
            .cancellable(id: CancelID.location)
            
        case .searchResponse(.failure):
            state.results = []
            return .none
            
        case let .searchResponse(.success(response)):
            state.results = response.results
            return .none
            
        case let .searchResultTapped(location):
            state.resultForecastRequestInFlight = location
            
            return .run { send in
                await send(.forecastResponse(
                    location.id,
                    TaskResult { try await self.weatherClient.forecast(location) }
                ))
            }
            .cancellable(id: CancelID.weather, cancelInFlight: true)
        }
    }
}

final class SearchVC: BaseVC<Search> {
    private let searchBar: UISearchBar = {
        let v = UISearchBar()
        v.placeholder = "Seoul, Busan..."
        v.searchTextField.clearButtonMode = .whileEditing
        v.searchBarStyle = .prominent
        return v
    }()
    
    private let tableview = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.register(SearchCell.self, forCellReuseIdentifier: "SearchCell")
    }
    
    typealias DataSource = UITableViewDiffableDataSource<Int, GeocodingSearch.Result>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, GeocodingSearch.Result>
    
    private var dataSource: DataSource!
    
    override func setup() {
        title = "Search"
        
        view.addSubview(searchBar)
        view.addSubview(tableview)
        
        searchBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        tableview.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        dataSource = DataSource(tableView: tableview) { [unowned self] tableView, indexPath, item in
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
            cell.setData(item)
            
            if item.id == viewStore.weather?.id {
                cell.setWeather(viewStore.weather)
            } else {
                cell.setWeather(nil)
            }

            if viewStore.resultForecastRequestInFlight?.id == item.id {
                cell.indicator.isHidden = false
            } else {
                cell.indicator.isHidden = true
            }
            
            return cell
        }
    }
    
    override func bind() {
        searchBar.textDidChangePublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [unowned self] in
                viewStore.send(.searchQueryChanged($0))
            }
            .store(in: &cancelBag)
            
        tableview.didSelectRowPublisher
            .map(\.row)
            .removeDuplicates()
            .sink { [unowned self] index in
                let result = viewStore.results[index]
                viewStore.send(.searchResultTapped(result))
                tableview.reloadData()
            }
            .store(in: &cancelBag)
        
        viewStore.publisher.searchQuery
            .sink { [unowned self] in
                searchBar.text = $0
            }
            .store(in: &cancelBag)
        
        viewStore.publisher.results
            .sink(receiveValue: applySnapshot)
            .store(in: &cancelBag)
        
        viewStore.publisher.weather
            .sink { [unowned self] weather in
                tableview.reloadData()
            }
            .store(in: &cancelBag)
    }
    
    private func applySnapshot(_ items: [GeocodingSearch.Result]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}
