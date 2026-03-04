# Agent Logs Job Details Flyout - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a job details flyout to Agent Logs overview cards showing comprehensive job information, rules/controls applied, and related pull requests.

**Architecture:** Extend AgentLogsPageComponent with modal state management. Use HDS Modal styled as a right-side panel (600px width, full height, slide-in animation). Button in card footer triggers flyout. Content organized into: Header (fixed), Summary, Rules & Controls (grouped/expandable), and Pull Requests sections.

**Tech Stack:** Ember 6.11.0, HDS 6.0.0, Handlebars templates, CSS for custom modal positioning

---

## Task 1: Add Component State and Actions

**Files:**
- Modify: `app/components/agent-logs-page.js`

**Step 1: Add tracked state for flyout**

Add after line 7 (after `expandedRows` definition):

```javascript
@tracked selectedJob = null;
```

**Step 2: Add action to open flyout**

Add after the `isRowExpanded` action (after line 223):

```javascript
@action
openJobDetails(job) {
  this.selectedJob = job;
}

@action
closeJobDetails() {
  this.selectedJob = null;
}
```

**Step 3: Verify changes**

Check the file compiles without errors:
```bash
cd hdsproto
pnpm start
```

Expected: Dev server starts successfully, no console errors.

**Step 4: Commit**

```bash
git add app/components/agent-logs-page.js
git commit -m "feat(agent-logs): add flyout state management

Add selectedJob tracked property and open/close actions for job details flyout.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Enhance Mock Data with Flyout Fields

**Files:**
- Modify: `app/components/agent-logs-page.js:10-56`

**Step 1: Update first job object with full data**

Replace the first job object (lines 11-19) with:

```javascript
{
  id: 1,
  name: 'Security Remediation',
  scope: '12',
  scopeType: 'Workspaces',
  status: 'success',
  prs: 3,
  timestamp: 'Jan 20, 2025, 5:23 AM',
  duration: '12m 34s',
  startTime: 'Jan 20, 2025, 5:10 AM',
  endTime: 'Jan 20, 2025, 5:23 AM',
  agentId: 'terraform-remediation-001',
  totalIssuesFound: 8,
  workspacesAffected: ['prod-infrastructure', 'staging-app', 'prod-database'],
  rulesApplied: [
    {
      ruleId: 'SEC-001',
      ruleName: 'S3 Bucket Encryption Required',
      ruleDescription: 'All S3 buckets must have server-side encryption enabled to protect data at rest.',
      ruleUrl: '#',
      actions: [
        {
          workspace: 'prod-infrastructure',
          action: 'Enabled AES-256 encryption on s3-prod-data bucket',
          timestamp: 'Jan 20, 2025, 5:12 AM',
          filesModified: ['s3.tf'],
          prNumber: 342
        },
        {
          workspace: 'staging-app',
          action: 'Enabled AES-256 encryption on s3-staging-uploads bucket',
          timestamp: 'Jan 20, 2025, 5:14 AM',
          filesModified: ['storage.tf'],
          prNumber: 343
        }
      ]
    },
    {
      ruleId: 'SEC-003',
      ruleName: 'RDS Instance Encryption',
      ruleDescription: 'All RDS instances must have encryption at rest enabled using KMS keys.',
      ruleUrl: '#',
      actions: [
        {
          workspace: 'prod-database',
          action: 'Enabled KMS encryption on prod-postgres RDS instance',
          timestamp: 'Jan 20, 2025, 5:18 AM',
          filesModified: ['rds.tf', 'kms.tf'],
          prNumber: 344
        }
      ]
    },
    {
      ruleId: 'COMP-012',
      ruleName: 'Terraform Version Compliance',
      ruleDescription: 'All workspaces must use Terraform >= 1.6.0 for security patches and feature support.',
      ruleUrl: '#',
      actions: [
        {
          workspace: 'prod-infrastructure',
          action: 'Updated required_version constraint from 1.3.0 to >= 1.6.0',
          timestamp: 'Jan 20, 2025, 5:15 AM',
          filesModified: ['versions.tf'],
          prNumber: 342
        },
        {
          workspace: 'staging-app',
          action: 'Updated required_version constraint from 1.4.0 to >= 1.6.0',
          timestamp: 'Jan 20, 2025, 5:16 AM',
          filesModified: ['versions.tf'],
          prNumber: 343
        },
        {
          workspace: 'prod-database',
          action: 'Updated required_version constraint from 1.5.0 to >= 1.6.0',
          timestamp: 'Jan 20, 2025, 5:19 AM',
          filesModified: ['versions.tf'],
          prNumber: 344
        }
      ]
    }
  ],
  pullRequests: [
    {
      prNumber: 342,
      title: 'Security hardening: Enable S3 encryption and update Terraform version',
      repo: 'hashicorp/terraform-prod-infra',
      status: 'open',
      url: '#',
      workspace: 'prod-infrastructure',
      filesChanged: 3,
      rulesAddressed: ['SEC-001', 'COMP-012']
    },
    {
      prNumber: 343,
      title: 'Security hardening: Enable S3 encryption and update Terraform version',
      repo: 'hashicorp/terraform-staging-app',
      status: 'open',
      url: '#',
      workspace: 'staging-app',
      filesChanged: 3,
      rulesAddressed: ['SEC-001', 'COMP-012']
    },
    {
      prNumber: 344,
      title: 'Security hardening: Enable RDS encryption and update Terraform version',
      repo: 'hashicorp/terraform-prod-database',
      status: 'merged',
      url: '#',
      workspace: 'prod-database',
      filesChanged: 4,
      rulesAddressed: ['SEC-003', 'COMP-012']
    }
  ]
},
```

**Step 2: Update remaining job objects (keep simple)**

For jobs 2-5, just add minimal flyout fields (you can copy job 1 and change IDs, or keep them simple since they're not the focus):

```javascript
{
  id: 2,
  name: 'Compliance Check',
  scope: '8',
  scopeType: 'Workspaces',
  status: 'success',
  prs: 2,
  timestamp: 'Jan 19, 2025, 3:15 PM',
  duration: '8m 12s',
  startTime: 'Jan 19, 2025, 3:07 PM',
  endTime: 'Jan 19, 2025, 3:15 PM',
  agentId: 'terraform-remediation-002',
  totalIssuesFound: 5,
  workspacesAffected: ['dev-testing', 'qa-environment'],
  rulesApplied: [],
  pullRequests: []
},
```

(Repeat similar structure for jobs 3, 4, 5 with different values)

**Step 3: Verify data structure**

Check browser console for any errors:
```bash
pnpm start
```

Navigate to Agent Logs, check console. Expected: No errors, jobs array intact.

**Step 4: Commit**

```bash
git add app/components/agent-logs-page.js
git commit -m "feat(agent-logs): enhance mock data with flyout fields

