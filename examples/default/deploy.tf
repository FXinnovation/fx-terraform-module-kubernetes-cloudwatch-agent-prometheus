module "this" {
  source = "../../"

  cluster_name = "fake"
  agent_configuration = {
    agent = {
      region = "ca-central-1"
    }
  }
}
