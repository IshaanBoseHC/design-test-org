# HCP Terraform Agentic Remediation Demo - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a frontend-only Ember.js demo showcasing AI-powered Terraform remediation with streaming agent logs.

**Architecture:** Service-driven architecture with one `remediation` service managing mock data and state. Two routes (dashboard + detail) with four minimal Glimmer components. All UI built with Helios Design System components.

**Tech Stack:** Ember.js (Octane), Helios Design System, Glimmer components, Ember Auto-import, Prism (syntax highlighting)

---

## Pre-Implementation Setup

**Verify Environment:**
- Node.js 18+ installed
- pnpm installed (`npm install -g pnpm`)
- Ember CLI installed (`pnpm install -g ember-cli`)

---

## Task 1: Scaffold New Ember App

**Files:**
- Create: Entire Ember app structure via CLI

**Step 1: Create new Ember app**

```bash
cd /Users/ishaanbose/Documents/hdsclaude
ember new terraform-remediation-demo --pnpm
cd terraform-remediation-demo
```

Expected: New Ember app created with default structure

**Step 2: Verify app runs**

```bash
ember serve
```

Expected: Dev server starts at http://localhost:4200, shows "Congratulations" page

**Step 3: Initial commit**

```bash
git add .
git commit -m "chore: initial Ember app scaffold

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 2: Install Helios Design System

**Files:**
- Modify: `package.json`
- Modify: `ember-cli-build.js`
- Create: `app/styles/app.scss`

**Step 1: Install Helios packages**

```bash
pnpm add @hashicorp/design-system-components
pnpm add @hashicorp/flight-icons
pnpm add ember-auto-import
```

Expected: Packages added to package.json

**Step 2: Configure ember-cli-build.js**

Modify: `ember-cli-build.js`

```javascript
'use strict';

const EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function (defaults) {
  const app = new EmberApp(defaults, {
    sassOptions: {
      precision: 4,
      includePaths: [
        'node_modules/@hashicorp/design-system-tokens/dist/products/css',
        'node_modules/@hashicorp/design-system-components/dist/styles',
      ],
    },
  });

  return app.toTree();
};
```

**Step 3: Set up Sass styles**

Create: `app/styles/app.scss`

```scss
// Import Helios tokens and components
@import '@hashicorp/design-system-components';

// Helios requires box-sizing reset
*, *::before, *::after {
  box-sizing: border-box;
}

html, body {
  margin: 0;
  padding: 0;
  font-family: var(--token-typography-font-stack-text);
}
```

Rename `app/styles/app.css` to `app.scss` (if needed) and replace content

**Step 4: Verify Helios loads**

```bash
ember serve
```

Expected: App compiles without Sass errors, page has Helios typography

**Step 5: Commit**

```bash
git add .
git commit -m "feat: add Helios Design System

Install @hashicorp/design-system-components and configure Sass

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: Create Remediation Service

**Files:**
- Create: `app/services/remediation.js`

**Step 1: Generate service**

```bash
ember generate service remediation
```

**Step 2: Implement service with mock data**

Modify: `app/services/remediation.js`

