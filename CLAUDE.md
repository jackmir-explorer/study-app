# CLAUDE.md

## 배포 & 커밋 규칙
- 변경 후 반드시 commit + push (GitHub Pages로 모바일/다른 PC에서 사용 중)
- 작업 단위가 작아도 예외 없음

## 앱 구조 (현황)
- 단일 파일: `index.html` (CSS·HTML·JS 전부 포함)
- 데이터 저장: `localStorage` → GitHub Gist 동기화
- 배포: https://jackmir-explorer.github.io/study-app/
- 모바일: Capacitor 네이티브 앱 (AnkiDroid 연동)

## 작업 제약
- 전체 파일 재작성 금지
- 수정 위치 먼저 확인 후 작업
- 교체할 코드 블록만 최소 범위로 수정
- 요청한 부분 외 다른 코드 수정 금지

## 작업 절차
1. 수정할 파일 확인
2. 수정 위치 확인 (Grep/Read)
3. 해당 블록만 Edit으로 교체
4. commit + push

## 작업 방침
- 불필요한 기능은 제거. 추가보다 단순화를 우선 검토
- 브라우저 vs 모바일 네이티브 동작이 다를 경우 `isNativeApp()`으로 분기
- JS에서 참조하는 HTML 요소 ID가 실제 존재하는지 확인
- 중요 데이터 저장 후엔 `schedulePush()`(2초 딜레이) 대신 `gistPush()` 직접 호출

## UX 원칙
- 읽기가 기본 상태. 편집은 명시적 버튼으로만 진입 (터치/클릭 ≠ 편집 의도)
