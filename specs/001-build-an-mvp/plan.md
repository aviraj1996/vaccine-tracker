# Implementation Plan: MVP Vaccine Tracking System

**Branch**: `001-build-an-mvp` | **Date**: 2025-10-05 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/Users/aviraj/vaccine-tracker/specs/001-build-an-mvp/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code, or `AGENTS.md` for all other agents).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Build an MVP vaccine tracking system with three core components: web-based QR generator, Flutter mobile scanner app, and Next.js real-time dashboard. The system enables generating GS1-formatted vaccine QR codes, scanning them with mobile devices via camera, and viewing scan events in real-time. All components communicate through Supabase real-time backend and must be testable on actual mobile devices via local network connection.

## Technical Context
**Language/Version**: TypeScript/JavaScript (Next.js 14+), Dart 3.x (Flutter)
**Primary Dependencies**: Next.js, Flutter SDK, qrcode.js, mobile_scanner (Flutter), Supabase JS SDK
**Storage**: Supabase PostgreSQL (free tier: 500MB database, 2GB bandwidth)
**Testing**: Jest for web components, Flutter test framework, manual testing on physical devices
**Target Platform**: Web (Chrome/Safari), iOS 12+, Android 8+
**Project Type**: mobile (Flutter app + Next.js web)
**Performance Goals**: QR generation < 500ms, dashboard refresh < 1s, mobile app cold start < 3s, hot reload < 1s web / < 3s mobile
**Constraints**: Free-tier only (Supabase free tier), local network testing, single-tenant, no offline support
**Scale/Scope**: MVP scope - 100+ test users, 10k+ scans, 3 screens (QR generator, mobile scanner, dashboard)

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Verify compliance with [Vaccine Tracker Constitution v1.0.0](../../.specify/memory/constitution.md):

- [x] **Mobile-First Testing**: Feature testable on physical devices via local network? ✅ YES - Flutter app + Next.js web accessible via local IP, supports both emulators and physical devices
- [x] **Instant Feedback Loop**: Hot reload preserved? Real-time updates working? ✅ YES - Next.js hot reload, Flutter Fast Refresh, Supabase real-time subscriptions for instant updates
- [x] **Core Flow Simplicity**: Does this add to Generate QR → Scan → Dashboard? If no, reject. ✅ YES - This IS the core flow, no extra features
- [x] **Free-Tier Architecture**: Stays within Supabase free tier limits? ✅ YES - 500MB DB and 2GB bandwidth sufficient for MVP (100+ users, 10k+ scans)
- [x] **Zero-Config DX**: No new manual configuration required? ✅ YES - Auto-detect network IP or single prompt, npm install && npm run dev

*Initial Constitution Check: PASS - All principles satisfied, no violations to document.*

## Project Structure

### Documentation (this feature)
```
specs/001-build-an-mvp/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
web/                          # Next.js web application (QR Generator + Dashboard)
├── app/
│   ├── page.tsx             # Dashboard (real-time scan feed)
│   ├── generate/
│   │   └── page.tsx         # QR Generator page
│   ├── api/
│   │   └── qr/
│   │       └── route.ts     # API route for QR generation
│   └── layout.tsx
├── components/
│   ├── QRGenerator.tsx      # QR generation form with live preview
│   ├── ScanFeed.tsx         # Real-time scan feed component
│   └── QRTable.tsx          # Recent QR codes table
├── lib/
│   ├── supabase.ts          # Supabase client setup
│   └── gs1-encoder.ts       # GS1 format encoder
├── package.json
└── next.config.js

mobile/                       # Flutter mobile application
├── lib/
│   ├── main.dart            # App entry point
│   ├── screens/
│   │   ├── login_screen.dart
│   │   └── scanner_screen.dart
│   ├── services/
│   │   ├── supabase_service.dart
│   │   └── scan_service.dart
│   ├── models/
│   │   ├── qr_code.dart
│   │   └── scan_event.dart
│   └── widgets/
│       ├── qr_scanner.dart
│       └── scan_list.dart
├── pubspec.yaml
└── android/ & ios/          # Platform-specific configs

supabase/
├── migrations/
│   └── 001_initial_schema.sql
└── seed.sql                  # Test data for development

tests/
├── web/
│   ├── integration/
│   │   └── qr_generation.test.ts
│   └── unit/
│       └── gs1_encoder.test.ts
└── mobile/
    └── test/
        └── widget_test.dart
```

