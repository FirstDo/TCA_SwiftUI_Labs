import SwiftUI
import ComposableArchitecture

struct WebSocket: ReducerProtocol {
  struct State: Equatable {
    var alert: AlertState<Action>?
    var connectivityState = ConnectivityState.disconnected
    var messageToSend = ""
    var receivedMesage: [String] = []
    
    enum ConnectivityState: String {
      case connected
      case connecting
      case disconnected
    }
  }
  
  enum Action: Equatable {
    case alertDismissed
    case connectButtonTapped
    case messageToSendChanged(String)
    case receivedSocketMessage(TaskResult<WebSocketClient.Message>)
    case sendButtonTapped
    case sendResponse(didSucceed: Bool)
    case webSocket(WebSocketClient.Action)
  }
  
  @Dependency(\.continuousClock) var clock
  @Dependency(\.webSocket) var webSocket
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .alertDismissed:
      state.alert = nil
      return .none
      
    case .connectButtonTapped:
      switch state.connectivityState {
      case .connected, .connecting:
        state.connectivityState = .disconnected
        return .cancel(id: WebSocketClient.ID())
      case .disconnected:
        state.connectivityState = .connecting
        return .run { send in
          let actions = await self.webSocket.open(
            WebSocketClient.ID(),
            URL(string: "wss://echo.websocket.events")!,
            []
          )
          await withThrowingTaskGroup(of: Void.self) { group in
            for await action in actions {
              group.addTask { await send(.webSocket(action)) }
              switch action {
              case .didOpen:
                group.addTask {
                  while !Task.isCancelled {
                    try await self.clock.sleep(for: .seconds(10))
                    try? await self.webSocket.sendPing(WebSocketClient.ID())
                  }
                }
                
                group.addTask {
                  for await result in try await self.webSocket.receive(WebSocketClient.ID()) {
                    await send(.receivedSocketMessage(result))
                  }
                }
              case .didClose:
                return
              }
            }
          }
        }
        .cancellable(id: WebSocketClient.ID())
      }
      
    case let .messageToSendChanged(message):
      state.messageToSend = message
      return .none
      
    case let .receivedSocketMessage(.success(message)):
      if case let .string(string) = message {
        state.receivedMesage.append(string)
      }
      return .none
      
    case .receivedSocketMessage(.failure):
      return .none
      
    case .sendButtonTapped:
      let messageToÍend = state.messageToSend
      state.messageToSend = ""
      return .run { send in
        try await self.webSocket.send(WebSocketClient.ID(), .string(messageToÍend))
        await send(.sendResponse(didSucceed: true))
      } catch: { error, send in
        await send(.sendResponse(didSucceed: false))
      }
      .cancellable(id: WebSocketClient.ID())
      
    case .sendResponse(didSucceed: false):
      state.alert = AlertState {
        TextState("Could not send socket message. Connect to the server first, and try again.")
      }
      return .none
      
    case .sendResponse(didSucceed: true):
      return .none
      
    case .webSocket(.didClose):
      state.connectivityState = .disconnected
      return .cancel(id: WebSocketClient.ID())
      
    case .webSocket(.didOpen):
      state.connectivityState = .connected
      state.receivedMesage.removeAll()
      return .none
    }
  }
}

struct WebSocketView: View {
  let store: StoreOf<WebSocket>
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Form {
        Section {
          VStack(alignment: .leading) {
            Button(
              viewStore.connectivityState == .connected
              ? "Disconnect"
              : viewStore.connectivityState == .disconnected
              ? "Connect"
              : "Conecting..."
            ) {
              viewStore.send(.connectButtonTapped)
            }
            .buttonStyle(.bordered)
            .tint(viewStore.connectivityState == .connected ? .red : .green)
            
            HStack {
              TextField(
                "Type message here",
                text: viewStore.binding(
                  get: \.messageToSend, send: WebSocket.Action.messageToSendChanged
                )
              )
              .textFieldStyle(.roundedBorder)
              
              Button("Send") {
                viewStore.send(.sendButtonTapped)
              }
              .buttonStyle(.borderless)
            }
          }
        }
        
        Section {
          Text("Status: \(viewStore.connectivityState.rawValue)")
            .foregroundStyle(.secondary)
          Text(viewStore.receivedMesage.reversed().joined(separator: "\n"))
        } header: {
          Text("Received messages")
        }
      }
      .alert(store.scope(state: \.alert, action: { $0 }), dismiss: .alertDismissed)
      .navigationTitle("Web Socket")
    }
  }
}

struct WebSocketView_Previews: PreviewProvider {
  static var previews: some View {
    WebSocketView(store: Store(initialState: WebSocket.State(), reducer: WebSocket()))
  }
}
