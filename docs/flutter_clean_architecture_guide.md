# Flutter Clean Architecture 완벽 가이드

## 목차
1. [Clean Architecture란?](#clean-architecture란)
2. [핵심 원칙](#핵심-원칙)
3. [레이어 구조](#레이어-구조)
4. [실제 프로젝트 구조](#실제-프로젝트-구조)
5. [각 레이어 상세 설명](#각-레이어-상세-설명)
6. [실전 예제: Todo 앱](#실전-예제-todo-앱)
7. [의존성 주입](#의존성-주입)
8. [에러 핸들링](#에러-핸들링)
9. [테스트 전략](#테스트-전략)
10. [Best Practices](#best-practices)

---

## Clean Architecture란?

**Clean Architecture**는 Robert C. Martin (Uncle Bob)이 제안한 소프트웨어 설계 철학으로, 코드를 여러 레이어로 분리하여 **유지보수성**, **테스트 용이성**, **확장성**을 극대화하는 아키텍처 패턴입니다.

### 왜 Clean Architecture를 사용하는가?

#### ❌ 일반적인 Flutter 앱의 문제점
```dart
// 모든 것이 한 파일에...
class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  User? user;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => isLoading = true);

    // UI 레이어에 HTTP 호출이...
    final response = await http.get(Uri.parse('https://api.example.com/user/1'));
    final json = jsonDecode(response.body);

    // UI 레이어에 비즈니스 로직이...
    user = User.fromJson(json);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // UI 코드...
  }
}
```

**문제점:**
- UI와 비즈니스 로직이 섞여 있음
- 테스트하기 어려움
- 재사용 불가능
- API가 바뀌면 모든 UI를 수정해야 함

#### ✅ Clean Architecture 적용 후
```dart
// Presentation Layer - UI만 담당
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) return CircularProgressIndicator();
        if (state is UserLoaded) return UserProfile(user: state.user);
        if (state is UserError) return ErrorWidget(message: state.message);
        return SizedBox();
      },
    );
  }
}

// Domain Layer - 비즈니스 로직
class GetUser {
  final UserRepository repository;
  GetUser(this.repository);

  Future<Either<Failure, User>> call(String userId) {
    return repository.getUser(userId);
  }
}

// Data Layer - 데이터 소스
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, User>> getUser(String userId) async {
    try {
      final userModel = await remoteDataSource.getUser(userId);
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
```

---

## 핵심 원칙

### 1. 관심사의 분리 (Separation of Concerns)
각 레이어는 명확한 책임을 가집니다.

### 2. 의존성 규칙 (Dependency Rule)
```
의존성은 항상 안쪽을 향합니다.

Presentation Layer  →  Domain Layer  ←  Data Layer
     (UI)           (비즈니스 로직)      (데이터)
```

**핵심:** Domain Layer는 다른 레이어를 알지 못합니다!

### 3. 추상화에 의존 (Depend on Abstractions)
구체적인 구현이 아닌 인터페이스(추상 클래스)에 의존합니다.

```dart
// ✅ Good: 추상화에 의존
class GetUser {
  final UserRepository repository; // 인터페이스
  GetUser(this.repository);
}

// ❌ Bad: 구체적 구현에 의존
class GetUser {
  final UserRepositoryImpl repository; // 구현체
  GetUser(this.repository);
}
```

---

## 레이어 구조

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │  Pages   │  │  Widgets │  │   BLoC   │      │
│  └──────────┘  └──────────┘  └──────────┘      │
├─────────────────────────────────────────────────┤
│              Domain Layer                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ Entities │  │ Use Cases│  │Repository│      │
│  │          │  │          │  │Interface │      │
│  └──────────┘  └──────────┘  └──────────┘      │
├─────────────────────────────────────────────────┤
│              Data Layer                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │  Models  │  │DataSource│  │Repository│      │
│  │          │  │          │  │   Impl   │      │
│  └──────────┘  └──────────┘  └──────────┘      │
└─────────────────────────────────────────────────┘
```

---

## 실제 프로젝트 구조

### 완전한 프로젝트 구조

```
lib/
├── core/                              # 공통으로 사용되는 코드
│   ├── error/
│   │   ├── exceptions.dart           # 데이터 레이어 예외
│   │   └── failures.dart             # 도메인 레이어 실패
│   ├── network/
│   │   └── network_info.dart         # 네트워크 상태 체크
│   ├── usecases/
│   │   └── usecase.dart              # UseCase 베이스 클래스
│   ├── utils/
│   │   ├── constants.dart
│   │   └── input_converter.dart
│   └── platform/
│       └── network_info.dart
│
├── features/                          # 기능별로 분리
│   ├── authentication/               # 인증 기능
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_data_source.dart
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login.dart
│   │   │       ├── logout.dart
│   │   │       └── register.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           └── custom_text_field.dart
│   │
│   ├── profile/                      # 프로필 기능
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── profile_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── profile_model.dart
│   │   │   └── repositories/
│   │   │       └── profile_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── profile.dart
│   │   │   ├── repositories/
│   │   │   │   └── profile_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_profile.dart
│   │   │       └── update_profile.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── profile_bloc.dart
│   │       │   ├── profile_event.dart
│   │       │   └── profile_state.dart
│   │       ├── pages/
│   │       │   └── profile_page.dart
│   │       └── widgets/
│   │           └── profile_avatar.dart
│   │
│   └── todos/                        # Todo 기능
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── todo_local_data_source.dart
│       │   │   └── todo_remote_data_source.dart
│       │   ├── models/
│       │   │   └── todo_model.dart
│       │   └── repositories/
│       │       └── todo_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── todo.dart
│       │   ├── repositories/
│       │   │   └── todo_repository.dart
│       │   └── usecases/
│       │       ├── add_todo.dart
│       │       ├── delete_todo.dart
│       │       ├── get_todos.dart
│       │       └── toggle_todo.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── todo_bloc.dart
│           │   ├── todo_event.dart
│           │   └── todo_state.dart
│           ├── pages/
│           │   └── todo_page.dart
│           └── widgets/
│               ├── todo_item.dart
│               └── add_todo_button.dart
│
├── injection_container.dart          # 의존성 주입 설정
└── main.dart                         # 앱 진입점
```

### Feature별 폴더 구조 상세

각 feature는 독립적인 모듈처럼 작동합니다:

```
feature_name/
├── data/                    # 데이터 계층
│   ├── datasources/        # 실제 데이터를 가져오는 곳
│   ├── models/             # JSON 변환 모델
│   └── repositories/       # Repository 구현
├── domain/                  # 도메인 계층 (핵심!)
│   ├── entities/           # 비즈니스 객체
│   ├── repositories/       # Repository 인터페이스
│   └── usecases/           # 비즈니스 로직
└── presentation/            # 프레젠테이션 계층
    ├── bloc/               # 상태 관리
    ├── pages/              # 전체 화면
    └── widgets/            # 재사용 위젯
```

---

## 각 레이어 상세 설명

### 1. Domain Layer (도메인 레이어)

**가장 중요한 레이어!** 순수한 Dart 코드만 사용하며, Flutter나 외부 패키지에 의존하지 않습니다.

#### 1.1 Entities (엔티티)

비즈니스 핵심 객체입니다.

```dart
// domain/entities/todo.dart
class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
  });

  // 비즈니스 로직 메서드
  Todo toggleComplete() {
    return Todo(
      id: id,
      title: title,
      description: description,
      isCompleted: !isCompleted,
      createdAt: createdAt,
    );
  }

  bool get isOverdue {
    return !isCompleted &&
           DateTime.now().difference(createdAt).inDays > 7;
  }
}
```

#### 1.2 Repository Interface (저장소 인터페이스)

데이터를 어떻게 가져올지 정의합니다 (구현은 Data Layer에서).

```dart
// domain/repositories/todo_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/todo.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<Todo>>> getTodos();
  Future<Either<Failure, Todo>> getTodoById(String id);
  Future<Either<Failure, void>> addTodo(Todo todo);
  Future<Either<Failure, void>> updateTodo(Todo todo);
  Future<Either<Failure, void>> deleteTodo(String id);
}
```

**왜 `Either`를 사용하는가?**
- `Either<Failure, Success>`: 실패 또는 성공을 표현
- 예외를 던지는 대신 명시적으로 에러를 처리
- `dartz` 패키지 사용

#### 1.3 Use Cases (사용 사례)

하나의 비즈니스 로직을 담당합니다.

```dart
// core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
```

```dart
// domain/usecases/get_todos.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class GetTodos implements UseCase<List<Todo>, NoParams> {
  final TodoRepository repository;

  GetTodos(this.repository);

  @override
  Future<Either<Failure, List<Todo>>> call(NoParams params) async {
    return await repository.getTodos();
  }
}
```

```dart
// domain/usecases/add_todo.dart
class AddTodo implements UseCase<void, AddTodoParams> {
  final TodoRepository repository;

  AddTodo(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTodoParams params) async {
    // 비즈니스 규칙 검증
    if (params.title.trim().isEmpty) {
      return Left(InvalidInputFailure());
    }

    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: params.title,
      description: params.description,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    return await repository.addTodo(todo);
  }
}

class AddTodoParams {
  final String title;
  final String description;

  AddTodoParams({required this.title, required this.description});
}
```

```dart
// domain/usecases/toggle_todo.dart
class ToggleTodo implements UseCase<void, String> {
  final TodoRepository repository;

  ToggleTodo(this.repository);

  @override
  Future<Either<Failure, void>> call(String todoId) async {
    // 1. Todo 가져오기
    final todoResult = await repository.getTodoById(todoId);

    return todoResult.fold(
      (failure) => Left(failure),
      (todo) async {
        // 2. 상태 토글
        final updatedTodo = todo.toggleComplete();

        // 3. 업데이트
        return await repository.updateTodo(updatedTodo);
      },
    );
  }
}
```

---

### 2. Data Layer (데이터 레이어)

실제로 데이터를 가져오고 저장하는 구현을 담당합니다.

#### 2.1 Models (모델)

Entity를 확장하고 JSON 변환 기능을 추가합니다.

```dart
// data/models/todo_model.dart
import '../../domain/entities/todo.dart';

class TodoModel extends Todo {
  TodoModel({
    required String id,
    required String title,
    required String description,
    required bool isCompleted,
    required DateTime createdAt,
  }) : super(
          id: id,
          title: title,
          description: description,
          isCompleted: isCompleted,
          createdAt: createdAt,
        );

  // JSON → Model
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Entity → Model 변환
  factory TodoModel.fromEntity(Todo entity) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
    );
  }
}
```

#### 2.2 Data Sources (데이터 소스)

##### Remote Data Source (원격 데이터)

```dart
// data/datasources/todo_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/error/exceptions.dart';
import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> getTodoById(String id);
  Future<void> addTodo(TodoModel todo);
  Future<void> updateTodo(TodoModel todo);
  Future<void> deleteTodo(String id);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'https://api.example.com';

  TodoRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TodoModel>> getTodos() async {
    final response = await client.get(
      Uri.parse('$baseUrl/todos'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => TodoModel.fromJson(json)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<TodoModel> getTodoById(String id) async {
    final response = await client.get(
      Uri.parse('$baseUrl/todos/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return TodoModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw NotFoundException();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<void> addTodo(TodoModel todo) async {
    final response = await client.post(
      Uri.parse('$baseUrl/todos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(todo.toJson()),
    );

    if (response.statusCode != 201) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    final response = await client.put(
      Uri.parse('$baseUrl/todos/${todo.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(todo.toJson()),
    );

    if (response.statusCode != 200) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/todos/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 204) {
      throw ServerException();
    }
  }
}
```

##### Local Data Source (로컬 데이터)

```dart
// data/datasources/todo_local_data_source.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/exceptions.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getCachedTodos();
  Future<void> cacheTodos(List<TodoModel> todos);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const CACHED_TODOS = 'CACHED_TODOS';

  TodoLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<TodoModel>> getCachedTodos() {
    final jsonString = sharedPreferences.getString(CACHED_TODOS);

    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(
        jsonList.map((json) => TodoModel.fromJson(json)).toList(),
      );
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) {
    final jsonString = json.encode(
      todos.map((todo) => todo.toJson()).toList(),
    );

    return sharedPreferences.setString(CACHED_TODOS, jsonString);
  }
}
```

#### 2.3 Repository Implementation (저장소 구현)

```dart
// data/repositories/todo_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_data_source.dart';
import '../datasources/todo_remote_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final TodoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Todo>>> getTodos() async {
    // 네트워크 연결 확인
    if (await networkInfo.isConnected) {
      try {
        // 원격에서 데이터 가져오기
        final remoteTodos = await remoteDataSource.getTodos();

        // 로컬에 캐시
        await localDataSource.cacheTodos(remoteTodos);

        return Right(remoteTodos);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      // 오프라인: 캐시된 데이터 사용
      try {
        final localTodos = await localDataSource.getCachedTodos();
        return Right(localTodos);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Todo>> getTodoById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final todo = await remoteDataSource.getTodoById(id);
        return Right(todo);
      } on NotFoundException {
        return Left(NotFoundFailure());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addTodo(Todo todo) async {
    if (await networkInfo.isConnected) {
      try {
        final todoModel = TodoModel.fromEntity(todo);
        await remoteDataSource.addTodo(todoModel);

        // 캐시 무효화 (다시 가져오기)
        final todos = await remoteDataSource.getTodos();
        await localDataSource.cacheTodos(todos);

        return Right(null);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateTodo(Todo todo) async {
    if (await networkInfo.isConnected) {
      try {
        final todoModel = TodoModel.fromEntity(todo);
        await remoteDataSource.updateTodo(todoModel);

        // 캐시 업데이트
        final todos = await remoteDataSource.getTodos();
        await localDataSource.cacheTodos(todos);

        return Right(null);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodo(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteTodo(id);

        // 캐시 업데이트
        final todos = await remoteDataSource.getTodos();
        await localDataSource.cacheTodos(todos);

        return Right(null);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
```

---

### 3. Presentation Layer (프레젠테이션 레이어)

UI와 상태 관리를 담당합니다.

#### 3.1 BLoC (Business Logic Component)

##### Events

```dart
// presentation/bloc/todo_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

class LoadTodos extends TodoEvent {}

class AddTodoEvent extends TodoEvent {
  final String title;
  final String description;

  const AddTodoEvent({required this.title, required this.description});

  @override
  List<Object> get props => [title, description];
}

class ToggleTodoEvent extends TodoEvent {
  final String todoId;

  const ToggleTodoEvent(this.todoId);

  @override
  List<Object> get props => [todoId];
}

class DeleteTodoEvent extends TodoEvent {
  final String todoId;

  const DeleteTodoEvent(this.todoId);

  @override
  List<Object> get props => [todoId];
}
```

##### States

```dart
// presentation/bloc/todo_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;

  const TodoLoaded({required this.todos});

  @override
  List<Object> get props => [todos];

  // 완료된 것과 미완료 필터링
  List<Todo> get completedTodos =>
      todos.where((todo) => todo.isCompleted).toList();

  List<Todo> get incompleteTodos =>
      todos.where((todo) => !todo.isCompleted).toList();
}

class TodoError extends TodoState {
  final String message;

  const TodoError({required this.message});

  @override
  List<Object> get props => [message];
}
```

##### BLoC

```dart
// presentation/bloc/todo_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/usecases/add_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_todos.dart';
import '../../domain/usecases/toggle_todo.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodos getTodos;
  final AddTodo addTodo;
  final ToggleTodo toggleTodo;
  final DeleteTodo deleteTodo;

  TodoBloc({
    required this.getTodos,
    required this.addTodo,
    required this.toggleTodo,
    required this.deleteTodo,
  }) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<ToggleTodoEvent>(_onToggleTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
  }

  Future<void> _onLoadTodos(
    LoadTodos event,
    Emitter<TodoState> emit,
  ) async {
    emit(TodoLoading());

    final result = await getTodos(NoParams());

    result.fold(
      (failure) => emit(TodoError(message: _mapFailureToMessage(failure))),
      (todos) => emit(TodoLoaded(todos: todos)),
    );
  }

  Future<void> _onAddTodo(
    AddTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    if (state is TodoLoaded) {
      emit(TodoLoading());

      final result = await addTodo(
        AddTodoParams(title: event.title, description: event.description),
      );

      await result.fold(
        (failure) async {
          emit(TodoError(message: _mapFailureToMessage(failure)));
        },
        (_) async {
          // 추가 후 다시 로드
          add(LoadTodos());
        },
      );
    }
  }

  Future<void> _onToggleTodo(
    ToggleTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;

      // Optimistic update (낙관적 업데이트)
      final updatedTodos = currentState.todos.map((todo) {
        if (todo.id == event.todoId) {
          return todo.toggleComplete();
        }
        return todo;
      }).toList();

      emit(TodoLoaded(todos: updatedTodos));

      // 서버에 업데이트
      final result = await toggleTodo(event.todoId);

      result.fold(
        (failure) {
          // 실패하면 이전 상태로 롤백
          emit(TodoLoaded(todos: currentState.todos));
          emit(TodoError(message: _mapFailureToMessage(failure)));
        },
        (_) {
          // 성공하면 최신 데이터 다시 로드
          add(LoadTodos());
        },
      );
    }
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    if (state is TodoLoaded) {
      emit(TodoLoading());

      final result = await deleteTodo(event.todoId);

      await result.fold(
        (failure) async {
          emit(TodoError(message: _mapFailureToMessage(failure)));
        },
        (_) async {
          add(LoadTodos());
        },
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return '서버 오류가 발생했습니다.';
      case CacheFailure:
        return '로컬 데이터를 불러올 수 없습니다.';
      case NetworkFailure:
        return '네트워크 연결을 확인해주세요.';
      case NotFoundFailure:
        return '항목을 찾을 수 없습니다.';
      default:
        return '예상치 못한 오류가 발생했습니다.';
    }
  }
}
```

#### 3.2 Pages

```dart
// presentation/pages/todo_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../widgets/add_todo_button.dart';
import '../widgets/todo_item.dart';

class TodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TodoBloc>()..add(LoadTodos()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Todos'),
        ),
        body: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            if (state is TodoInitial) {
              return Center(child: Text('초기 상태'));
            } else if (state is TodoLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is TodoLoaded) {
              if (state.todos.isEmpty) {
                return Center(
                  child: Text('할 일이 없습니다.\n아래 버튼을 눌러 추가해보세요!'),
                );
              }

              return ListView.builder(
                itemCount: state.todos.length,
                itemBuilder: (context, index) {
                  return TodoItem(todo: state.todos[index]);
                },
              );
            } else if (state is TodoError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(state.message),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TodoBloc>().add(LoadTodos());
                      },
                      child: Text('다시 시도'),
                    ),
                  ],
                ),
              );
            }
            return SizedBox();
          },
        ),
        floatingActionButton: AddTodoButton(),
      ),
    );
  }
}
```

#### 3.3 Widgets

```dart
// presentation/widgets/todo_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<TodoBloc>().add(DeleteTodoEvent(todo.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${todo.title} 삭제됨')),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) {
              context.read<TodoBloc>().add(ToggleTodoEvent(todo.id));
            },
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: todo.description.isNotEmpty
              ? Text(todo.description)
              : null,
          trailing: todo.isOverdue
              ? Chip(
                  label: Text('기한 초과'),
                  backgroundColor: Colors.red.shade100,
                )
              : null,
        ),
      ),
    );
  }
}
```

```dart
// presentation/widgets/add_todo_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';

class AddTodoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddTodoDialog(context),
      child: Icon(Icons.add),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('새 할 일 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: '제목',
                hintText: '할 일을 입력하세요',
              ),
              autofocus: true,
            ),
            SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: '설명 (선택)',
                hintText: '상세 내용을 입력하세요',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                context.read<TodoBloc>().add(
                      AddTodoEvent(
                        title: title,
                        description: descriptionController.text.trim(),
                      ),
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: Text('추가'),
          ),
        ],
      ),
    );
  }
}
```

---

## 의존성 주입

### GetIt 설정

```dart
// injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'features/todos/data/datasources/todo_local_data_source.dart';
import 'features/todos/data/datasources/todo_remote_data_source.dart';
import 'features/todos/data/repositories/todo_repository_impl.dart';
import 'features/todos/domain/repositories/todo_repository.dart';
import 'features/todos/domain/usecases/add_todo.dart';
import 'features/todos/domain/usecases/delete_todo.dart';
import 'features/todos/domain/usecases/get_todos.dart';
import 'features/todos/domain/usecases/toggle_todo.dart';
import 'features/todos/presentation/bloc/todo_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Todos
  // Bloc
  sl.registerFactory(
    () => TodoBloc(
      getTodos: sl(),
      addTodo: sl(),
      toggleTodo: sl(),
      deleteTodo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTodos(sl()));
  sl.registerLazySingleton(() => AddTodo(sl()));
  sl.registerLazySingleton(() => ToggleTodo(sl()));
  sl.registerLazySingleton(() => DeleteTodo(sl()));

  // Repository
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}
```

### main.dart

```dart
// main.dart
import 'package:flutter/material.dart';
import 'injection_container.dart' as di;
import 'features/todos/presentation/pages/todo_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Architecture Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoPage(),
    );
  }
}
```

---

## 에러 핸들링

### Exceptions (Data Layer)

```dart
// core/error/exceptions.dart
class ServerException implements Exception {}

