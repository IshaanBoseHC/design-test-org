deployment "prod" {
  stacks = ["./stacks.hcl"]
  variables = {
    environment = "prod"
  }
}
