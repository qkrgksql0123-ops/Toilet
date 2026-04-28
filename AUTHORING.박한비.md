# AUTHORING.박한비.md
> **Version**: v1.0.0
> **Author**: 박한비
> **Project**: 알바 급여 계산기 (Alva Pay Calculator)
> **Course**: Vibe Coding Project — 앱 프로그래밍 응용
> **Last Updated**: 2026-04-28

---

## 📌 이 파일의 목적

이 단일 파일 하나로 프로젝트에 필요한 **모든 AI Agent 설정을 부트스트랩**한다.

> **핵심 원칙**: AI가 만들어줬어도, 나는 모든 것을 이해하고 설명할 수 있어야 한다.

---

## 1. 프로젝트 정의

### 1.1 앱 소개

| 항목 | 내용 |
|---|---|
| **앱 이름** | 알바페이 (AlvaPay) |
| **한 줄 설명** | 알바생이 직접 급여를 계산하고 불법 여부를 확인하는 앱 |
| **타겟 유저** | 시간제 근무(알바) 중인 대학생 및 청년층 |
| **플랫폼** | Flutter (Android / iOS 크로스플랫폼) |
| **백엔드** | 없음 (완전 로컬, 하드코딩된 노동법 수치 사용) |
| **AI 연동** | Claude API — 선택적 |

### 1.2 왜 만드냐

> 나는 지금 알바 중이다.
> 사장이 주휴수당을 제대로 주는지 매번 계산하기 귀찮다.
> 이 앱 하나면 바로 확인할 수 있다.

### 1.3 핵심 기능 목록

```
[필수 기능]
F-01. 시급 + 근무 시간 입력
F-02. 기본급 자동 계산
F-03. 주휴수당 자동 계산 (주 15시간 이상 근무 시)
F-04. 야간수당 자동 계산 (오후 10시 ~ 오전 6시 × 1.5배)
F-05. 연장수당 자동 계산 (주 40시간 초과 × 1.5배)
F-06. 최종 수령 금액 합산 표시
F-07. 근무 기록 로컬 저장 (월별 히스토리)

[선택 기능 — 가산점용]
F-08. AI 채팅 — "이거 불법이야?" 자연어 판단
F-09. 사장이 준 금액 vs 계산 금액 비교 → 차액 표시
```

### 1.4 노동법 수치 (하드코딩 기준, API 불필요)

```dart
const double MIN_WAGE_2025 = 10030;
const double NIGHT_MULTIPLIER = 1.5;
const int NIGHT_START_HOUR = 22;
const int NIGHT_END_HOUR = 6;
const int WEEKLY_STANDARD_HOURS = 40;
const int WEEKLY_HOLIDAY_PAY_MIN_HOURS = 15;

// 주휴수당 = (주 근무시간 / 40) × 8 × 시급
double calcHolidayPay(double weeklyHours, double hourlyWage) {
  if (weeklyHours < 15) return 0;
  return (weeklyHours / 40) * 8 * hourlyWage;
}
```

---

## 2. AGENTS.md — AI Agent 행동 규칙

### 역할
이 프로젝트의 AI Agent는 알바 급여 계산기 Flutter 앱의
전체 구현을 담당하는 시니어 Flutter 개발자다.

### 절대 규칙
1. 백엔드 서버 코드를 생성하지 않는다 — 완전 로컬 앱이다.
2. 외부 API 호출 코드는 F-08 (AI 채팅) 기능에만 허용한다.
3. 노동법 수치는 반드시 constants.dart에서만 관리한다.
4. 코드에는 반드시 한국어 주석을 달아준다.
5. 상태관리는 Provider 패턴을 사용한다.

### 디렉토리 구조
```
lib/
├── main.dart
├── constants/
│   └── labor_law.dart
├── models/
│   ├── work_record.dart
│   └── pay_result.dart
├── services/
│   ├── pay_calculator.dart
│   └── storage_service.dart
├── providers/
│   └── pay_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── input_screen.dart
│   ├── result_screen.dart
│   └── history_screen.dart
└── widgets/
    ├── pay_summary_card.dart
    └── work_time_input.dart
```

### 커밋 메시지 규칙
```
feat: 새 기능 추가
fix: 버그 수정
refactor: 코드 개선
docs: 문서 수정
style: UI/스타일 변경
```

---

## 3. skills/ — AI 스킬 정의

### skill-01: 급여 계산 로직 생성
트리거: "급여 계산 로직 만들어줘" / "pay_calculator.dart 작성해줘"
- calcBasePay(hours, wage) → 기본급
- calcHolidayPay(weeklyHours, wage) → 주휴수당
- calcNightPay(nightHours, wage) → 야간수당
- calcOvertimePay(overtimeHours, wage) → 연장수당

