# CLAUDE.md

## Deploy & Commit Rules
- Always commit + push after every change (app is used across mobile and other PCs via GitHub Pages)
- No exceptions, even for small changes

## App Structure
- Single file: `index.html` (CSS, HTML, JS all in one)
- Data persistence: `localStorage` synced to GitHub Gist
- Deployment: https://jackmir-explorer.github.io/study-app/
- Mobile: Capacitor native app (AnkiDroid integration)

## Constraints
- Never rewrite the entire file
- Always locate the exact edit position before making changes
- Modify only the minimum code block needed
- Never touch code outside the requested scope

## Workflow
1. Identify the file to modify
2. Locate the exact position (Grep/Read)
3. Replace only that block using Edit
4. commit + push

## Guidelines
- Prefer removing over adding — simplicity first
- Use `isNativeApp()` when behavior differs between browser and mobile native
- Verify that HTML element IDs referenced in JS actually exist in the HTML
- After critical data saves, call `gistPush()` directly instead of `schedulePush()` (2s delay)

## UX Principles
- Read mode is the default state. Edit mode only via explicit button action (touch/click ≠ intent to edit)
