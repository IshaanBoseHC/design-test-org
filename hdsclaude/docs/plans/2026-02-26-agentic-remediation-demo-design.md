# HCP Terraform Agentic Remediation Demo - Design Document

**Date**: 2026-02-26
**Status**: Approved
**Author**: Claude Code with User

## Executive Summary

A frontend-only Ember.js demo showcasing an AI-powered Terraform remediation workflow within HCP Terraform's UI. The demo simulates detecting infrastructure issues (drift, compliance violations, version upgrades) and AI-generated fixes with streaming agent logs.

**Scope**: Lightweight, production-quality demo with minimal architecture suitable for showcasing the concept.

## Context

This demo serves as a proof-of-concept for the "Agentic Workflows" feature set in HCP Terraform, providing a realistic UI experience without backend implementation. Based on internal design notes, this aligns with:

- Private beta Q2 goals
- Settings page at project/workspace level
- PR snapshot impact analysis concepts
- Agent log visibility (leveraging existing agent pool UI patterns)

## Design Decisions

### Deployment Model
**Decision**: Standalone Ember app running via `ember serve`
**Rationale**: Easy to demo, share, and potentially deploy to static hosting. No dependencies on existing codebases.

### UI Context
**Decision**: Simulate full HCP Terraform product UI with AppHeader and AppSideNav
**Rationale**: Creates authentic product experience. "Agentic Workflows" appears as a first-class navigation section.

### Issue Types Covered
**Decision**: Focus on three categories:
1. Drift detection (infrastructure changed outside Terraform)
2. Compliance violations (missing tags, wrong configs)
3. Provider/module version upgrades

**Rationale**: Covers the most common remediation scenarios without overwhelming the demo.

### Agent Simulation Depth
**Decision**: Full streaming logs with progress states
**Rationale**: Most realistic demonstration of AI agent thinking process. Critical for showcasing the "agentic" nature of the workflow.

## Architecture

### High-Level Structure

```
Service-Driven Architecture (Lightweight)

app/
├── services/
│   └── remediation.js          # Single service - all mock data & state
├── routes/
│   ├── index.js                # Redirect to remediation
│   └── remediation/
│       ├── index.js            # Dashboard (issues list)
│       └── detail.js           # Issue detail + fix flow
├── components/
│   ├── app-layout.js           # AppFrame wrapper (reusable)
│   ├── issue-card.js           # Issue preview card
│   ├── plan-diff.js            # Code diff viewer
│   └── agent-log.js            # Streaming log display
└── templates/
    └── (corresponding .hbs files)
```

### Key Principles
- **Single service**: One `remediation` service handles all data and simulation logic
- **No Ember Data**: Direct service interaction for simplicity
- **Two routes**: Dashboard + detail view only
- **Four components**: Minimal, purpose-built components
- **No persistence**: State resets on refresh (acceptable for demo)

### Out of Scope
- Settings pages
- User management
- Multiple workspaces/projects (hardcoded to one context)
- Real API integration
- Workflow history page
- Authentication

## Data Flow

```
Service (mock data) → Route model() → Template → Component @args
                              ↓
User action → Component @onClick → Route action → Service method
                                                      ↓
                                    Service updates @tracked state
                                                      ↓
                                    Template auto-updates via reactivity
```

### Service API

```javascript
class RemediationService {
  @tracked issues = [/* mock data */];

  getIssues()
  getIssue(id)
  async applyRemediation(issueId)  // Simulates streaming with setTimeout
  acceptFix(issueId)
  rejectFix(issueId)
}
```

## Data Structure

### Issue Object

```javascript
{
  id: '1',
  severity: 'high', // 'critical' | 'high' | 'medium' | 'low'
  type: 'drift', // 'drift' | 'compliance' | 'version-upgrade'
  resourceType: 'aws_security_group',
  resourceAddress: 'module.networking.aws_security_group.web',
  title: 'Security group allows unrestricted inbound access',
  description: 'Resource modified outside Terraform...',
  detectedAt: '2026-02-26T10:30:00Z',

  // AI-generated remediation
  suggestedFix: '/* HCL code string */',
  planDiff: '/* Terraform plan output string */',

  // Agent execution
  agentLogs: [
    { timestamp: '10:30:15', message: 'Analyzing drift...' },
    { timestamp: '10:30:18', message: 'Generating remediation...' }
  ],

  status: 'pending', // 'pending' | 'accepted' | 'rejected' | 'applying' | 'applied'
  workspace: 'prod-infrastructure'
}
```