### skill-02: UI 화면 생성
트리거: "[화면이름] 화면 만들어줘"
- Material Design 3 기반 UI
- Provider로 상태 연결
- 한국어 텍스트 사용
- 메인 컬러: 초록색 계열

### skill-03: 문서 자동 생성
트리거: "기획서 써줘" / "README 만들어줘"
- 마크다운 형식으로 출력
- Mermaid 다이어그램 포함

---

## 4. rules/ — 코드/문서 작성 규칙

### rule-01: 코드 규칙
- 모든 파일 상단에 파일 목적 주석 1줄 작성
- 함수마다 한국어 주석으로 설명
- 매직 넘버 사용 금지 → constants에서 가져와서 사용
- null safety 준수 (? 연산자 적극 활용)
- 한 함수는 하나의 일만 한다 (단일 책임 원칙)

### rule-02: 문서 규칙
- 모든 문서는 마크다운으로 작성
- 날짜 형식: YYYY-MM-DD
- 표(Table)로 정리할 수 있는 내용은 표로 작성

### rule-03: Git 규칙
```
main       → 배포 가능한 안정 버전
dev        → 개발 통합 브랜치
feat/기능명  → 기능 개발 브랜치
```

---

## 5. commands/ — 자주 쓰는 명령어

```bash
flutter create alva_pay --org com.hanbi
flutter pub get
flutter run
flutter build apk --release
flutter test
flutter analyze
```

### 필요한 패키지 (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  intl: ^0.19.0
  http: ^1.2.0
```

---

## 6. LLM Wiki — 나만의 암묵지

### Flutter 팁
- SharedPreferences는 직접 List를 저장 못 한다 → jsonEncode/jsonDecode 사용
- Provider: ChangeNotifier extends → ChangeNotifierProvider로 감싸기

### AI Agent 잘 되는 패턴
- 파일 하나씩 요청하기
- 기존 코드 붙여넣고 "이거 기반으로 확장해줘" 패턴
- "규칙을 따라서"라고 명시하면 일관성 올라감
- Claude Code CLI: 종료는 /exit 사용 (Ctrl+C 두 번 금지!)

### 급여 계산 공식
- 기본급 = 시급 × 실제 근무시간
- 주휴수당 = (주 근무시간 / 40) × 8 × 시급 (주 15시간 이상)
- 야간수당 = 야간 근무시간 × 시급 × 0.5 (오후 10시~오전 6시)
- 연장수당 = 초과 시간 × 시급 × 0.5 (주 40시간 초과)
- 최종 수령액 = 기본급 + 주휴수당 + 야간 가산분 + 연장 가산분

---

## 7. 세션별 체크리스트

- [x] 세션 1: 팀 결정(1인팀), 주제 후보 3개, AUTHORING.md 작성, GitHub 리포 생성
- [ ] 세션 2: 기획서.md, WBS.md, 일정표.md
- [ ] 세션 3: 아키텍처.md, ADR.md, Flutter 초기 세팅, GitHub 리포 연결
- [ ] 세션 4: 핵심 기능(F-01~F-06) 구현, 중간 발표
- [ ] 세션 5: F-07 히스토리, F-08 AI 채팅(선택), 테스트, 버그 수정
- [ ] 세션 6: APK 빌드, README.md, AGENTS.md, 배포 가이드
- [ ] 세션 7: 최종 발표, Q&A 준비, 데모

---

## 8. 발표 Q&A 대비 — 개발자 기본 소양

Q. 사용한 플랫폼은 무엇이고 왜 선택했나?
A. Flutter. Android와 iOS를 하나의 코드베이스로 개발 가능하고 AI 코드 생성에 적합한 구조.

Q. 앱의 구조는 어떻게 되어 있나?
A. constants / models / services / providers / screens / widgets 레이어로 분리.

Q. 개발 환경 설정은 어떻게 하나?
A. Flutter SDK 설치 → flutter pub get → flutter run

Q. 빌드와 배포는 어떤 단계로 이뤄지나?
A. flutter build apk --release → APK 직접 배포 또는 Play Store 업로드

Q. 테스트는 어떻게 작성하고 실행하나?
A. flutter test 명령어. pay_calculator.dart 단위 테스트로 경계값 검증.

---

*이 파일은 프로젝트가 진행되면서 계속 업데이트된다.*
*AI가 만든 것도, 내가 이해하고 설명할 수 있으면 내 것이다.*
