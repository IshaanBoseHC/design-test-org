# Agent Logs Job Details Flyout - Design Document

**Date:** March 4, 2026
**Author:** Design Session
**Status:** Approved

## Overview

Add a job details flyout to the Agent Logs overview cards that provides comprehensive transparency into remediation jobs. Users will see what the agent did, why it took those actions (rules/controls), and access to related pull requests.

## Problem Statement

The current overview cards show only basic job summary information (scope, PR count, timestamp). Users need deeper visibility into:
- What specific actions the agent took
- Which security rules or controls triggered those actions
- Links to documentation explaining why rules exist
- Detailed PR information and status
- Complete job metadata and timeline

## User Goals

1. Understand why the agent made specific changes
2. Trace actions back to the security controls that triggered them
3. Quickly access PRs and external documentation
4. Review job execution details and metadata

## Solution

### 1. Architecture

**Component Structure:**
- Enhance `AgentLogsPageComponent` with:
  - `@tracked selectedJob = null` - tracks currently viewed job
  - `@action openJobDetails(job)` - opens flyout with job data
  - `@action closeJobDetails()` - closes flyout

**Button Integration:**
- Small, secondary, icon-only button with `arrow-right` icon
- Positioned in bottom-right of each overview card footer
- Uses `justify-content: space-between` layout with timestamp

**Modal Implementation:**
- Uses `Hds::Modal` component configured as right-side panel
- Full-height (100vh), fixed width (600px)
- Conditional rendering: shown when `selectedJob` is not null
- Backdrop click or close button sets `selectedJob = null`

### 2. Data Model

Enhanced job objects include:

```javascript
{
  // Existing fields
  id: 1,
  name: 'Remediation',
  scope: '12',
  scopeType: 'Workspaces',
  status: 'success',
  prs: 3,
  timestamp: 'Jan 20, 2025, 5:23 AM',

  // New fields for flyout
  duration: '12m 34s',
  startTime: 'Jan 20, 2025, 5:10 AM',
  endTime: 'Jan 20, 2025, 5:23 AM',
  agentId: 'terraform-remediation-001',
  totalIssuesFound: 8,
  workspacesAffected: ['prod-infrastructure', 'staging-app'],

  // Rules/controls structure
  rulesApplied: [
    {
      ruleId: 'SEC-001',
      ruleName: 'S3 Bucket Encryption Required',
      ruleDescription: 'All S3 buckets must have encryption enabled',
      ruleUrl: '#', // Empty href placeholder
      actions: [
        {
          workspace: 'prod-infrastructure',
          action: 'Enabled AES-256 encryption on s3-prod-data bucket',
          timestamp: 'Jan 20, 2025, 5:12 AM',
          filesModified: ['s3.tf'],
          prNumber: 342
        }
      ]
    }
  ],

  // Pull requests
  pullRequests: [
    {
      prNumber: 342,
      title: 'Enable S3 encryption for prod-data bucket',
      repo: 'org/terraform-infra',
      status: 'open',
      url: '#',
      workspace: 'prod-infrastructure',
      filesChanged: 2,
      rulesAddressed: ['SEC-001']
    }
  ]
}
```

**Design Rationale:** Grouping actions by rule/control makes the "why" immediately clear. PRs reference which rules they address, enabling bidirectional navigation.

### 3. Content Layout

The flyout is organized into four sections:

#### Header (Fixed)
- Job name with status badge
- Close button (icon-only, top-right)
- Key metrics row:
  - Duration
  - Workspaces affected
  - Issues found
  - PRs created

#### Summary Section (Scrollable)
- Agent ID (code-formatted)
- Start and end times with duration
- List of affected workspaces as badges/tags

#### Rules & Controls Section (Primary Content)
Grouped by rule/control with expandable sections:

**Each rule header shows:**
- Rule ID and name (e.g., "SEC-001: S3 Bucket Encryption Required")
- External link icon to documentation (using `Hds::Link::Standalone` with `@href="#"`)
- Rule description

**Expanded section shows actions:**
- Workspace name (with icon)
- What was done (action description)
- Timestamp
- Files modified
- Associated PR number (clickable, jumps to PR section)

Uses `Hds::Accordion` or similar for expand/collapse functionality.

#### Pull Requests Section
List of PRs created during this job:

- PR number and title
- Repository and workspace
- Status badge (open/merged/closed)
- Files changed count
- Rules addressed (clickable, jumps back to rule sections)
- External link to GitHub/VCS (with `@href="#"`)

### 4. Styling & Animation

**Modal Positioning:**
- Override HDS Modal default centering
- Position: fixed right, full height
- Width: 600px
- Deep box shadow for elevation
- White background using HDS tokens

**Slide Animation:**
- Entry: `transform: translateX(100%)` → `translateX(0)`
- Exit: reverse slide to right
- Duration: 250ms, ease-out timing
- Backdrop fades in/out simultaneously

**Accordion Behavior:**
- Default state: all rules collapsed
- Smooth height transition on expand/collapse
- Chevron icon indicates state
- Only one rule needs to be open at a time (user choice)

**Spacing & Typography:**
- Header: 1.5rem padding, larger text
- Section headers: HDS Display components
- Content: 1.5rem horizontal, 1rem vertical between sections
- Consistent HDS text hierarchy (Display → Body → Code)

**Scrolling:**
- Fixed header stays visible
- Content area independently scrollable
- Standard browser scrollbar

### 5. Component Interactions

**Opening the flyout:**
1. User clicks arrow button in card footer
2. `openJobDetails(job)` action fires
3. `selectedJob` is set to clicked job
4. Modal renders and animates in
5. Backdrop appears

**Closing the flyout:**
1. User clicks backdrop, close button, or ESC key
2. `closeJobDetails()` action fires
3. `selectedJob` set to null
4. Modal animates out and unmounts

**Navigation within flyout:**
- PR number links scroll to PR section
- Rule ID links in PR section scroll back to rule
- External links open in new tabs

### 6. Implementation Notes

**HDS Components Used:**
- `Hds::Modal` - flyout container
- `Hds::Button` - trigger button and close button
- `Hds::Badge` - status indicators and workspace tags
- `Hds::Text::Display` - section headers
- `Hds::Text::Body` - body text
- `Hds::Text::Code` - agent IDs, file names
- `Hds::Link::Standalone` - external links with icons
- `Hds::Icon` - various contextual icons
- `Hds::Accordion` (or similar) - expandable rule sections

**Accessibility:**
- Modal handles focus trap automatically via HDS
- Close button has proper aria-label
- Keyboard navigation: ESC to close, Tab through interactive elements
- Screen reader announcements for modal open/close

**Performance:**
- Modal content only renders when `selectedJob` exists
- No watchers or computed properties needed
- Simple tracked property reactivity

## Future Enhancements

- Real-time job status updates within open flyout
- Filter/search within rules and PRs
- Export job details as JSON or PDF
- Link to detailed logs view filtered to this job
- Inline PR diff preview

## Success Metrics

- Users can understand why changes were made
- Clear path from action → rule → documentation
- Easy navigation to related PRs
- Reduced support questions about agent behavior

## Open Questions

None - design approved for implementation.
