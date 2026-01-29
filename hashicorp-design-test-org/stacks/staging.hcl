deployment "staging" {
  stacks = ["./stacks.hcl"]
  variables = {
    environment = "staging"
  }
}
