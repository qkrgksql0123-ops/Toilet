# 볼일봐 🚻 — CLAUDE.md

> 이 파일은 Claude Code가 프로젝트를 이해하기 위한 컨텍스트 문서입니다.
> `Toilet/` 루트 디렉토리에 위치해야 합니다.

---

## 프로젝트 개요

| 항목 | 내용 |
|---|---|
| 앱 이름 | 볼일봐 (Bol-il-bwa) |
| 주제 | 공중화장실 지도 앱 |
| 레포 / 디렉토리 | Toilet |
| GitHub | https://github.com/qkrgksql0123-ops/Toilet |
| 플랫폼 | Flutter 3.44.0 (iOS / Android) |
| 언어 | Dart |

---

## 핵심 기능 (MVP)

1. **지도 표시** — 내 주변 공중화장실을 Google Maps 핀으로 표시
2. **청결도 별점/리뷰** — 사용자가 직접 청결도 평가 및 후기 작성
3. **즐겨찾기** — 자주 가는 화장실 저장
4. **비번 공유** — 잠긴 화장실 비밀번호를 커뮤니티로 공유 (좋아요로 신뢰도 표시)

---

## 기술 스택

| 분류 | 선택 | 이유 |
|---|---|---|
| 프론트엔드 | Flutter 3.x + Dart | 한 코드로 iOS/Android, 공식 Maps 패키지 |
| 상태관리 | Riverpod 2.x | Firebase StreamProvider 자연스러운 연동 |
| 백엔드 / DB | Firebase (Firestore + Auth) | 서버 불필요, 실시간 동기화 |
| 지도 API | Google Maps Flutter | 공식 패키지, 공공데이터 좌표 연동 |
| 공공데이터 | 행정안전부 공중화장실 현황 API | 전국 화장실 위치 데이터 |

---

## 아키텍처 — 4계층 레이어드

```
Presentation  →  Application  →  Domain  →  Data
(화면/위젯)       (ViewModel/UseCase)  (Entity/Rule)  (Firebase/API)
```

### 레이어별 역할

- **Presentation** `lib/presentation/` — 화면, 위젯, 테마. UI 로직만 담당
- **Application** `lib/application/` — Riverpod Provider, UseCase. 흐름 조율
- **Domain** `lib/domain/` — 순수 Dart. 비즈니스 규칙, 엔티티 모델
- **Data** `lib/data/` — Firebase, 공공데이터 API, 로컬 캐시

---

## 디렉토리 구조

```
Toilet/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── map_screen.dart           # 메인 지도 화면
│   │   │   ├── toilet_detail_screen.dart # 화장실 상세
│   │   │   ├── review_screen.dart        # 리뷰 작성
│   │   │   ├── favorites_screen.dart     # 즐겨찾기 목록
│   │   │   └── password_screen.dart      # 비번 공유
│   │   ├── widgets/
│   │   │   ├── toilet_marker.dart
│   │   │   ├── rating_widget.dart
│   │   │   ├── review_card.dart
│   │   │   └── password_card.dart
│   │   └── theme/
│   │       └── app_theme.dart
│   ├── application/
│   │   ├── view_models/
│   │   │   ├── map_view_model.dart
│   │   │   ├── toilet_view_model.dart
│   │   │   └── favorites_view_model.dart
│   │   ├── use_cases/
│   │   │   ├── search_nearby_toilets.dart
│   │   │   ├── add_review.dart
│   │   │   ├── share_password.dart
│   │   │   └── toggle_favorite.dart
│   │   └── state/
│   │       └── toilet_state.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── toilet.dart
│   │   │   ├── review.dart
│   │   │   └── password_share.dart
│   │   ├── services/
│   │   │   ├── distance_service.dart
│   │   │   └── rating_service.dart
│   │   └── rules/
│   │       └── toilet_rules.dart         # 반경 500m, 비번 최대 길이 등
│   └── data/
│       ├── repositories/
│       │   ├── toilet_repository.dart
│       │   ├── review_repository.dart
│       │   └── password_repository.dart
│       ├── api/
│       │   ├── firebase_service.dart
│       │   └── public_toilet_api.dart    # 행정안전부 공공데이터
│       └── local/
│           └── favorites_cache.dart
├── docs/
│   ├── architecture.md
│   ├── setup.md
│   └── adr/
│       ├── ADR-0000-app-selection.md
│       ├── ADR-0001-flutter.md
│       ├── ADR-0002-riverpod.md
│       ├── ADR-0003-firebase.md
│       └── ADR-0004-google-maps.md
├── CLAUDE.md                             # 이 파일
├── pubspec.yaml
├── .env.example
├── .gitignore
└── README.md
```

---

## Firestore 데이터 구조

```
toilets/
  {toiletId}/
    name: "서울역 공중화장실"
    lat: 37.5547
    lng: 126.9706
    address: "서울시 중구 ..."
    avgRating: 3.8
    isLocked: false           # 잠긴 화장실 여부

    reviews/
      {reviewId}/
        userId: string
        rating: number (1~5)
        comment: string
        createdAt: timestamp

    passwords/
      {pwId}/
        password: string
        userId: string
        likes: number
        createdAt: timestamp

users/
  {userId}/
    favorites/
      {toiletId}: true
```

---

## 주요 패키지 (pubspec.yaml)

```yaml
dependencies:
  flutter_riverpod: ^2.5.0      # 상태관리
  firebase_core: ^3.0.0         # Firebase 초기화
  cloud_firestore: ^5.0.0       # DB
  firebase_auth: ^5.0.0         # 인증
  google_maps_flutter: ^2.5.0   # 지도
  geolocator: ^11.0.0           # GPS 위치
  http: ^1.2.0                  # 공공데이터 API 호출
  shared_preferences: ^2.2.0    # 즐겨찾기 로컬 저장
```

---

## 환경변수 (.env)

```
GOOGLE_MAPS_API_KEY=
PUBLIC_TOILET_API_KEY=
FIREBASE_PROJECT_ID=
FIREBASE_API_KEY=
```

---

## 코딩 규칙 (Claude Code에게)

- 새 화면 → `lib/presentation/screens/` 에 추가
- 새 상태/Provider → `lib/application/view_models/` 에 추가
- 새 비즈니스 규칙 → `lib/domain/services/` 또는 `rules/` 에 추가
- Firebase/API 코드 → `lib/data/repositories/` 또는 `api/` 에 추가
- 모든 Provider는 Riverpod 2.x 문법 사용 (ConsumerWidget, ref.watch)
- 비동기 처리는 AsyncValue 패턴 사용
- 한국어 주석 사용
- 파일명은 snake_case

---

## 현재 진행 상태

- [x] ADR-0000~0004 작성 완료
- [x] WBS 작성 완료
- [x] architecture.md 작성 완료
- [x] setup.md 작성 완료
- [ ] Flutter 프로젝트 생성
- [ ] Firebase 연동
- [ ] Google Maps 연동
- [ ] 공공데이터 API 연동
- [ ] 화면 개발 (5개 화면)
- [ ] 테스트
- [ ] 발표 준비
