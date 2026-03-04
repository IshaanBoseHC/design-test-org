# HDS Terraform Remediation Prototype

**A prototype UI demonstrating agentic Terraform remediation workflows and audit trails**

This prototype explores how AI agents can automatically remediate Terraform infrastructure issues while providing comprehensive transparency and audit trails through the Helios Design System (HDS).

## 🎯 What This Prototype Demonstrates

### 1. **Agent Logs with Job Details**
- **Overview cards** displaying recent remediation jobs with summary information
- **Job details flyout** providing deep transparency into agent actions:
  - What the agent did (grouped by security rules/controls)
  - Why it took those actions (rule descriptions with documentation links)
  - Related pull requests created across workspaces
  - Complete job metadata and timeline

### 2. **Workflows Page**
- Visual representation of remediation workflows
- Integration points for Terraform Cloud workspaces
- Agent configuration and control interfaces

### 3. **Projects Page**
- Project-level views of Terraform infrastructure
- Integration with GitHub repositories
- Pull request tracking and management

## 🛠 Tech Stack

- **Ember.js 6.11.0** - Modern Octane framework
- **Vite** - Fast build tool and dev server
- **HDS 6.0.0** - Helios Design System components
- **Sass** - Styling with HDS design tokens
- **pnpm** - Package management

## 📦 Project Structure

```
hdsproto/
├── hdsproto/              # Main Ember application
│   ├── app/
│   │   ├── components/    # Reusable UI components
│   │   │   ├── agent-logs-page.{js,hbs}     # Agent logs with flyout
│   │   │   ├── workflows-page.{js,hbs}      # Workflows interface
│   │   │   ├── projects-page.{js,hbs}       # Projects view
│   │   │   └── agent-configuration.{js,hbs} # Agent config
│   │   ├── templates/     # Route templates
│   │   ├── routes/        # Route handlers
│   │   └── styles/        # Global styles
│   ├── tests/             # QUnit tests
│   └── public/            # Static assets
├── docs/
│   └── plans/             # Design docs and implementation plans
├── terraform/             # Terraform demo infrastructure
└── package.json           # Root dependencies
```

## 🚀 Getting Started

### Prerequisites

- **Node.js**: >= 20.x
- **pnpm**: 10.28.2 or higher

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/IshaanBoseHC/remediationprototype.git
   cd remediationprototype
   ```

2. **Install dependencies**
   ```bash
   cd hdsproto
   pnpm install
   ```

3. **Start the development server**
   ```bash
   pnpm start
   ```

4. **Open your browser**
   ```
   http://localhost:4203
   ```

### First Time Setup

If you encounter a blank page on first run:
1. Clear Vite cache: `rm -rf hdsproto/node_modules/.vite`
2. Restart dev server: `pnpm start`

## 🧪 Development

### Available Commands

```bash
# Development server (Vite)
pnpm start

# Build for production
pnpm build

# Run tests
pnpm test

# Lint all code
pnpm lint

# Format code
pnpm format

# Fix linting issues
pnpm lint:fix
```

### Key Features to Explore

#### 1. Agent Logs Page (`/agent-logs`)
- Browse recent remediation jobs
- Click the **arrow button** in any job card to open the details flyout
- Explore grouped actions by security rule/control
- View related pull requests

#### 2. Workflows Page (`/workflows`)
- Configure agent workflows
- View workflow execution status
- Manage workspace integrations

#### 3. Projects Page (`/projects`)
- Browse Terraform projects
- Track GitHub repository connections
- Monitor pull request status

## 🎨 Design System

This prototype uses the [Helios Design System (HDS)](https://helios.hashicorp.design/) v6.0.0:

### Key Components Used
- `Hds::AppHeader` - Application header with navigation
- `Hds::SideNav` - Sidebar navigation
- `Hds::Flyout` - Right-side panel for job details
- `Hds::Badge` - Status indicators
- `Hds::Button` - Interactive elements
- `Hds::Card` - Content containers
- `Hds::Tabs` - Tabbed navigation
- `Hds::Text::*` - Typography components

### Styling Configuration

HDS requires specific Sass include paths (configured in `ember-cli-build.js`):

```javascript
sassOptions: {
  includePaths: [
    'node_modules/@hashicorp/design-system-components/dist/styles',
    'node_modules/@hashicorp/design-system-tokens/dist/products/css',
  ],
}
```

## 📚 Documentation

Detailed design and implementation documentation is available in `docs/plans/`:

- **[Agent Logs Job Details Flyout - Design](docs/plans/2026-03-04-agent-logs-job-details-flyout-design.md)**
  - Complete design specification for the job details flyout
  - Data model, component architecture, and UX flows

- **[Agent Logs Job Details Flyout - Implementation](docs/plans/2026-03-04-agent-logs-job-details-flyout.md)**
  - Step-by-step implementation plan with TDD approach
  - Task breakdown and commit strategy

- **[Demo GitHub PRs - Design](docs/plans/2026-03-03-demo-github-prs-design.md)**
  - Design for GitHub PR integration

- **[Demo GitHub PRs - Implementation](docs/plans/2026-03-03-demo-github-prs.md)**
  - Implementation plan for PR workflows

## 🐛 Known Issues

### Blank Page on Initial Load
**Symptom**: Application loads but shows blank white page
**Solution**:
```bash
rm -rf node_modules/.vite
pnpm start
```

### Test Failures
**Note**: One pre-existing test failure in workflows route is unrelated to prototype features.

## 🏗 Architecture

### Layout Structure

The application uses a manual flexbox layout (not `Hds::AppFrame`):
- **Top**: `Hds::AppHeader` with navigation
- **Middle**: Flex container with:
  - **Left**: `Hds::AppSideNav` (250px fixed width)
  - **Right**: Main content area (flex-grow with 2rem padding)

### State Management

Components use Ember's tracked properties and actions:
- `@tracked` decorators for reactive state
- `@action` decorators for event handlers
- Mock data in components for prototype demonstration

### Data Flow

Current implementation uses mock data embedded in components. In production:
1. Route handlers fetch data from APIs
2. Data passed to components via arguments
3. Components trigger actions back to routes
4. Routes update backend via services

## 🤝 Contributing

This is a prototype for exploration and demonstration. When adapting for production:

1. Replace mock data with real API integration
2. Add proper error handling and loading states
3. Implement authentication and authorization
4. Add comprehensive test coverage
5. Set up CI/CD pipelines

## 📝 License

MIT License - See LICENSE file for details

## 🔗 Related Resources

- [Helios Design System Documentation](https://helios.hashicorp.design/)
- [Ember.js Guides](https://guides.emberjs.com/release/)
- [Terraform Cloud API Documentation](https://developer.hashicorp.com/terraform/cloud-docs/api-docs)

## 💡 Key Insights from This Prototype

### Agent Transparency Design Pattern
- Group actions by **rules/controls** rather than timeline or workspace
- Show **why** (the rule) before **what** (the action)
- Link to external documentation for rule details
- Bidirectional navigation between rules and PRs

### Component Architecture
- Use `Hds::Flyout` for side panels (not modals with custom CSS)
- Keep state management in parent components
- Pass actions down, emit events up
- Prefer tracked properties over computed properties

### Development Workflow
- Design documents before implementation
- TDD approach with frequent commits
- Spec compliance review before code quality review
- Iterate on feedback loops

---

**Built with ❤️ using Ember.js and Helios Design System**
