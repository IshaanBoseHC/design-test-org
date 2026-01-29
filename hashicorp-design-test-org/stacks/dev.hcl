deployment "dev" {
  stacks = ["./stacks.hcl"]
  variables = {
    environment = "dev"
  }
}