class CacheException implements Exception {}

class NotFoundException implements Exception {}

class NetworkException implements Exception {}
```

### Failures (Domain Layer)

```dart
// core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class NetworkFailure extends Failure {}

class NotFoundFailure extends Failure {}

class InvalidInputFailure extends Failure {}
```

### Network Info

```dart
// core/network/network_info.dart
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
```

---

## 테스트 전략

### 1. Unit Tests (단위 테스트)

#### Use Case 테스트

```dart
// test/domain/usecases/get_todos_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([TodoRepository])
void main() {
  late GetTodos usecase;
  late MockTodoRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoRepository();
    usecase = GetTodos(mockRepository);
  });

  final tTodos = [
    Todo(
      id: '1',
      title: 'Test Todo',
      description: 'Test Description',
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
  ];

  test('should get todos from the repository', () async {
    // arrange
    when(mockRepository.getTodos())
        .thenAnswer((_) async => Right(tTodos));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Right(tTodos));
    verify(mockRepository.getTodos());
    verifyNoMoreInteractions(mockRepository);
  });
}
```

#### Repository 테스트

```dart
// test/data/repositories/todo_repository_impl_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  TodoRemoteDataSource,
  TodoLocalDataSource,
  NetworkInfo,
])
void main() {
  late TodoRepositoryImpl repository;
  late MockTodoRemoteDataSource mockRemoteDataSource;
  late MockTodoLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockTodoRemoteDataSource();
    mockLocalDataSource = MockTodoLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = TodoRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getTodos', () {
    final tTodoModels = [
      TodoModel(
        id: '1',
        title: 'Test',
        description: 'Desc',
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
    ];

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getTodos())
          .thenAnswer((_) async => tTodoModels);
      when(mockLocalDataSource.cacheTodos(any))
          .thenAnswer((_) async => Future.value());

      // act
      await repository.getTodos();

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    test('should return remote data when online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getTodos())
          .thenAnswer((_) async => tTodoModels);
      when(mockLocalDataSource.cacheTodos(any))
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.getTodos();

      // assert
      verify(mockRemoteDataSource.getTodos());
      verify(mockLocalDataSource.cacheTodos(tTodoModels));
      expect(result, Right(tTodoModels));
    });

    test('should return cached data when offline', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.getCachedTodos())
          .thenAnswer((_) async => tTodoModels);

      // act
      final result = await repository.getTodos();

      // assert
      verifyZeroInteractions(mockRemoteDataSource);
      verify(mockLocalDataSource.getCachedTodos());
      expect(result, Right(tTodoModels));
    });
  });
}
```

### 2. Widget Tests

```dart
// test/presentation/widgets/todo_item_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tTodo = Todo(
    id: '1',
    title: 'Test Todo',
    description: 'Test Description',
    isCompleted: false,
    createdAt: DateTime.now(),
  );

  testWidgets('should display todo title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodoItem(todo: tTodo),
        ),
      ),
    );

    expect(find.text('Test Todo'), findsOneWidget);
  });

  testWidgets('should have checkbox', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodoItem(todo: tTodo),
        ),
      ),
    );

    expect(find.byType(Checkbox), findsOneWidget);
  });
}
```

### 3. BLoC Tests

```dart
// test/presentation/bloc/todo_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([GetTodos, AddTodo, ToggleTodo, DeleteTodo])
void main() {
  late TodoBloc bloc;
  late MockGetTodos mockGetTodos;
  late MockAddTodo mockAddTodo;
  late MockToggleTodo mockToggleTodo;
  late MockDeleteTodo mockDeleteTodo;

  setUp(() {
    mockGetTodos = MockGetTodos();
    mockAddTodo = MockAddTodo();
    mockToggleTodo = MockToggleTodo();
    mockDeleteTodo = MockDeleteTodo();

    bloc = TodoBloc(
      getTodos: mockGetTodos,
      addTodo: mockAddTodo,
      toggleTodo: mockToggleTodo,
      deleteTodo: mockDeleteTodo,
    );
  });

  final tTodos = [
    Todo(
      id: '1',
      title: 'Test',
      description: 'Desc',
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
  ];

  blocTest<TodoBloc, TodoState>(
    'should emit [Loading, Loaded] when LoadTodos is successful',
    build: () {
      when(mockGetTodos(any))
          .thenAnswer((_) async => Right(tTodos));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadTodos()),
    expect: () => [
      TodoLoading(),
      TodoLoaded(todos: tTodos),
    ],
  );

  blocTest<TodoBloc, TodoState>(
    'should emit [Loading, Error] when LoadTodos fails',
    build: () {
      when(mockGetTodos(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadTodos()),
    expect: () => [
      TodoLoading(),
      TodoError(message: '서버 오류가 발생했습니다.'),
    ],
  );
}
```

---

## Best Practices

### 1. 레이어 분리 원칙

```dart
// ❌ Bad: Domain이 Data에 의존
// domain/entities/user.dart
import '../../data/models/user_model.dart'; // 절대 안됨!

class User extends UserModel { ... }

// ✅ Good: Data가 Domain에 의존
// data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends User { ... }
```

### 2. Use Case는 하나의 책임만

```dart
// ❌ Bad: 여러 일을 하는 UseCase
class UserOperations {
  Future<void> loginAndGetProfile() { ... }
  Future<void> updateAndNotify() { ... }
}

// ✅ Good: 각각 분리
class Login { ... }
class GetProfile { ... }
class UpdateProfile { ... }
class NotifyUser { ... }
```

### 3. Repository 인터페이스는 Domain에

```dart
// ✅ domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
}

// ✅ data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  // 구현...
}
```

### 4. Equatable 사용하기

```dart
// Entity, Event, State에서 비교를 쉽게
class Todo extends Equatable {
  final String id;
  final String title;

  @override
  List<Object> get props => [id, title];
}
```

### 5. Freezed 사용 (선택사항)

불변 객체를 쉽게 만들 수 있습니다:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';

@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    required String description,
    required bool isCompleted,
    required DateTime createdAt,
  }) = _Todo;
}
```

### 6. 명확한 네이밍

```dart
// Use Cases
class GetTodos { ... }         // get으로 시작
class AddTodo { ... }          // add
class UpdateTodo { ... }       // update
class DeleteTodo { ... }       // delete

// Events
class LoadTodos { ... }        // Load, Fetch 등
class AddTodoEvent { ... }     // Event 접미사
class ToggleTodoEvent { ... }

// States
class TodoInitial { ... }      // Initial
class TodoLoading { ... }      // Loading
class TodoLoaded { ... }       // Loaded
class TodoError { ... }        // Error
```

---

## 필요한 패키지

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # 상태 관리
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # 함수형 프로그래밍
  dartz: ^0.10.1

  # 의존성 주입
  get_it: ^7.6.4

  # 네트워크
  http: ^1.1.0
  internet_connection_checker: ^1.0.0+1

  # 로컬 저장소
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  # 테스트
  mockito: ^5.4.2
  bloc_test: ^9.1.4
  build_runner: ^2.4.6

  # 코드 생성 (선택)
  freezed: ^2.4.5
  json_serializable: ^6.7.1
```

---

## 요약

### Clean Architecture의 장점

1. **테스트 용이성**: 각 레이어를 독립적으로 테스트
2. **유지보수성**: 코드가 명확하게 분리되어 관리 쉬움
3. **확장성**: 새 기능 추가가 쉬움
4. **독립성**: UI, DB, 프레임워크 변경이 쉬움
5. **재사용성**: 비즈니스 로직 재사용 가능

### 핵심 기억사항

```
Presentation (UI)
    ↓
Domain (비즈니스 로직) ← 가장 중요!
    ↑
Data (데이터 소스)
```

의존성은 항상 안쪽(Domain)을 향합니다!

---

이 가이드를 참고하여 Flutter Clean Architecture를 실전에 적용해보세요! 🚀
