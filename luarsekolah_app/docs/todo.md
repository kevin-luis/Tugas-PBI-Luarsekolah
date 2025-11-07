### 📄 `README.md` (Clean Architecture Overview)

# 🏛️ Application Architecture (Clean Architecture)

This project is built using the **Clean Architecture** pattern (also known as Hexagonal or Ports and Adapters) to separate the core business logic from implementation details (such as databases, UI, or external APIs). The goal is to create a system that is highly **Testable**, **Maintainable**, and **Scalable**.

## 1. 🌐 Layer Overview

The architecture is divided into concentric layers, where each layer only depends on the layers deeper inside (the dependency rule). Dependencies must always point inwards.

### 1.1. 🧠 Domain Layer (The Core)
This is the innermost and purest layer.
* **Function:** Contains the core *Business Rules* and *Entities* of the application.
* **Components:** `Entities` (Pure business objects), `Interfaces/Abstract Repositories` (Contracts for data operations), and `Use Cases` (Application-specific business logic).
* **Dependency Rule:** Must not have any imports or dependencies on external frameworks (Flutter, GetX, Dio, etc.) or any outer layers.

### 1.2. 💻 Data Layer (Adapters/Implementation)
This layer is responsible for interacting with the outside world.
* **Function:** Translates data from external sources (API, Local DB) and implements the contracts defined in the Domain Layer.
* **Components:** `Models` (DTOs/Data Transfer Objects for JSON serialization) and `Repository Implementations` (e.g., `TodoRepositoryImpl`).
* **Dependency Rule:** Depends on the Domain Layer (as it implements the Domain *interfaces*) but must not depend on the Presentation Layer.

### 1.3. 🖼️ Presentation Layer (UI/Framework)
This is the outermost layer, where the user interacts.
* **Function:** Manages State, renders the UI, and handles user input.
* **Components:** `Pages`, `Widgets`, `Controllers` (GetX/Provider/Bloc), and `Bindings` (the Dependency Injection mechanism).
* **Dependency Rule:** Depends on the Domain Layer (to call Use Cases) and the Data Layer (for injection setup).

---

## 2. 🔄 Data Flow

The data flow is strictly governed to ensure the *dependency rule* is never violated.

### A. Data Request (Read/Write)
The request starts from the UI and flows **inwards**:

```mermaid
graph TD
    A[1. UI/Page Action] --> B(2. Controller/ViewModel);
    B --> C[3. Use Case/Interactor];
    C --> D{4. Repository Interface};
    D --> E[5. Repository Implementation];
    E --> F((6. External Data Source\n(API, Database)));
````

### B. Result Return

The result from the data source flows **outwards**:

```mermaid
graph TD
    F((6. External Data Source\n(API, Database))) --> G[7. Repository Implementation\n(Convert Model to Entity)];
    G --> C[8. Use Case/Interactor];
    C --> B(9. Controller/ViewModel\n(Update State));
    B --> A[10. UI Update (Obx/Stream)];
```

### 🎯 Todo Example Flow: Fetching Todos

1.  **`TodoListPage`** calls `controller.fetchTodos()`.
2.  **`TodoController`** calls `getTodosUseCase.call()`.
3.  **`GetTodosUseCase`** calls `todoRepository.getAllTodos()`.
4.  **`TodoRepositoryImpl`** (Data Layer) executes the HTTP call.
5.  Raw JSON data is converted into a **`TodoModel`**.
6.  The `TodoModel` is converted into a **`TodoEntity`** before being returned.
7.  **`GetTodosUseCase`** receives the `List<TodoEntity>`.
8.  **`TodoController`** receives the `List<TodoEntity>` and updates its reactive state (`_allTodos.obs`).
9.  **The UI** is automatically updated (via `Obx`).

-----

## 3\. 🛠️ Dependency Injection (DI)

The project uses **GetX Bindings** to manage Dependency Injection, ensuring that the correct dependencies are available for each feature.

  * The **`TodoBinding`** acts as the DI hub for the Todo feature.
  * All dependencies (Repository Implementations, Use Cases, Controllers) are registered using `Get.lazyPut()` for optimal performance (created only when first needed).
  * **Principle Applied:** The *Dependency Inversion Principle* (DIP). The inner Domain layer (`TodoRepository` interface) defines the contract, and the outer layer (`TodoRepositoryImpl`) implements it, reversing the dependency flow.

<!-- end list -->