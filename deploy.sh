#!/usr/bin/env bash
# deploy.sh - GitHub Pages 배포 스크립트
# 사용법: bash deploy.sh [repo-name]
# 예시:   bash deploy.sh family-med-study

set -euo pipefail

# ── 설정 ──────────────────────────────────────────────
REPO_NAME="${1:-family-med-study}"
BRANCH="gh-pages"
DEPLOY_DIR="$(pwd)/_deploy"
QUESTIONS_FILE="output/questions_vol7.json"

# ── 색상 출력 ─────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

echo ""
echo "=================================================="
echo " 가정의학과 기출문제 뷰어 GitHub Pages 배포"
echo "=================================================="
echo ""

# ── 사전 확인 ─────────────────────────────────────────
command -v git  >/dev/null 2>&1 || error "git이 설치되어 있지 않습니다."
command -v gh   >/dev/null 2>&1 || error "GitHub CLI(gh)가 없습니다. https://cli.github.com 에서 설치하세요."

info "GitHub 인증 상태 확인..."
gh auth status >/dev/null 2>&1 || error "gh auth login 먼저 실행하세요."

GH_USER=$(gh api user --jq '.login' 2>/dev/null) || error "GitHub 사용자 정보를 가져올 수 없습니다."
info "GitHub 사용자: $GH_USER"

# ── questions.json 확인 ──────────────────────────────
if [[ ! -f "$QUESTIONS_FILE" ]]; then
  error "$QUESTIONS_FILE 파일이 없습니다. 먼저 process_pdf.py를 실행하세요."
fi
Q_COUNT=$(python -c "import json; d=json.load(open('$QUESTIONS_FILE')); print(len(d))" 2>/dev/null || echo "?")
info "문제 수: $Q_COUNT개"

# ── GitHub repo 생성 (없으면) ────────────────────────
info "GitHub repository 확인..."
if gh repo view "$GH_USER/$REPO_NAME" >/dev/null 2>&1; then
  warn "이미 존재하는 저장소: $GH_USER/$REPO_NAME"
else
  info "Private repository 생성: $REPO_NAME"
  gh repo create "$REPO_NAME" \
    --private \
    --description "가정의학과 전문의 기출문제 뷰어" \
    --confirm 2>/dev/null || \
  gh repo create "$GH_USER/$REPO_NAME" \
    --private \
    --description "가정의학과 전문의 기출문제 뷰어"
  success "저장소 생성 완료"
fi

# GitHub Pages는 public repo 또는 GitHub Pro 필요
# Private repo + Pages 사용하려면 Pro/Team 필요
echo ""
warn "주의: Private repo의 GitHub Pages는 GitHub Pro/Team 플랜이 필요합니다."
warn "      무료 플랜이라면 Public repo로 전환하거나 로컬 서버를 사용하세요."
echo ""

# ── 배포 디렉토리 준비 ───────────────────────────────
info "배포 파일 준비..."
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR/output"

# 필수 파일 복사
cp viewer.html "$DEPLOY_DIR/index.html"
cp "$QUESTIONS_FILE" "$DEPLOY_DIR/output/questions_vol7.json"

# .nojekyll (Jekyll 빌드 스킵)
touch "$DEPLOY_DIR/.nojekyll"

# ── Git 초기화 및 배포 ───────────────────────────────
info "gh-pages 브랜치로 배포..."

REMOTE_URL="https://github.com/$GH_USER/$REPO_NAME.git"

cd "$DEPLOY_DIR"
git init -q
git checkout -b "$BRANCH"
git add -A
git commit -m "Deploy: 가정의학과 기출문제 뷰어 (${Q_COUNT}문제)" -q

# 원격 추가 및 push
git remote add origin "$REMOTE_URL" 2>/dev/null || \
  git remote set-url origin "$REMOTE_URL"

git push origin "$BRANCH" --force -q

cd - >/dev/null

# ── GitHub Pages 활성화 ──────────────────────────────
info "GitHub Pages 설정..."
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/$GH_USER/$REPO_NAME/pages" \
  -f source='{"branch":"gh-pages","path":"/"}' \
  >/dev/null 2>&1 || \
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/$GH_USER/$REPO_NAME/pages" \
  -f source='{"branch":"gh-pages","path":"/"}' \
  >/dev/null 2>&1 || \
  warn "Pages 설정을 자동으로 할 수 없습니다. GitHub > Settings > Pages에서 수동으로 설정하세요."

# ── 정리 ─────────────────────────────────────────────
rm -rf "$DEPLOY_DIR"

echo ""
echo "=================================================="
success "배포 완료!"
echo ""
echo "  뷰어 URL: https://${GH_USER}.github.io/${REPO_NAME}/"
echo "  저장소:   https://github.com/${GH_USER}/${REPO_NAME}"
echo ""
echo "  ※ GitHub Pages 빌드에 1~3분 소요될 수 있습니다."
echo "=================================================="
echo ""
