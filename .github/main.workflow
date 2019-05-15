workflow "Build and deploy on push" {
  on = "push"
  resolves = [
    "Lint code",
    "Push image",
    "Docker login",
    "Push image to latest",
  ]
}

action "Lint code" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  args = "build --target ci ."
}

action "Build image" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  args = "build -t ovh-ip-updater-go ."
}

action "Tag image" {
  uses = "actions/docker/tag@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = [
    "Build image",
    "Lint code",
  ]
  args = "ovh-ip-updater-go sazap10/ovh-ip-updater-go"
}

action "Push image" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Docker login"]
  args = "push sazap10/ovh-ip-updater-go:$GITHUB_SHA"
}

action "Branch filter" {
  uses = "actions/bin/filter@3c0b4f0e63ea54ea5df2914b4fabf383368cd0da"
  needs = ["Docker login"]
  args = "branch master"
}

action "Docker login" {
  uses = "actions/docker/login@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Tag image"]
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "Push image to latest" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Branch filter"]
  args = "push sazap10/ovh-ip-updater-go:latest"
}