### Mock Data Set (5-6 issues)

1. **Drift**: Security group modified manually (high severity)
2. **Compliance**: Missing required tags (medium severity)
3. **Version upgrade**: AWS provider outdated (low severity)
4. **Drift**: S3 bucket deleted outside Terraform (critical severity)
5. **Compliance**: EC2 instance wrong type (medium severity)

## Component Specifications

### 1. app-layout.js (Glimmer component)
- Wraps all pages in `<Hds::AppFrame>`
- Renders `<Hds::AppHeader>` with org/project context
- Renders `<Hds::AppSideNav>` with "Agentic Workflows" section
- Yields to block for page content

### 2. issue-card.js
- Receives `@issue` arg
- Uses `<Hds::Card>` wrapper
- Displays `<Hds::Badge>` for severity
- Shows resource type/address
- Primary button: "View Remediation"

### 3. plan-diff.js
- Receives `@planDiff` string (HCL code)
- Uses `<Hds::CodeBlock language="hcl">`
- Syntax highlighting via Prism
- Optional copy button (`<Hds::Button>` icon-only)

### 4. agent-log.js
- Receives `@logs` array
- Simple list rendering with timestamps
- Uses `<Hds::Text>` for formatting
- Auto-scrolls to bottom via `{{did-insert}}` modifier

## Helios Components Used

- **AppFrame** - Top-level layout
- **AppHeader** - Global navigation
- **AppSideNav** - Section navigation
- **Card** - Issue cards
- **Badge** - Severity indicators
- **Button** - Actions (Primary/Secondary/Tertiary variants)
- **CodeBlock** - HCL code display
- **Table** - Issues list
- **Tabs** - Detail view sections
- **Alert** - Success/error feedback
- **Text** - Typography
- **Icon** - Flight Icons library

## User Flows

### Dashboard Flow
1. User lands on `/remediation`
2. Sees table of detected issues
3. Each row shows: severity badge, type, resource, detected time, "View" button
4. Clicks "View" → navigates to detail page

### Remediation Flow
1. User on `/remediation/:id`
2. Sees issue summary (title, severity, resource)
3. Tabs: "Suggested Fix" | "Plan Diff" | "Agent Log"
4. Default tab: "Suggested Fix" (HCL code)
5. Actions available:
   - **Accept Fix** (Secondary) → marks issue as accepted
   - **Reject** (Secondary) → marks as rejected
   - **Apply Remediation** (Primary, enabled after accept) → triggers agent
6. When "Apply" clicked:
   - Button shows loading spinner
   - Status changes to "Applying"
   - Agent Log tab auto-selected
   - Logs stream in over 3-4 seconds
   - Success Alert appears: "Remediation applied successfully"
   - Button disabled, shows "Applied"

## UI Layout Wireframes

### Dashboard Page

```
┌─────────────────────────────────────────────────────────────┐
│ [HCP Terraform Header - org: demo-org, project: prod]      │
├───────┬─────────────────────────────────────────────────────┤
│ Side  │ PAGE HEADER                                         │
│ Nav:  │ Terraform Remediation                               │
│       │ 5 issues detected across prod-infrastructure        │
│ • Overview│                                                 │
│ • Workspaces                                                │
│ • Registry                                                  │
│ • Settings                                                  │
│ ▼ Agentic Workflows ←                                       │
│   • Remediation                                             │
│       │                                                     │
│       │ TABLE: Issues                                       │
│       │ ┌────────────────────────────────────────────────┐ │
│       │ │[Severity][Type][Resource][Detected][Action]   │ │
│       │ │ High    Drift  aws_sg... 2h ago    [View]     │ │
│       │ │ Medium  Comp.  aws_ec2.. 5h ago    [View]     │ │
│       │ │ Low     Version tf-aws.. 1d ago    [View]     │ │
│       │ └────────────────────────────────────────────────┘ │
└───────┴─────────────────────────────────────────────────────┘
```

### Detail Page