**Structure Decision**: Mobile + Web architecture selected. This is a mobile-first application requiring both a Flutter mobile app (for camera-based QR scanning) and a Next.js web application (for QR generation and dashboard). Supabase serves as the shared backend with real-time capabilities. All components connect via local network during development.

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh claude`
     **IMPORTANT**: Execute it exactly as specified above. Do not add or remove any arguments.
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Each API endpoint → contract test task [P]
- Each entity (QRCode, ScanEvent) → model/type definition task [P]
- Each user story → integration test task
- Implementation tasks to make tests pass
- Setup tasks for project initialization (web + mobile)

**Specific Task Breakdown**:

1. **Setup Tasks** (3 tasks):
   - Initialize Next.js project with TypeScript, Tailwind
   - Initialize Flutter project with Supabase SDK
   - Create Supabase schema and seed data

2. **Web Component Tasks** (8-10 tasks):
   - GS1 encoder utility (TypeScript)
   - QR Generator component with live preview
   - Dashboard with real-time Supabase subscription
   - API routes: `/api/qr/generate`, `/api/scan`, `/api/scans/recent`
   - Supabase client setup and types

3. **Mobile App Tasks** (6-8 tasks):
   - Login screen (simple email input)
   - Scanner screen with mobile_scanner integration
   - GS1 parser for scanned data
   - Supabase service layer
   - Scan event recording
   - Last 5 scans list widget

4. **Integration Tasks** (3-4 tasks):
   - Connect web app to Supabase
   - Connect mobile app to local network IP
   - Real-time subscription setup (dashboard)
   - Network configuration helper (auto-detect IP)

5. **Testing Tasks** (4-5 tasks):
   - Integration test: Generate QR → Scan → Dashboard
   - Unit test: GS1 encoder
   - Manual testing on physical device (quickstart validation)

**Ordering Strategy**:
- Database schema first (blocks all other tasks)
- Web and mobile can be parallel [P] after schema
- GS1 encoder before QR generator
- Supabase client before API routes
- Integration tests last (require all components)

**Estimated Output**: ~30 numbered, ordered tasks in tasks.md

**Parallel Execution Opportunities**:
- Web app and mobile app development (independent after schema)
- Individual API routes (different files)
- Component development within each platform

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command) - research.md generated
- [x] Phase 1: Design complete (/plan command) - data-model.md, contracts/, quickstart.md, CLAUDE.md created
- [x] Phase 2: Task planning complete (/plan command - describe approach only) - See Phase 2 section below
- [ ] Phase 3: Tasks generated (/tasks command) - Ready to execute
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS - All 5 principles satisfied
- [x] Post-Design Constitution Check: PASS - No new violations introduced
- [x] All NEEDS CLARIFICATION resolved - No unknowns in Technical Context
- [x] Complexity deviations documented - None (no violations)

**Artifacts Generated**:
- ✅ `/specs/001-build-an-mvp/plan.md` (this file)
- ✅ `/specs/001-build-an-mvp/research.md` (10 technology decisions documented)
- ✅ `/specs/001-build-an-mvp/data-model.md` (2 entities, query patterns, migration)
- ✅ `/specs/001-build-an-mvp/contracts/api-spec.yaml` (OpenAPI 3.0 spec, 7 endpoints)
- ✅ `/specs/001-build-an-mvp/quickstart.md` (5 test scenarios, performance benchmarks)
- ✅ `/CLAUDE.md` (Agent context file updated with tech stack)

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