Add duration, agent ID, rules applied, PRs, and other metadata to job objects.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Add Button to Card Footer

**Files:**
- Modify: `app/components/agent-logs-page.hbs:44-49`

**Step 1: Update footer layout to flex with space-between**

Replace the footer div (lines 44-49) with:

```handlebars
{{! Footer with timestamp and details button }}
<div style="border-top: 1px solid var(--token-color-border-primary); padding-top: 0.75rem; margin-top: 0.75rem; display: flex; justify-content: space-between; align-items: center;">
  <div style="display: flex; align-items: center; gap: 0.5rem;">
    <Hds::Icon @name="clock" @size="16" @color="var(--token-color-foreground-faint)" />
    <Hds::Text::Body @tag="span" @size="100" @color="faint">{{job.timestamp}}</Hds::Text::Body>
  </div>
  <Hds::Button
    @text=""
    @icon="arrow-right"
    @color="secondary"
    @size="small"
    @isIconOnly={{true}}
    {{on "click" (fn this.openJobDetails job)}}
    aria-label="View job details"
  />
</div>
```

**Step 2: Test button appears**

Run dev server and check:
```bash
pnpm start
```

Navigate to Agent Logs → Overview tab.
Expected: Small arrow button appears in bottom-right of each card.

**Step 3: Test button click**

Click the arrow button.
Expected: Console should log the job object or show modal opening (modal doesn't exist yet, so this might error - that's expected).

**Step 4: Commit**

