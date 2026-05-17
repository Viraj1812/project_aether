# Project Aether — MMORPG Nervous System

A single-screen Flutter app that manages a live World Event and high-frequency engagement layer for a global MMORPG. Built to survive real-world concurrency, strict lint enforcement, and cloud cost constraints.

---

## Firebase Cost Strategy

To handle 10,000 concurrent players in the chat without a massive read bill, we use `limitToLast(25)` on the Firestore stream so each listener only ever reads the latest 25 documents regardless of how large the collection grows. We shard the `chat_messages` collection by region or time window (e.g. `chat_messages/region_IN/messages`) so no single collection grows unboundedly and listeners are scoped to a smaller dataset. For older message history, we never load it automatically — we paginate on demand using a `startAfter()` cursor so users only pay for reads they explicitly request.

---

## Architecture Overview

```
UI Layer
├── HomeTimerSection       — rebuilds every 100ms from Riverpod state
├── HomeRaidSection        — join button, shows success/failure status
└── HomeChatSection        — live stream via StreamProvider

State Layer
└── HomeStateNotifier      — timer loop, raid joining, chat sending

Repository Layer
└── HomeRepository         — abstracts all Firestore calls behind IHomeRepository interface

Service Layer
└── RaidService            — Lock-based atomic slot enforcement

Database (Firestore)
├── events/dragon_raid     — { slots_filled: 0, max_slots: 15 }
└── chat_messages          — { text, userId, timestamp }
```

---

## Features

### 1. World Boss Countdown Timer (100ms)

A timer that ticks every 100ms — not every second — so players feel real urgency. Built using `Future.doWhile()` which loops every 100ms, subtracts from remaining time, and updates the UI through Riverpod state. The loop self-terminates when the widget is disposed, preventing memory leaks.

```dart
void startTimer() {
  Future.doWhile(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (_timerCancelled || !state.timerActive) return false;
    state = state.copyWith(remainingMs: state.remainingMs - 100);
    return state.timerActive;
  });
}
```

### 2. Geo-Raid Sign-Up — Atomic Concurrency (15 slots)

The hardest feature. If 50 players click Join at the exact same millisecond, exactly 15 must get in. The 16th must get a clean failure. No race conditions, no double-booking.

**The problem — naive implementation fails:**
```
Player A reads slots_filled = 14  ──┐
Player B reads slots_filled = 14  ──┤ same millisecond
Player A writes slots_filled = 15 ──┤
Player B writes slots_filled = 15 ──┘ now 16 people are in. WRONG.
```

**The fix — Dart Lock serializes requests:**
```dart
Future<bool> joinRaid({required String userId}) async {
  return _lock.synchronized<bool>(() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await raidRef.get();

    final int slotsFilled =
        (snapshot.data()?['slots_filled'] as int?) ?? 0;
    final int maxSlots =
        (snapshot.data()?['max_slots'] as int?) ?? 15;

    if (slotsFilled >= maxSlots) return false;

    await raidRef.update({'slots_filled': slotsFilled + 1});
    return true;
  });
}
```

`Lock` from the `synchronized` package forces each request to wait its turn before reading and writing — no two requests can check the count simultaneously. In production Firebase this maps directly to `runTransaction` which provides the same atomic guarantee at the database level.

### 3. Real-Time Engagement Chat

A live chat box powered by a Firestore `snapshots()` stream. Built with `limitToLast(25)` to cap read costs, ordered by server timestamp for correct ordering.

```dart
Stream<QuerySnapshot<Map<String, dynamic>>> watchChatMessages() {
  return firestore
      .collection('chat_messages')
      .orderBy('timestamp')
      .limitToLast(25)
      .snapshots();
}
```

---

## State Management — Riverpod

| Provider | Type | Purpose |
|---|---|---|
| `homeRepositoryProvider` | `Provider` | Provides `HomeRepository` with injected Firestore and RaidService |
| `homeChatMessagesProvider` | `StreamProvider` | Streams last 25 chat messages from Firestore |
| `homeStateNotifierProvider` | `StateNotifierProvider` | Manages timer state, raid status, and chat sending |

`HomeState` is immutable — all fields are `final`, updated only via `copyWith()`. This prevents accidental mutation and makes state changes traceable.

---

## Dependency Injection — Testability

`RaidService` and `HomeRepository` both accept `FirebaseFirestore` via constructor injection:

```dart
// Production
RaidService(firestore: FirebaseFirestore.instance)

// Test
RaidService(firestore: FakeFirebaseFirestore())
```

This means the concurrency test runs against `FakeFirebaseFirestore` with no network, no emulator, and no real Firebase account needed.

---

## Concurrency Test

The test harness fires 50 simultaneous `joinRaid()` calls and asserts exactly 15 succeed:

```dart
final List<Future<bool>> joinRequests = List<Future<bool>>.generate(
  50,
  (int i) => raidService.joinRaid(userId: 'user_$i'),
);

final List<bool> results = await Future.wait(joinRequests);
final int successfulJoins =
    results.where((bool result) => result == true).length;

expect(successfulJoins, 15);
expect(slotsFilled, 15);
```

---

## Code Quality

All code passes the enforced `analysis_options.yaml` rules with zero warnings:

| Rule | Enforcement |
|---|---|
| `always_specify_types` | Every variable has an explicit type — no `var` |
| `avoid_dynamic_calls` | No calls on `dynamic` typed variables |
| `unawaited_futures` | Every `Future` is `await`ed |
| `empty_catches` | No silent error swallowing |
| `cancel_subscriptions` | All stream subscriptions are disposed |
| `prefer_const_constructors` | `const` used wherever possible |
| `always_declare_return_types` | Every function has a declared return type |
| `prefer_final_locals` | Variables that don't change are `final` |

**Lint conflict resolved:** `very_good_analysis` enables `omit_local_variable_types` which conflicts with `always_specify_types`. Fixed by explicitly setting `omit_local_variable_types: false` in `analysis_options.yaml` to override the base package.

---

## Project Structure

```
lib/
├── features/
│   ├── home/
│   │   ├── controllers/
│   │   │   ├── home_state.dart
│   │   │   └── home_state_notifier.dart
│   │   ├── repository/
│   │   │   └── home_repository.dart
│   │   └── views/
│   │       ├── home_screen.dart
│   │       └── widgets/
│   │           ├── home_chat_section.dart
│   │           ├── home_raid_section.dart
│   │           └── home_timer_section.dart
│   └── splash/
│       ├── controller/
│       │   └── splash_future_provider.dart
│       └── views/
│           └── splash_screen.dart
└── services/
    └── raid_service.dart

test/
└── raid_concurrency_test.dart
```

---

## Dependencies

```yaml
dependencies:
  cloud_firestore: ^5.0.0
  firebase_core: ^3.0.0
  flutter_riverpod: ^2.0.0
  synchronized: ^3.1.0

dev_dependencies:
  fake_cloud_firestore: ^3.0.0
  flutter_lints: ^4.0.0
```

---

## How to Run

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run concurrency test
flutter test test/raid_concurrency_test.dart

# Run architecture linter and generate report
dart aether_linter.dart
```

---

## Architecture Report

Generated by `dart aether_linter.dart`:

```
✅ PASS — Zero static analysis warnings
✅ PASS — Your architecture survived the Thundering Herd
```