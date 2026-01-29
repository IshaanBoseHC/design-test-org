# HCP Terraform UI Steps

These are tasks that cannot be fully automated in Terraform today.

## Organization + VCS

- Create the org in HCP Terraform.
- Connect GitHub/GitLab/Bitbucket and copy the OAuth token ID.
- Invite users and assign teams.

## Private module registry

- Open the private module registry and publish each module from `modules/`.
- Use the monorepo paths:
  - `modules/network`
  - `modules/logging`
  - `modules/identity`
  - `modules/service`
  - `modules/tags`

## Run tasks

- Configure run task integrations (Infracost, Checkov, Wiz, etc.).
- Copy the endpoint URLs for use in `org/run_tasks.tf`.

## Stacks

- Create stack deployments for `dev`, `staging`, and `prod`.
- Point each deployment to the corresponding HCL in `stacks/`.