```bash
git add app/components/agent-logs-page.hbs
git commit -m "feat(agent-logs): add details button to overview cards

Add icon-only arrow button in card footer to trigger job details flyout.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Create Flyout Modal Structure

**Files:**
- Modify: `app/components/agent-logs-page.hbs:111` (after closing Tabs tag)

**Step 1: Add modal after tabs (before closing div)**

Add after line 111 (after `</Hds::Tabs>`):

```handlebars
{{! Job Details Flyout }}
{{#if this.selectedJob}}
  <Hds::Modal @color="neutral" @onClose={{this.closeJobDetails}} as |M|>
    <M.Header>
      <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 1rem;">
        <div>
          <Hds::Text::Display @tag="h3" @size="300" @weight="semibold">{{this.selectedJob.name}}</Hds::Text::Display>
          <Hds::Badge @text="Success" @icon="check-circle" @color="success" @size="small" style="margin-top: 0.5rem;" />
        </div>
      </div>

      {{! Key Metrics Row }}
      <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem; margin-top: 1rem; padding: 1rem; background: var(--token-color-surface-faint); border-radius: 6px;">
        <div>
          <Hds::Text::Body @tag="div" @size="100" @color="faint">Duration</Hds::Text::Body>
          <Hds::Text::Body @tag="div" @size="200" @weight="semibold">{{this.selectedJob.duration}}</Hds::Text::Body>
        </div>
        <div>
          <Hds::Text::Body @tag="div" @size="100" @color="faint">Workspaces</Hds::Text::Body>
          <Hds::Text::Body @tag="div" @size="200" @weight="semibold">{{this.selectedJob.workspacesAffected.length}}</Hds::Text::Body>
        </div>
        <div>
          <Hds::Text::Body @tag="div" @size="100" @color="faint">Issues Found</Hds::Text::Body>
          <Hds::Text::Body @tag="div" @size="200" @weight="semibold">{{this.selectedJob.totalIssuesFound}}</Hds::Text::Body>
        </div>
        <div>
          <Hds::Text::Body @tag="div" @size="100" @color="faint">PRs Created</Hds::Text::Body>
          <Hds::Text::Body @tag="div" @size="200" @weight="semibold">{{this.selectedJob.prs}}</Hds::Text::Body>
        </div>
      </div>
    </M.Header>

    <M.Body>
      {{! Summary Section }}
      <div style="margin-bottom: 2rem;">
        <Hds::Text::Display @tag="h4" @size="200" @weight="semibold" style="margin-bottom: 1rem;">Job Summary</Hds::Text::Display>

        <div style="display: flex; flex-direction: column; gap: 0.75rem;">
          <div style="display: flex; align-items: center; gap: 0.5rem;">
            <Hds::Icon @name="cpu" @size="16" />
            <Hds::Text::Body @tag="span" @size="100" @color="faint">Agent ID:</Hds::Text::Body>
            <Hds::Text::Code @tag="span" @size="100">{{this.selectedJob.agentId}}</Hds::Text::Code>
          </div>

          <div style="display: flex; align-items: center; gap: 0.5rem;">
            <Hds::Icon @name="clock" @size="16" />
            <Hds::Text::Body @tag="span" @size="100" @color="faint">Start:</Hds::Text::Body>
            <Hds::Text::Body @tag="span" @size="100">{{this.selectedJob.startTime}}</Hds::Text::Body>
          </div>

          <div style="display: flex; align-items: center; gap: 0.5rem;">
            <Hds::Icon @name="clock" @size="16" />
            <Hds::Text::Body @tag="span" @size="100" @color="faint">End:</Hds::Text::Body>
            <Hds::Text::Body @tag="span" @size="100">{{this.selectedJob.endTime}}</Hds::Text::Body>
          </div>
        </div>

        <div style="margin-top: 1rem;">
          <Hds::Text::Body @tag="div" @size="100" @color="faint" style="margin-bottom: 0.5rem;">Affected Workspaces:</Hds::Text::Body>
          <div style="display: flex; flex-wrap: wrap; gap: 0.5rem;">
            {{#each this.selectedJob.workspacesAffected as |workspace|}}
              <Hds::Badge @text={{workspace}} @color="neutral" @size="small" />
            {{/each}}
          </div>
        </div>
      </div>

      {{! Rules & Controls Section }}
      <div style="margin-bottom: 2rem;">
        <Hds::Text::Display @tag="h4" @size="200" @weight="semibold" style="margin-bottom: 1rem;">Rules & Controls Applied</Hds::Text::Display>

        {{#each this.selectedJob.rulesApplied as |rule|}}
          <div style="border: 1px solid var(--token-color-border-primary); border-radius: 6px; margin-bottom: 1rem; padding: 1rem;">
            {{! Rule Header }}
            <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 0.75rem;">
              <div>
                <Hds::Text::Body @tag="div" @size="200" @weight="semibold">{{rule.ruleId}}: {{rule.ruleName}}</Hds::Text::Body>
                <Hds::Text::Body @tag="div" @size="100" @color="faint">{{rule.ruleDescription}}</Hds::Text::Body>
              </div>
              <Hds::Link::Standalone @icon="external-link" @iconPosition="trailing" @href={{rule.ruleUrl}} @text="Docs" @size="small" />
            </div>

            {{! Actions }}
            <div style="margin-top: 1rem; padding-top: 1rem; border-top: 1px solid var(--token-color-border-primary);">
              <Hds::Text::Body @tag="div" @size="100" @weight="semibold" @color="faint" style="margin-bottom: 0.5rem;">Actions Taken:</Hds::Text::Body>

              {{#each rule.actions as |action|}}
                <div style="margin-bottom: 1rem; padding-left: 1rem; border-left: 2px solid var(--token-color-border-strong);">
                  <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.25rem;">
                    <Hds::Icon @name="layers" @size="16" />
                    <Hds::Text::Code @tag="span" @size="100">{{action.workspace}}</Hds::Text::Code>
                  </div>

                  <Hds::Text::Body @tag="div" @size="100" style="margin-bottom: 0.25rem;">{{action.action}}</Hds::Text::Body>

                  <div style="display: flex; gap: 1rem; margin-top: 0.5rem;">
                    <div style="display: flex; align-items: center; gap: 0.25rem;">
                      <Hds::Icon @name="clock" @size="14" @color="var(--token-color-foreground-faint)" />
                      <Hds::Text::Body @tag="span" @size="100" @color="faint">{{action.timestamp}}</Hds::Text::Body>
                    </div>

                    <div style="display: flex; align-items: center; gap: 0.25rem;">
                      <Hds::Icon @name="file-text" @size="14" @color="var(--token-color-foreground-faint)" />
                      <Hds::Text::Body @tag="span" @size="100" @color="faint">{{action.filesModified.length}} files</Hds::Text::Body>
                    </div>

                    <div style="display: flex; align-items: center; gap: 0.25rem;">
                      <Hds::Icon @name="git-pull-request" @size="14" @color="var(--token-color-foreground-faint)" />
                      <Hds::Text::Body @tag="span" @size="100" @color="faint">PR #{{action.prNumber}}</Hds::Text::Body>
                    </div>
                  </div>
                </div>
              {{/each}}
            </div>
          </div>
        {{/each}}
      </div>

      {{! Pull Requests Section }}
      <div>
        <Hds::Text::Display @tag="h4" @size="200" @weight="semibold" style="margin-bottom: 1rem;">Pull Requests</Hds::Text::Display>

        {{#each this.selectedJob.pullRequests as |pr|}}
          <div style="border: 1px solid var(--token-color-border-primary); border-radius: 6px; padding: 1rem; margin-bottom: 1rem;">
            <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 0.75rem;">
              <div style="flex: 1;">
                <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.25rem;">
                  <Hds::Text::Body @tag="span" @size="200" @weight="semibold">PR #{{pr.prNumber}}</Hds::Text::Body>
                  {{#if (eq pr.status "open")}}
                    <Hds::Badge @text="Open" @color="highlight" @size="small" />
                  {{else if (eq pr.status "merged")}}
                    <Hds::Badge @text="Merged" @color="success" @size="small" />
                  {{else}}
                    <Hds::Badge @text="Closed" @color="neutral" @size="small" />
                  {{/if}}
                </div>
                <Hds::Text::Body @tag="div" @size="100">{{pr.title}}</Hds::Text::Body>
              </div>
              <Hds::Link::Standalone @icon="external-link" @iconPosition="trailing" @href={{pr.url}} @text="View" @size="small" />
            </div>

            <div style="display: flex; gap: 1rem; flex-wrap: wrap; margin-top: 0.75rem;">
              <div style="display: flex; align-items: center; gap: 0.25rem;">
                <Hds::Icon @name="folder" @size="14" @color="var(--token-color-foreground-faint)" />
                <Hds::Text::Code @tag="span" @size="100">{{pr.repo}}</Hds::Text::Code>
              </div>

              <div style="display: flex; align-items: center; gap: 0.25rem;">
                <Hds::Icon @name="layers" @size="14" @color="var(--token-color-foreground-faint)" />
                <Hds::Text::Body @tag="span" @size="100" @color="faint">{{pr.workspace}}</Hds::Text::Body>
              </div>

              <div style="display: flex; align-items: center; gap: 0.25rem;">
                <Hds::Icon @name="file-text" @size="14" @color="var(--token-color-foreground-faint)" />
                <Hds::Text::Body @tag="span" @size="100" @color="faint">{{pr.filesChanged}} files changed</Hds::Text::Body>
              </div>
            </div>

            <div style="margin-top: 0.75rem;">
              <Hds::Text::Body @tag="div" @size="100" @color="faint" style="margin-bottom: 0.25rem;">Rules Addressed:</Hds::Text::Body>
              <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
                {{#each pr.rulesAddressed as |ruleId|}}
                  <Hds::Badge @text={{ruleId}} @color="neutral" @size="small" />
                {{/each}}
              </div>
            </div>
          </div>
        {{/each}}
      </div>
    </M.Body>

    <M.Footer>
      <Hds::Button @text="Close" @color="secondary" {{on "click" this.closeJobDetails}} />
    </M.Footer>
  </Hds::Modal>
{{/if}}
```

**Step 2: Test modal opens**

Run dev server:
```bash
pnpm start
```

Navigate to Agent Logs → Overview, click arrow button on first card.
Expected: Modal appears with job details content.

**Step 3: Test modal closes**

Click backdrop, ESC key, or Close button.
Expected: Modal dismisses, selectedJob set to null.

**Step 4: Commit**

```bash
git add app/components/agent-logs-page.hbs
git commit -m "feat(agent-logs): add job details flyout modal

Add comprehensive flyout showing job summary, rules/controls applied, and PRs.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Style Modal as Right-Side Panel

**Files:**
- Create: `app/components/agent-logs-page.scss`

**Step 1: Create component stylesheet**

Create new file:

```scss
// Right-side flyout modal styling
:global(.job-details-flyout) {
  .hds-modal {
    // Override default center positioning
    align-items: flex-start;
    justify-content: flex-end;
  }

  .hds-modal__content {
    position: fixed;
    right: 0;
    top: 0;
    height: 100vh;
    width: 600px;
    max-width: 90vw;
    margin: 0;
    border-radius: 0;

    // Slide-in animation
    animation: slideInRight 250ms ease-out;
  }

  .hds-modal__header,
  .hds-modal__footer {
    padding: 1.5rem;
  }

  .hds-modal__body {
    padding: 0 1.5rem 1.5rem;
    overflow-y: auto;
  }
}

@keyframes slideInRight {
  from {
    transform: translateX(100%);
  }
  to {
    transform: translateX(0);
  }
}
```

**Step 2: Add class to modal in template**

Modify the modal opening tag in `app/components/agent-logs-page.hbs`:

Change:
```handlebars
<Hds::Modal @color="neutral" @onClose={{this.closeJobDetails}} as |M|>
```

To:
```handlebars
<Hds::Modal @color="neutral" @onClose={{this.closeJobDetails}} class="job-details-flyout" as |M|>
```

**Step 3: Import stylesheet in component**

If HDS uses CSS modules or you need to import, add import to `app/components/agent-logs-page.js`:

```javascript
import './agent-logs-page.scss';
```

(Add after other imports at top of file)

**Step 4: Test slide-in animation**

Run dev server and test:
```bash
pnpm start
```

Open modal - should slide in from right, 600px wide.
Expected: Modal positioned on right edge, full height, smooth slide animation.

**Step 5: Commit**

```bash
git add app/components/agent-logs-page.scss app/components/agent-logs-page.hbs app/components/agent-logs-page.js
git commit -m "style(agent-logs): add right-side panel styling to flyout

Position modal as right-side panel with slide-in animation.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Final Integration Testing

**Files:**
- None (manual testing)

**Step 1: Test full user flow**

```bash
cd hdsproto
pnpm start
```

Navigate to Agent Logs → Overview tab.

Test checklist:
- [ ] All cards display arrow button in bottom-right
- [ ] Clicking arrow opens flyout from right
- [ ] Flyout shows correct job name and badge
- [ ] Key metrics display (duration, workspaces, issues, PRs)
- [ ] Job summary section shows agent ID, times, workspace badges
- [ ] Rules & Controls section shows all rules with actions
- [ ] Each rule has external link icon
- [ ] Pull Requests section lists all PRs with badges
- [ ] PR external links present
- [ ] Close button, backdrop click, and ESC key all close modal
- [ ] Modal has smooth slide-in/out animation
- [ ] Can open different job cards and see their specific data

**Step 2: Cross-browser check (optional)**

Test in Chrome, Firefox, Safari if available.
Expected: Consistent behavior across browsers.

**Step 3: Accessibility check**

- [ ] Tab navigation works through modal content
- [ ] ESC key closes modal
- [ ] Focus trap works (tab doesn't escape modal)
- [ ] Close button has proper aria-label
- [ ] Screen reader can announce modal opening

**Step 4: Document any issues**

If issues found, create GitHub issues or note for follow-up.

**Step 5: Final commit (if any fixes made)**

```bash
git add .
git commit -m "fix(agent-logs): address integration issues in flyout

[Describe any fixes made during testing]

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Update Remaining Mock Jobs (Optional Polish)

**Files:**
- Modify: `app/components/agent-logs-page.js:60-95` (jobs 2-5)

**Step 1: Add realistic data to jobs 2-5**

For each remaining job, add similar structure to job 1 but with different:
- Duration times
- Agent IDs
- Rules/controls
- PRs
- Workspaces

Example for job 2:

```javascript
{
  id: 2,
  name: 'Provider Version Update',
  scope: '8',
  scopeType: 'Workspaces',
  status: 'success',
  prs: 2,
  timestamp: 'Jan 19, 2025, 3:15 PM',
  duration: '8m 12s',
  startTime: 'Jan 19, 2025, 3:07 PM',
  endTime: 'Jan 19, 2025, 3:15 PM',
  agentId: 'terraform-remediation-002',
  totalIssuesFound: 5,
  workspacesAffected: ['dev-testing', 'qa-environment'],
  rulesApplied: [
    {
      ruleId: 'DEP-004',
      ruleName: 'AWS Provider Version',
      ruleDescription: 'AWS provider must be >= 5.0 for latest security patches.',
      ruleUrl: '#',
      actions: [
        {
          workspace: 'dev-testing',
          action: 'Updated AWS provider from 4.67.0 to 5.31.0',
          timestamp: 'Jan 19, 2025, 3:10 AM',
          filesModified: ['versions.tf', 'providers.tf'],
          prNumber: 340
        }
      ]
    }
  ],
  pullRequests: [
    {
      prNumber: 340,
      title: 'Update AWS provider to v5.31.0',
      repo: 'hashicorp/terraform-dev-testing',
      status: 'merged',
      url: '#',
      workspace: 'dev-testing',
      filesChanged: 2,
      rulesAddressed: ['DEP-004']
    }
  ]
},
```

Repeat similar approach for jobs 3, 4, 5.

**Step 2: Test variety**

Open different job cards, verify data shows correctly.

**Step 3: Commit**

```bash
git add app/components/agent-logs-page.js
git commit -m "feat(agent-logs): complete mock data for all jobs

Add realistic flyout data to jobs 2-5 for testing variety.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Completion Checklist

- [ ] Component state management added
- [ ] Mock data enhanced with flyout fields
- [ ] Button added to card footers
- [ ] Modal structure created with all sections
- [ ] Right-side panel styling applied
- [ ] Slide-in animation working
- [ ] Integration testing passed
- [ ] Accessibility verified
- [ ] All commits pushed

## Next Steps

Once implementation complete:
- Replace mock data with real API calls
- Add loading states during data fetch
- Add error handling for failed API requests
- Implement accordion collapse/expand for rules
- Add internal navigation (PR links to rules, rule links to PRs)
- Consider adding filters/search within flyout

---

**Implementation Status:** Ready for execution
**Estimated Time:** 45-60 minutes
**Complexity:** Medium (UI-focused, some CSS customization required)