```javascript
import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class RemediationService extends Service {
  @tracked issues = [
    {
      id: '1',
      severity: 'high',
      type: 'drift',
      resourceType: 'aws_security_group',
      resourceAddress: 'module.networking.aws_security_group.web',
      title: 'Security group allows unrestricted inbound access',
      description: 'Resource was modified outside Terraform. The security group now allows inbound traffic from 0.0.0.0/0 on all ports, which was not defined in the configuration.',
      detectedAt: '2026-02-26T10:30:00Z',
      suggestedFix: `resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  ingress {
-   cidr_blocks = ["0.0.0.0/0"]
+   cidr_blocks = ["10.0.0.0/8"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "web-sg"
    Environment = "production"
  }
}`,
      planDiff: `Terraform will perform the following actions:

  # module.networking.aws_security_group.web will be updated in-place
  ~ resource "aws_security_group" "web" {
        id                     = "sg-0123456789abcdef0"
        name                   = "web-sg"
      ~ ingress {
          ~ cidr_blocks = [
              - "0.0.0.0/0",
              + "10.0.0.0/8",
            ]
            from_port   = 443
            to_port     = 443
            protocol    = "tcp"
        }
        # (3 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.`,
      agentLogs: [],
      status: 'pending',
      workspace: 'prod-infrastructure',
    },
    {
      id: '2',
      severity: 'medium',
      type: 'compliance',
      resourceType: 'aws_instance',
      resourceAddress: 'aws_instance.app_server',
      title: 'EC2 instance missing required tags',
      description: 'Instance is missing required tags: Owner, CostCenter, Compliance. Organization policy requires these tags on all EC2 instances.',
      detectedAt: '2026-02-26T08:15:00Z',
      suggestedFix: `resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"
  subnet_id     = var.subnet_id

  tags = {
    Name        = "app-server-01"
    Environment = "production"
+   Owner       = "platform-team@example.com"
+   CostCenter  = "engineering"
+   Compliance  = "pci-dss"
  }
}`,
      planDiff: `Terraform will perform the following actions:

  # aws_instance.app_server will be updated in-place
  ~ resource "aws_instance" "app_server" {
        id            = "i-0123456789abcdef0"
        ami           = "ami-0c55b159cbfafe1f0"
      ~ tags          = {
            "Environment" = "production"
            "Name"        = "app-server-01"
          + "Owner"       = "platform-team@example.com"
          + "CostCenter"  = "engineering"
          + "Compliance"  = "pci-dss"
        }
        # (10 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.`,
      agentLogs: [],
      status: 'pending',
      workspace: 'prod-infrastructure',
    },
    {
      id: '3',
      severity: 'low',
      type: 'version-upgrade',
      resourceType: 'provider[registry.terraform.io/hashicorp/aws]',
      resourceAddress: 'provider configuration',
      title: 'AWS provider version outdated',
      description: 'Using AWS provider v4.67.0. Latest stable version is v5.82.0 with important security fixes and new features.',
      detectedAt: '2026-02-25T14:20:00Z',
      suggestedFix: `terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
-     version = "~> 4.67"
+     version = "~> 5.82"
    }
  }
}

provider "aws" {
  region = var.aws_region
}`,
      planDiff: `No infrastructure changes required.

This is a provider version upgrade only. After applying:
- Run 'terraform init -upgrade' to download the new provider version
- Review provider changelog for any breaking changes
- Test in non-production environment first`,
      agentLogs: [],
      status: 'pending',
      workspace: 'prod-infrastructure',
    },
    {
      id: '4',
      severity: 'critical',
      type: 'drift',
      resourceType: 'aws_s3_bucket',
      resourceAddress: 'aws_s3_bucket.data_lake',
      title: 'S3 bucket deleted outside Terraform',
      description: 'The S3 bucket defined in Terraform no longer exists in AWS. It may have been deleted manually through the AWS console.',
      detectedAt: '2026-02-26T09:45:00Z',
      suggestedFix: `resource "aws_s3_bucket" "data_lake" {
  bucket = "example-data-lake-prod"

  tags = {
    Name        = "data-lake"
    Environment = "production"
    Owner       = "data-team"
  }
}

resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}`,
      planDiff: `Terraform will perform the following actions:

  # aws_s3_bucket.data_lake will be created
  + resource "aws_s3_bucket" "data_lake" {
      + bucket              = "example-data-lake-prod"
      + id                  = (known after apply)
      + arn                 = (known after apply)
      + region              = (known after apply)
      + tags                = {
          + "Name"        = "data-lake"
          + "Environment" = "production"
          + "Owner"       = "data-team"
        }
    }

  # aws_s3_bucket_versioning.data_lake will be created
  + resource "aws_s3_bucket_versioning" "data_lake" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + versioning_configuration {
          + status = "Enabled"
        }
    }

  # aws_s3_bucket_server_side_encryption_configuration.data_lake will be created
  + resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + rule {
          + apply_server_side_encryption_by_default {
              + sse_algorithm = "AES256"
            }
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.`,
      agentLogs: [],
      status: 'pending',
      workspace: 'prod-infrastructure',
    },
    {
      id: '5',
      severity: 'medium',
      type: 'compliance',
      resourceType: 'aws_instance',
      resourceAddress: 'module.web_app.aws_instance.primary',
      title: 'Instance type does not meet policy requirements',
      description: 'Instance is using t2.micro but organization policy requires t3.small or larger for production workloads.',
      detectedAt: '2026-02-26T07:30:00Z',
      suggestedFix: `resource "aws_instance" "primary" {
  ami           = "ami-0c55b159cbfafe1f0"
- instance_type = "t2.micro"
+ instance_type = "t3.small"
  subnet_id     = var.subnet_id

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name        = "web-app-primary"
    Environment = "production"
  }
}`,
      planDiff: `Terraform will perform the following actions:

  # module.web_app.aws_instance.primary must be replaced
-/+ resource "aws_instance" "primary" {
      ~ id                  = "i-0987654321fedcba0" -> (known after apply)
      ~ instance_type       = "t2.micro" -> "t3.small" # forces replacement
        ami                 = "ami-0c55b159cbfafe1f0"
        # (15 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Warning: This change will destroy and recreate the instance.`,
      agentLogs: [],
      status: 'pending',
      workspace: 'prod-infrastructure',
    },
  ];

  getIssues() {
    return this.issues;
  }

  getIssue(id) {
    return this.issues.find((issue) => issue.id === id);
  }

  acceptFix(issueId) {
    const issue = this.getIssue(issueId);
    if (issue) {
      issue.status = 'accepted';
    }
  }

  rejectFix(issueId) {
    const issue = this.getIssue(issueId);
    if (issue) {
      issue.status = 'rejected';
    }
  }

  async applyRemediation(issueId) {
    const issue = this.getIssue(issueId);
    if (!issue) return;

    issue.status = 'applying';
    issue.agentLogs = [];

    await this._addLog(issue, 'Initializing remediation agent...');
    await this._delay(600);
    await this._addLog(issue, 'Analyzing infrastructure state...');
    await this._delay(800);
    await this._addLog(issue, 'Validating suggested configuration...');
    await this._delay(700);
    await this._addLog(issue, 'Running terraform plan...');
    await this._delay(1200);
    await this._addLog(issue, 'Plan generated successfully');
    await this._delay(500);
    await this._addLog(issue, 'Applying configuration changes...');
    await this._delay(1500);
    await this._addLog(issue, 'Terraform apply completed');
    await this._delay(400);
    await this._addLog(issue, '✓ Remediation applied successfully');

    issue.status = 'applied';
  }

  _addLog(issue, message) {
    const timestamp = new Date().toLocaleTimeString('en-US', {
      hour12: false,
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
    issue.agentLogs.push({ timestamp, message });
  }

  _delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
```

**Step 3: Verify service loads**

```bash
ember serve
```

Expected: App compiles, no errors in console

**Step 4: Commit**

```bash
git add app/services/remediation.js
git commit -m "feat: add remediation service with mock data

Service manages 5 mock issues (drift, compliance, version upgrades)
Includes streaming agent log simulation

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: Create App Layout Component

**Files:**
- Create: `app/components/app-layout.js`
- Create: `app/components/app-layout.hbs`

**Step 1: Generate component**

```bash
ember generate component app-layout --with-component-class
```

**Step 2: Implement layout component**

Modify: `app/components/app-layout.js`

```javascript
import Component from '@glimmer/component';

export default class AppLayoutComponent extends Component {
  // Static mock data for demo
  orgName = 'demo-org';
  projectName = 'production';
}
```

**Step 3: Create layout template**

Modify: `app/components/app-layout.hbs`

```handlebars
<Hds::AppFrame>
  {{! Top header with org/project context }}
  <:header>
    <Hds::AppHeader>
      <:logo>
        <Hds::Link::Standalone @icon="terraform" @text="HCP Terraform" @href="#" />
      </:logo>

      <:utilities>
        <Hds::Dropdown @listPosition="bottom-right" as |dd|>
          <dd.ToggleButton @text={{this.orgName}} />
          <dd.Title @text="Organization" />
          <dd.Interactive @text={{this.orgName}} />
        </Hds::Dropdown>

        <Hds::Dropdown @listPosition="bottom-right" as |dd|>
          <dd.ToggleButton @text={{this.projectName}} />
          <dd.Title @text="Project" />
          <dd.Interactive @text={{this.projectName}} />
        </Hds::Dropdown>
      </:utilities>
    </Hds::AppHeader>
  </:header>

  {{! Side navigation }}
  <:sidebar>
    <Hds::AppSideNav>
      <Hds::AppSideNav::List as |SNL|>
        <SNL.Title>Terraform</SNL.Title>
        <SNL.Link @icon="dashboard" @text="Overview" @href="#" />
        <SNL.Link @icon="folder" @text="Workspaces" @href="#" />
        <SNL.Link @icon="box" @text="Registry" @href="#" />
        <SNL.Link @icon="settings" @text="Settings" @href="#" />
      </Hds::AppSideNav::List>

      <Hds::AppSideNav::List as |SNL|>
        <SNL.Title>Agentic Workflows</SNL.Title>
        <SNL.Link @icon="auto-fix" @text="Remediation" @isActive={{true}} @href="#/remediation" />
      </Hds::AppSideNav::List>
    </Hds::AppSideNav>
  </:sidebar>

  {{! Main content area }}
  <:main>
    {{yield}}
  </:main>
</Hds::AppFrame>
```

**Step 4: Verify layout renders**

Update `app/templates/application.hbs`:

```handlebars
<AppLayout>
  {{outlet}}
</AppLayout>
```

```bash
ember serve
```

Expected: App shows header with org/project dropdowns and side nav

**Step 5: Commit**

```bash
git add app/components/app-layout.* app/templates/application.hbs
git commit -m "feat: add app layout with Helios AppFrame

Includes header with org/project context and side nav with
Agentic Workflows section

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 5: Create Issue Table Component (Dashboard)

**Files:**
- Create: `app/components/issue-table.js`
- Create: `app/components/issue-table.hbs`

**Step 1: Generate component**

```bash
ember generate component issue-table --with-component-class
```

**Step 2: Implement component**

Modify: `app/components/issue-table.js`

```javascript
import Component from '@glimmer/component';

export default class IssueTableComponent extends Component {
  getSeverityColor(severity) {
    const colors = {
      critical: 'critical',
      high: 'warning',
      medium: 'highlight',
      low: 'neutral',
    };
    return colors[severity] || 'neutral';
  }

  getRelativeTime(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now - date;
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));

    if (diffHours < 1) return 'Just now';
    if (diffHours < 24) return `${diffHours}h ago`;
    const diffDays = Math.floor(diffHours / 24);
    return `${diffDays}d ago`;
  }

  getTypeLabel(type) {
    const labels = {
      'drift': 'Drift',
      'compliance': 'Compliance',
      'version-upgrade': 'Version Upgrade',
    };
    return labels[type] || type;
  }
}
```

**Step 3: Create template**

Modify: `app/components/issue-table.hbs`

```handlebars
<Hds::Table @caption="Remediation Issues">
  <:head as |H|>
    <H.Tr>
      <H.Th>Severity</H.Th>
      <H.Th>Type</H.Th>
      <H.Th>Resource</H.Th>
      <H.Th>Detected</H.Th>
      <H.Th>Actions</H.Th>
    </H.Tr>
  </:head>
  <:body as |B|>
    {{#each @issues as |issue|}}
      <B.Tr>
        <B.Td>
          <Hds::Badge
            @text={{issue.severity}}
            @color={{this.getSeverityColor issue.severity}}
          />
        </B.Td>
        <B.Td>
          <Hds::Text::Body @size="200">
            {{this.getTypeLabel issue.type}}
          </Hds::Text::Body>
        </B.Td>
        <B.Td>
          <Hds::Text::Body @size="200">
            {{issue.resourceType}}
          </Hds::Text::Body>
          <Hds::Text::Body @size="100" @color="faint">
            {{issue.resourceAddress}}
          </Hds::Text::Body>
        </B.Td>
        <B.Td>
          <Hds::Text::Body @size="200">
            {{this.getRelativeTime issue.detectedAt}}
          </Hds::Text::Body>
        </B.Td>
        <B.Td>
          <Hds::Button
            @text="View"
            @size="small"
            @color="secondary"
            @route="remediation.detail"
            @model={{issue.id}}
          />
        </B.Td>
      </B.Tr>
    {{/each}}
  </:body>
</Hds::Table>
```

**Step 4: Commit**

```bash
git add app/components/issue-table.*
git commit -m "feat: add issue table component

Displays issues with severity badges, type, resource, and view button

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 6: Create Plan Diff Component

**Files:**
- Create: `app/components/plan-diff.js`
- Create: `app/components/plan-diff.hbs`

**Step 1: Generate component**

```bash
ember generate component plan-diff --with-component-class
```

**Step 2: Install Prism for syntax highlighting**

```bash
pnpm add ember-prism
```

**Step 3: Implement component**

Modify: `app/components/plan-diff.js`

```javascript
import Component from '@glimmer/component';

export default class PlanDiffComponent extends Component {
  // Component receives @code and @language args
}
```

**Step 4: Create template**

Modify: `app/components/plan-diff.hbs`

```handlebars
<Hds::CodeBlock @language={{@language}} @value={{@code}} @hasCopyButton={{true}} />
```

**Step 5: Commit**

```bash
git add app/components/plan-diff.* package.json
git commit -m "feat: add plan diff component

Uses Helios CodeBlock with syntax highlighting for HCL

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 7: Create Agent Log Component

**Files:**
- Create: `app/components/agent-log.js`
- Create: `app/components/agent-log.hbs`

**Step 1: Generate component**

```bash
ember generate component agent-log --with-component-class
```

**Step 2: Implement component with auto-scroll**

Modify: `app/components/agent-log.js`

```javascript
import Component from '@glimmer/component';
import { action } from '@ember/object';

export default class AgentLogComponent extends Component {
  @action
  scrollToBottom(element) {
    element.scrollTop = element.scrollHeight;
  }

  @action
  didUpdateLogs(element) {
    // Auto-scroll when new logs are added
    element.scrollTop = element.scrollHeight;
  }
}
```

**Step 3: Create template**

Modify: `app/components/agent-log.hbs`

```handlebars
<div
  class="agent-log"
  {{did-insert this.scrollToBottom}}
  {{did-update this.didUpdateLogs @logs}}
>
  {{#if @logs.length}}
    {{#each @logs as |log|}}
      <div class="log-entry">
        <Hds::Text::Code @tag="span" @size="100">
          [{{log.timestamp}}]
        </Hds::Text::Code>
        <Hds::Text::Body @tag="span" @size="200">
          {{log.message}}
        </Hds::Text::Body>
      </div>
    {{/each}}
  {{else}}
    <Hds::ApplicationState @align="center" as |A|>
      <A.Header @title="No logs yet" />
      <A.Body @text="Agent logs will appear here when remediation is applied." />
    </Hds::ApplicationState>
  {{/if}}
</div>
```

**Step 4: Add styles**

Add to `app/styles/app.scss`:

```scss
.agent-log {
  background-color: var(--token-color-surface-faint);
  border: 1px solid var(--token-color-border-primary);
  border-radius: 6px;
  padding: 16px;
  max-height: 400px;
  overflow-y: auto;
  font-family: var(--token-typography-font-stack-code);

  .log-entry {
    margin-bottom: 8px;
    display: flex;
    gap: 12px;
    align-items: baseline;

    &:last-child {
      margin-bottom: 0;
    }
  }
}
```

**Step 5: Commit**

```bash
git add app/components/agent-log.* app/styles/app.scss
git commit -m "feat: add agent log component

Displays streaming logs with timestamps and auto-scroll

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 8: Create Remediation Dashboard Route

**Files:**
- Create: `app/routes/remediation/index.js`
- Create: `app/templates/remediation/index.hbs`
- Modify: `app/router.js`

**Step 1: Configure router**

Modify: `app/router.js`:

```javascript
import EmberRouter from '@ember/routing/router';
import config from 'terraform-remediation-demo/config/environment';

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function () {
  this.route('remediation', function() {
    this.route('detail', { path: '/:issue_id' });
  });
});
```

**Step 2: Generate routes**

```bash
ember generate route remediation --path=/remediation
ember generate route remediation/index
```

**Step 3: Implement dashboard route**

Modify: `app/routes/remediation/index.js`:

```javascript
import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class RemediationIndexRoute extends Route {
  @service remediation;

  model() {
    return this.remediation.getIssues();
  }
}
```

**Step 4: Create dashboard template**

Modify: `app/templates/remediation/index.hbs`:

```handlebars
<div class="page-header">
  <Hds::PageHeader as |PH|>
    <PH.Title>Terraform Remediation</PH.Title>
    <PH.Description>
      {{@model.length}} issues detected across prod-infrastructure workspace
    </PH.Description>
  </Hds::PageHeader>
</div>

<div class="page-content">
  <IssueTable @issues={{@model}} />
</div>
```

**Step 5: Add page styles**

Add to `app/styles/app.scss`:

```scss
.page-header {
  margin-bottom: 24px;
}

.page-content {
  padding: 0 24px 24px;
}
```

**Step 6: Update application template to redirect**

Modify `app/routes/application.js`:

```javascript
import Route from '@ember/routing/route';

export default class ApplicationRoute extends Route {
  beforeModel() {
    this.transitionTo('remediation.index');
  }
}
```

Generate if needed:
```bash
ember generate route application
```

**Step 7: Verify dashboard renders**

```bash
ember serve
```

Navigate to http://localhost:4200/

Expected: See dashboard with table of 5 issues

**Step 8: Commit**

```bash
git add app/routes/remediation* app/templates/remediation* app/router.js app/routes/application.js app/styles/app.scss
git commit -m "feat: add remediation dashboard route

Shows table of issues with counts and navigation

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 9: Create Issue Detail Route

**Files:**
- Create: `app/routes/remediation/detail.js`
- Create: `app/templates/remediation/detail.hbs`
- Create: `app/controllers/remediation/detail.js`

**Step 1: Generate route and controller**

```bash
ember generate route remediation/detail
ember generate controller remediation/detail
```

**Step 2: Implement detail route**

Modify: `app/routes/remediation/detail.js`:

```javascript
import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class RemediationDetailRoute extends Route {
  @service remediation;

  model(params) {
    return this.remediation.getIssue(params.issue_id);
  }
}
```

**Step 3: Implement detail controller with actions**

Modify: `app/controllers/remediation/detail.js`:

```javascript
import Controller from '@ember/controller';
import { service } from '@ember/service';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';

export default class RemediationDetailController extends Controller {
  @service remediation;
  @tracked selectedTab = 'fix';
  @tracked showSuccessAlert = false;

  get isAccepted() {
    return this.model.status === 'accepted';
  }

  get isApplying() {
    return this.model.status === 'applying';
  }

  get isApplied() {
    return this.model.status === 'applied';
  }

  @action
  selectTab(tabId) {
    this.selectedTab = tabId;
  }

  @action
  acceptFix() {
    this.remediation.acceptFix(this.model.id);
  }

  @action
  rejectFix() {
    this.remediation.rejectFix(this.model.id);
    // Redirect back to dashboard
    this.transitionToRoute('remediation.index');
  }

  @action
  async applyRemediation() {
    // Switch to logs tab
    this.selectedTab = 'logs';

    // Apply remediation (triggers streaming)
    await this.remediation.applyRemediation(this.model.id);

    // Show success alert
    this.showSuccessAlert = true;
  }

  @action
  dismissAlert() {
    this.showSuccessAlert = false;
  }
}
```

**Step 4: Create detail template**

Modify: `app/templates/remediation/detail.hbs`:

```handlebars
<div class="page-header">
  <Hds::Breadcrumb>
    <Hds::Breadcrumb::Item @text="Remediation" @route="remediation.index" />
    <Hds::Breadcrumb::Item @text="Issue {{@model.id}}" @current={{true}} />
  </Hds::Breadcrumb>

  <Hds::PageHeader as |PH|>
    <PH.Title>{{@model.title}}</PH.Title>
    <PH.Description>
      <Hds::Badge
        @text={{@model.severity}}
        @color={{if (eq @model.severity "critical") "critical"
                  (if (eq @model.severity "high") "warning"
                  (if (eq @model.severity "medium") "highlight" "neutral"))}}
      />
      <Hds::Text::Body @tag="span" @color="faint">
        • {{@model.resourceType}} • {{@model.resourceAddress}}
      </Hds::Text::Body>
    </PH.Description>
  </Hds::PageHeader>
</div>

{{#if this.showSuccessAlert}}
  <Hds::Alert @type="inline" @color="success" @onDismiss={{this.dismissAlert}} as |A|>
    <A.Title>Remediation applied successfully</A.Title>
    <A.Description>
      The infrastructure changes have been applied. {{@model.workspace}} workspace has been updated.
    </A.Description>
  </Hds::Alert>
{{/if}}

<div class="page-content">
  <Hds::Card::Container>
    <Hds::Text::Body>
      {{@model.description}}
    </Hds::Text::Body>
  </Hds::Card::Container>

  <Hds::Tabs @selectedTabIndex={{if (eq this.selectedTab "fix") 0 (if (eq this.selectedTab "diff") 1 2)}} as |T|>
    <T.Tab @count={{null}} {{on "click" (fn this.selectTab "fix")}}>
      Suggested Fix
    </T.Tab>
    <T.Tab @count={{null}} {{on "click" (fn this.selectTab "diff")}}>
      Plan Diff
    </T.Tab>
    <T.Tab @count={{@model.agentLogs.length}} {{on "click" (fn this.selectTab "logs")}}>
      Agent Log
    </T.Tab>

    <T.Panel>
      {{#if (eq this.selectedTab "fix")}}
        <PlanDiff @code={{@model.suggestedFix}} @language="hcl" />
      {{else if (eq this.selectedTab "diff")}}
        <PlanDiff @code={{@model.planDiff}} @language="text" />
      {{else if (eq this.selectedTab "logs")}}
        <AgentLog @logs={{@model.agentLogs}} />
      {{/if}}
    </T.Panel>
  </Hds::Tabs>

  <Hds::ButtonSet>
    {{#unless this.isApplied}}
      {{#if this.isAccepted}}
        <Hds::Button
          @text={{if this.isApplying "Applying..." "Apply Remediation"}}
          @color="primary"
          @isLoading={{this.isApplying}}
          @isDisabled={{this.isApplying}}
          {{on "click" this.applyRemediation}}
        />
      {{else}}
        <Hds::Button
          @text="Accept Fix"
          @color="secondary"
          {{on "click" this.acceptFix}}
        />
      {{/unless}}

      <Hds::Button
        @text="Reject"
        @color="secondary"
        @isDisabled={{this.isApplying}}
        {{on "click" this.rejectFix}}
      />
    {{else}}
      <Hds::Button
        @text="Applied"
        @color="primary"
        @isDisabled={{true}}
      />
    {{/unless}}
  </Hds::ButtonSet>
</div>
```

**Step 5: Add detail page styles**

Add to `app/styles/app.scss`:

```scss
.page-content {
  padding: 0 24px 24px;

  > * + * {
    margin-top: 24px;
  }
}
```

**Step 6: Verify detail page works**

```bash
ember serve
```

Navigate to http://localhost:4200/remediation/1

Expected:
- See issue detail with tabs
- Click "Accept Fix" → button changes to "Apply Remediation"
- Click "Apply Remediation" → switches to Agent Log tab, logs stream in
- After complete, success alert appears

**Step 7: Commit**

```bash
git add app/routes/remediation/detail.js app/templates/remediation/detail.hbs app/controllers/remediation/detail.js app/styles/app.scss
git commit -m "feat: add issue detail route and controller

Full remediation flow: accept, apply with streaming logs, success state

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 10: Polish and Final Verification

**Files:**
- Modify: `app/styles/app.scss`
- Create: `README.md`

**Step 1: Add final polish styles**

Add to `app/styles/app.scss`:

```scss
// Ensure proper spacing throughout
.page-header {
  margin-bottom: var(--token-spacing-04);
  padding: var(--token-spacing-04) var(--token-spacing-04) 0;
}

.page-content {
  padding: 0 var(--token-spacing-04) var(--token-spacing-04);

  > * + * {
    margin-top: var(--token-spacing-04);
  }
}

// Alert spacing
.hds-alert {
  margin: var(--token-spacing-04);
}

// Smooth scrolling for agent logs
.agent-log {
  scroll-behavior: smooth;
}
```

**Step 2: Create README**

Create: `README.md`:

```markdown
# HCP Terraform Agentic Remediation Demo

Frontend-only Ember.js demo showcasing AI-powered Terraform remediation with streaming agent logs.

## Features

- **Dashboard**: View all detected issues (drift, compliance, version upgrades)
- **Issue Detail**: See AI-generated fixes with HCL diffs
- **Streaming Logs**: Watch AI agent execution in real-time
- **Remediation Flow**: Accept, reject, or apply fixes

## Tech Stack

- Ember.js (Octane)
- Helios Design System
- Glimmer components
- Mock data (no backend)

## Installation

```bash
pnpm install
```

## Running

```bash
ember serve
```

Navigate to http://localhost:4200/

## Architecture

- **Service-driven**: Single `remediation` service manages all state
- **Two routes**: Dashboard (`/remediation`) and detail (`/remediation/:id`)
- **Four components**:
  - `app-layout` - AppFrame with header/nav
  - `issue-table` - Dashboard table
  - `plan-diff` - Code/diff viewer
  - `agent-log` - Streaming log display

## Demo Flow

1. View issues on dashboard
2. Click "View" to see issue detail
3. Review suggested fix, plan diff
4. Click "Accept Fix"
5. Click "Apply Remediation"
6. Watch agent logs stream
7. See success confirmation

## Design Document

See `docs/plans/2026-02-26-agentic-remediation-demo-design.md` for full design rationale.

## Notes

- All data is mocked in the frontend
- State resets on page refresh
- No authentication or backend required
- Built with HashiCorp Helios Design System
```

**Step 3: Full manual verification**

Test all flows:

```bash
ember serve
```

Checklist:
- [ ] Dashboard loads with 5 issues
- [ ] Table shows severity badges, types, resources
- [ ] Click "View" navigates to detail page
- [ ] Breadcrumb shows on detail page
- [ ] Three tabs: Suggested Fix, Plan Diff, Agent Log
- [ ] Code blocks have syntax highlighting
- [ ] "Accept Fix" button works
- [ ] "Apply Remediation" streams logs
- [ ] Success alert appears after apply
- [ ] "Reject" button returns to dashboard
- [ ] All Helios components render correctly
- [ ] No console errors

**Step 4: Final commit**

```bash
git add app/styles/app.scss README.md
git commit -m "feat: add final polish and README

Complete styling with Helios tokens and comprehensive documentation

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 11: Create Mock Data Documentation

**Files:**
- Create: `docs/MOCK_DATA.md`

**Step 1: Document mock data structure**

Create: `docs/MOCK_DATA.md`:

```markdown
# Mock Data Reference

## Issue Structure

Each issue object contains:

```javascript
{
  id: string,                    // Unique identifier
  severity: string,              // 'critical' | 'high' | 'medium' | 'low'
  type: string,                  // 'drift' | 'compliance' | 'version-upgrade'
  resourceType: string,          // Terraform resource type
  resourceAddress: string,       // Full resource address in state
  title: string,                 // Short description
  description: string,           // Detailed explanation
  detectedAt: string,            // ISO 8601 timestamp
  suggestedFix: string,          // HCL code with diff markers
  planDiff: string,              // Terraform plan output
  agentLogs: Array<Log>,         // Array of {timestamp, message}
  status: string,                // 'pending' | 'accepted' | 'rejected' | 'applying' | 'applied'
  workspace: string              // Workspace name
}
```

## Current Mock Issues

### Issue 1: Security Group Drift (High)
- **Type**: Drift
- **Resource**: `aws_security_group.web`
- **Problem**: Manually modified to allow 0.0.0.0/0 access
- **Fix**: Restrict to 10.0.0.0/8

### Issue 2: Missing Tags (Medium)
- **Type**: Compliance
- **Resource**: `aws_instance.app_server`
- **Problem**: Missing Owner, CostCenter, Compliance tags
- **Fix**: Add required tags

### Issue 3: Outdated Provider (Low)
- **Type**: Version Upgrade
- **Resource**: AWS provider
- **Problem**: Using v4.67, latest is v5.82
- **Fix**: Update version constraint

### Issue 4: Deleted S3 Bucket (Critical)
- **Type**: Drift
- **Resource**: `aws_s3_bucket.data_lake`
- **Problem**: Bucket deleted outside Terraform
- **Fix**: Recreate with versioning and encryption

### Issue 5: Wrong Instance Type (Medium)
- **Type**: Compliance
- **Resource**: `module.web_app.aws_instance.primary`
- **Problem**: Using t2.micro instead of required t3.small
- **Fix**: Upgrade instance type (requires replacement)

## Adding New Issues

To add a new mock issue, edit `app/services/remediation.js` and add to the `issues` array:

1. Ensure unique `id`
2. Choose appropriate `severity` and `type`
3. Write realistic `suggestedFix` with diff markers (- for removals, + for additions)
4. Write realistic `planDiff` showing Terraform plan output
5. Initialize `agentLogs` as empty array
6. Set `status` to 'pending'

## Simulating Different Scenarios

**To test "accepted" state:**
Click "Accept Fix" button - sets `status` to 'accepted'

**To test "applying" state:**
Click "Apply Remediation" - sets `status` to 'applying', populates `agentLogs`

**To test "applied" state:**
Wait for apply to complete - sets `status` to 'applied', disables button

**To test "rejected" state:**
Click "Reject" button - sets `status` to 'rejected', redirects to dashboard
```

**Step 2: Commit**

```bash
git add docs/MOCK_DATA.md
git commit -m "docs: add mock data reference

Documents issue structure and current mock scenarios

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Completion Checklist

Verify all tasks completed:

- [x] Task 1: Scaffold Ember app
- [x] Task 2: Install Helios
- [x] Task 3: Create remediation service
- [x] Task 4: Create app layout
- [x] Task 5: Create issue table
- [x] Task 6: Create plan diff component
- [x] Task 7: Create agent log component
- [x] Task 8: Create dashboard route
- [x] Task 9: Create detail route
- [x] Task 10: Polish and README
- [x] Task 11: Mock data docs

Final verification:
```bash
ember serve
```

Navigate through entire flow and verify:
- Dashboard shows all issues
- Detail page loads for each issue
- All three tabs work
- Accept/Apply/Reject flow works
- Agent logs stream correctly
- No console errors
- Helios components render properly

---

## Next Steps

**Demo is complete!**

To extend:
1. Add more issue types
2. Create settings page for configuration
3. Add workflow history view
4. Implement filtering/sorting on dashboard
5. Add modal for editing fixes
6. Add export functionality

Refer to design doc (`docs/plans/2026-02-26-agentic-remediation-demo-design.md`) for out-of-scope enhancements.