```
┌─────────────────────────────────────────────────────────────┐
│ [Header]                                                    │
├───────┬─────────────────────────────────────────────────────┤
│ Nav   │ [Breadcrumb: Remediation > Issue #1]               │
│       │                                                     │
│       │ Security group allows unrestricted inbound access   │
│       │ 🔴 High severity • aws_security_group.web          │
│       │                                                     │
│       │ ┌─────────────────────────────────────────────┐   │
│       │ │[Suggested Fix][Plan Diff][Agent Log]        │   │
│       │ ├─────────────────────────────────────────────┤   │
│       │ │                                             │   │
│       │ │ resource "aws_security_group" "web" {       │   │
│       │ │   ingress {                                 │   │
│       │ │ -   cidr_blocks = ["0.0.0.0/0"]            │   │
│       │ │ +   cidr_blocks = ["10.0.0.0/8"]           │   │
│       │ │   }                                         │   │
│       │ │ }                                           │   │
│       │ │                                             │   │
│       │ └─────────────────────────────────────────────┘   │
│       │                                                     │
│       │ [Accept Fix] [Reject] [Apply Remediation]          │
│       │  Secondary   Secondary  Primary                    │
└───────┴─────────────────────────────────────────────────────┘
```

## Helios Design Patterns Applied

- **Button Organization**: Primary action (Apply) on right, secondary (Accept/Reject) on left
- **Form Patterns**: Clear action hierarchy with button variants
- **Filter Patterns**: Not needed for MVP (table shows all issues)
- **Table Multi-select**: Not needed for MVP (single-issue actions only)
- **Show/Hide/Disable**: Apply button disabled until user accepts fix
- **Data Visualization**: Severity badges use semantic colors

## Technical Details

### Routing

```javascript
// app/router.js
Router.map(function() {
  this.route('remediation', function() {
    this.route('detail', { path: '/:issue_id' });
  });
});
```

### State Management

- Service holds `@tracked issues` array
- `applyRemediation()` simulates async work:
  1. Updates issue `status` to 'applying'
  2. Pushes log entries to `agentLogs` array over time (setTimeout)
  3. After 3-4 seconds, updates `status` to 'applied'
- All state changes trigger reactive template updates

### Streaming Log Simulation

```javascript
async applyRemediation(issueId) {
  const issue = this.getIssue(issueId);
  issue.status = 'applying';

  await this._addLog(issue, 'Validating configuration...');
  await this._delay(800);
  await this._addLog(issue, 'Running terraform plan...');
  await this._delay(1200);
  await this._addLog(issue, 'Applying changes...');
  await this._delay(1000);
  await this._addLog(issue, '✓ Remediation complete');

  issue.status = 'applied';
}

_addLog(issue, message) {
  issue.agentLogs.push({
    timestamp: new Date().toLocaleTimeString(),
    message
  });
}

_delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
```

## Styling Strategy

- Use Helios design tokens exclusively (no custom CSS unless necessary)
- Leverage Helios spacing utilities
- Use Helios typography tokens
- Apply Helios color tokens for semantic meaning
- Minimal custom styling (layout only where AppFrame insufficient)

## Testing Strategy (Out of Scope for Demo)

For a production implementation, we would include:
- Component integration tests
- Route unit tests
- Service state management tests
- Accessibility testing

For demo purposes: Manual QA only.

## Deployment Instructions

1. Install dependencies: `pnpm install`
2. Run dev server: `ember serve`
3. Open browser: `http://localhost:4200/remediation`

## Future Enhancements (Not in Scope)

- Modal for editing AI-generated fixes
- Settings page for enabling/disabling agentic workflows
- Workflow history page
- Real-time collaboration (multiple users viewing same issue)
- Integration with HCP Terraform workspaces API
- Actual Terraform plan execution
- Rollback functionality
- Multi-issue bulk operations

## Success Criteria

This demo is successful if it:
1. ✅ Looks like a real HCP Terraform product feature
2. ✅ Uses Helios components correctly and idiomatically
3. ✅ Demonstrates the agentic remediation workflow clearly
4. ✅ Shows streaming agent logs convincingly
5. ✅ Runs standalone via `ember serve`
6. ✅ Can be presented to stakeholders without explanation of "what's fake"

## References

- Helios Design System: https://helios.hashicorp.design/
- HCP Terraform: https://developer.hashicorp.com/hcp/docs/terraform
- Internal Design Notes: `../ishaandoc/HashiCorp Planning and Notes/Agentic/`
- Terraform Documentation: `../ishaandoc/Terraform Documentation Reference/`

---

**Next Steps**: Create detailed implementation plan with file-by-file breakdown for parallel agent execution.
