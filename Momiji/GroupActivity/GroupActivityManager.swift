import Combine
import GroupActivities
import RealityKit
import SwiftUI

@Observable
class GroupActivityManager {
    var session: GroupSession<MomijiActivity>?
    var messenger: GroupSessionMessenger?
    var reliableMessenger: GroupSessionMessenger?
    var subscriptions = Set<AnyCancellable>()
    var tasks = Set<Task<Void, Never>>()
    var isSharePlaying = false
    

    // MARK: Start SharePlay session
    func startSession() async {
        do {
            let _ = try await MomijiActivity().activate()
        } catch {
            print("Failed to activate MomijiActivity: \(error)")
        }
    }

    // MARK: Configure session
    func configureGroupSession(session: GroupSession<MomijiActivity>, appState: AppState) async {
        self.session = session

        subscriptions.removeAll()
        tasks.forEach { $0.cancel() }
        tasks.removeAll()

        messenger = GroupSessionMessenger(session: session, deliveryMode: .unreliable)
        reliableMessenger = GroupSessionMessenger(session: session, deliveryMode: .reliable)
        setupStateSubscription(for: session)
        setupParticipantsSubscription(for: session)
        
        await setCoordinatorConfiguration(session: session)
        session.join()
        isSharePlaying = true
    }

    // Monitor session state and
    // set up a subscription that terminates the session if it becomes invalid
    private func setupStateSubscription(for session: GroupSession<MomijiActivity>) {
//        session.$state
//            .sink { [weak self] state in
//                if case .invalidated = state {
//                    await self?.endSession()
//                }
//            }
//            .store(in: &subscriptions)
    }

    // MARK: Monitor changes in participants and set up a subscription that sends the current information to new participants
    private func setupParticipantsSubscription(for session: GroupSession<MomijiActivity>) {
        session.$activeParticipants
            .sink { [] activeParticipants in
                let newParticipants = activeParticipants.subtracting(session.activeParticipants)
                print("newParticipants: \(newParticipants)")
            }
            .store(in: &subscriptions)
    }

    // MARK: Configure the system coordinator
    private func setCoordinatorConfiguration(session: GroupSession<MomijiActivity>) async {
        if let coordinator = await session.systemCoordinator {
            var config = SystemCoordinator.Configuration()
            config.spatialTemplatePreference = .sideBySide
            config.supportsGroupImmersiveSpace = true
            coordinator.configuration = config

        }
    }

    // MARK: End SharePlay session
    func endSession() async -> Bool {
        guard session != nil else {
            return false
        }
        isSharePlaying = false
        messenger = nil
        reliableMessenger = nil
        tasks.forEach { task in
            task.cancel()
        }
        tasks.removeAll()
        subscriptions.removeAll()
        session?.leave()
        session = nil
        
        return true
    }
}
