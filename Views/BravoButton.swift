//
//  BravoButton.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

// MARK: - BravoButton
//
// Bouton "bravo" inline affiché sur un Promi pour marquer son soutien.
// Design minimal — un icône thumbsup + le compteur — sans fond pour rester
// discret dans les contextes où il est intégré (détail d'un Promi, liste
// de commentaires, vue partagée…). L'état actif passe en orange brand
// pour signaler clairement que l'utilisateur a déjà donné son bravo.
// L'état inactif utilise un blanc désaturé cohérent avec l'identité chrome
// des pages récentes (white/0.58).
//
// Note: le toggle n'est qu'unidirectionnel (add-only) — une fois qu'un
// bravo est donné, il reste. Un tap en état actif ne fait qu'un haptic
// subtil, sans action. C'est intentionnel : un bravo est un engagement
// positif qu'on ne peut pas "reprendre". Si un retrait devient nécessaire
// à l'avenir, ajouter une méthode `removePromiBravo` au PromiStore et
// brancher ici sans toucher au reste.

struct BravoButton: View {
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore

    let promiId: UUID
    let count: Int
    let isActive: Bool


    var body: some View {
        Button(action: toggleBravo) {
            HStack(spacing: 4) {
                Image(systemName: isActive ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.system(size: 14))
                Text("\(count)")
                    .font(.system(size: 12, weight: .regular))
            }
            .foregroundColor(
                isActive
                    ? Brand.orange
                    : Color.white.opacity(0.58)
            )
        }
        .buttonStyle(.plain)
    }

    private func toggleBravo() {
        if isActive {
            // User has already bravoed — no state change, just a subtle
            // acknowledgment haptic so the tap still feels alive.
            Haptics.shared.lightTap()
        } else {
            let bravo = Bravo(
                promiId: promiId,
                userId: userStore.localUserId
            )
            promiStore.addBravo(bravo)
            Haptics.shared.success()
        }
    }
}
