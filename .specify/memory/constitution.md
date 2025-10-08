<!--
SYNC IMPACT REPORT
==================
Version Change: NONE → 1.0.0
Bump Type: MAJOR (Initial constitution)
Bump Rationale: First version of the Vaccine Tracker constitution defining MVP-focused principles

Modified Principles: N/A (initial version)
Added Sections:
  - Core Principles (5 principles)
  - Development Workflow
  - Technical Constraints
  - Governance

Removed Sections: N/A

Template Consistency:
  ✅ .specify/templates/plan-template.md - Updated Constitution Check section with v1.0.0 gates (lines 47-58, 227)
  ✅ .specify/templates/spec-template.md - No constitution-specific requirements needed
  ✅ .specify/templates/tasks-template.md - TDD ordering aligns with Principle III (recommended not mandatory)
  ✅ .specify/templates/agent-file-template.md - Not reviewed (optional)

Follow-up TODOs: None
-->

# Vaccine Tracker Constitution

## Core Principles

### I. Mobile-First Testing
**Every feature MUST work on actual mobile devices via local network testing.**

The system must be testable on physical phones and emulators without deployment overhead. This means:
- Development servers expose endpoints accessible via local network IP (e.g., 192.168.x.x)
- QR codes and mobile apps connect to dev machine IPs, not localhost
- Zero-config setup: automatic network detection or clear one-time IP configuration
- Both iOS and Android emulators supported
- Physical device testing prioritized for QR scanning (camera required)

*Rationale*: QR code scanning requires cameras; emulator-only testing misses critical UX and hardware integration issues. Local network testing enables rapid iteration without cloud deployments.

### II. Instant Feedback Loop
**All changes MUST reflect within seconds via hot reload and live preview.**

Developers must see results immediately:
- Hot reload for web dashboard (< 1s refresh)
- Fast Refresh for mobile apps (< 3s reload)
- QR code generation with live preview (instant visual feedback)
- Real-time data updates propagate across all connected clients
- No manual refresh or restart required during development

*Rationale*: Tight feedback loops accelerate development velocity and improve developer experience. Waiting for builds or deployments kills productivity.

### III. Core Flow Simplicity (NON-NEGOTIABLE)
**The system MUST focus exclusively on: Generate QR → Scan → View on Dashboard.**

No features outside this critical path until MVP validates the core:
- Admin generates vaccine QR code
- Recipient scans QR code with mobile app
- Dashboard displays real-time vaccination data
- Single-tenant architecture: one organization, no multi-tenancy complexity
- No user accounts, roles, or permissions in MVP
- No advanced analytics, reporting, or integrations

*Rationale*: MVP success depends on proving the core value proposition. Every non-core feature divides focus and delays validation. Complexity is the enemy of MVPs.

### IV. Free-Tier Architecture
**All infrastructure MUST run on free tiers; no paid services allowed.**

Technology choices constrained to:
- Supabase free tier (500 MB database, 50k monthly active users, 2 GB bandwidth)
- No serverless function costs beyond free tier
- Local development without cloud dependencies
- Graceful degradation if free limits approached (log warning, don't fail)

*Rationale*: MVP budget is zero. Free tiers validate product-market fit before revenue. Supabase free tier is sufficient for 100+ test users and 10k+ scans.

### V. Zero-Config Developer Experience
**Setup time from git clone to running app MUST be under 5 minutes.**

Eliminate configuration friction:
- Single command setup: `npm install && npm run dev`
- Auto-detect network IP or prompt once
- Environment variables with sensible defaults
- Database migrations auto-run on startup
- Clear error messages with fix instructions
- No manual config file editing required

*Rationale*: Configuration complexity kills momentum. Every minute spent debugging setup is a minute not building features. Developer experience is a competitive advantage.

## Development Workflow

### Test-Driven Development (Recommended)
While not mandatory for MVP speed, integration tests for the core flow are highly valuable:
- Write integration test for QR generate → scan → dashboard display
- Use test to validate end-to-end flow works on mobile + web
- Manual testing on physical devices is acceptable for camera/QR functionality

### Commit Discipline
- Commit after each working feature (not broken states)
- Descriptive messages: "feat: add QR generation", "fix: scan detection on Android"
- Push to main for MVP (no branching overhead)

### Performance Standards
- QR code generation: < 500ms
- Dashboard data refresh: < 1s
- Mobile app cold start: < 3s
- Hot reload: < 1s web, < 3s mobile

## Technical Constraints

### Technology Stack
- **Frontend Dashboard**: React/Next.js (web)
- **Mobile App**: Flutter (iOS + Android)
- **Backend**: Supabase (PostgreSQL + Realtime + Auth optional)
- **QR Library**: Platform-standard (e.g., `qrcode` for web, `mobile_scanner` for Flutter)

### Data Model (Single-Tenant MVP)
- **VaccinationRecords**: ID, vaccine name, date, recipient info, QR hash
- **Authentication**: Email/password via Supabase Auth (all users have equal permissions)
- Realtime subscriptions for dashboard updates

### Deployment (Future)
- Web dashboard: Vercel/Netlify free tier
- Mobile app: Flutter build for iOS/Android (TestFlight/APK distribution initially)
- Database: Supabase hosted free tier

## Governance

**This constitution supersedes all other development practices.**

### Amendment Process
1. Identify deviation from principles (e.g., adding paid service, multi-tenancy)
2. Document justification in Complexity Tracking section of plan.md
3. If no simpler alternative exists, amend constitution before proceeding
4. Increment version (MAJOR for principle removal, MINOR for new principle, PATCH for clarification)

### Compliance Review
- Every plan.md MUST include Constitution Check gate
- Violations must be justified in Complexity Tracking or design simplified
- Code reviews verify core flow focus (reject scope creep)

### Version Policy
- **MAJOR**: Backward-incompatible changes (remove/replace core principle)
- **MINOR**: New principle added or significant expansion
- **PATCH**: Clarifications, wording improvements, typo fixes

**Version**: 1.0.0 | **Ratified**: 2025-10-05 | **Last Amended**: 2025-10-05
