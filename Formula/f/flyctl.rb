class Flyctl < Formula
  desc "Command-line tools for fly.io services"
  homepage "https://fly.io"
  url "https://github.com/superfly/flyctl.git",
      tag:      "v0.1.95",
      revision: "001cdfdf42dbb5789a24b73e93d8965ba1131940"
  license "Apache-2.0"
  head "https://github.com/superfly/flyctl.git", branch: "master"

  # Upstream tags versions like `v0.1.92` and `v2023.9.8` but, as of writing,
  # they only create releases for the former and those are the versions we use
  # in this formula. We could omit the date-based versions using a regex but
  # this uses the `GithubLatest` strategy, as the upstream repository also
  # contains over a thousand tags (and growing).
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "80b390cf7f36164c23b7e8fb8f5a044be93194e4e4dbed3f33c818fd430686e1"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "80b390cf7f36164c23b7e8fb8f5a044be93194e4e4dbed3f33c818fd430686e1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "80b390cf7f36164c23b7e8fb8f5a044be93194e4e4dbed3f33c818fd430686e1"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "80b390cf7f36164c23b7e8fb8f5a044be93194e4e4dbed3f33c818fd430686e1"
    sha256 cellar: :any_skip_relocation, sonoma:         "49527a7d654aa83112056dfa39eeecfc34a3171177778e07c19c6c4de97b621d"
    sha256 cellar: :any_skip_relocation, ventura:        "49527a7d654aa83112056dfa39eeecfc34a3171177778e07c19c6c4de97b621d"
    sha256 cellar: :any_skip_relocation, monterey:       "49527a7d654aa83112056dfa39eeecfc34a3171177778e07c19c6c4de97b621d"
    sha256 cellar: :any_skip_relocation, big_sur:        "49527a7d654aa83112056dfa39eeecfc34a3171177778e07c19c6c4de97b621d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "f0e498217cb9580474eb6c6f7ca03cefe70588e6d48ae1048681a9a84f873315"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/superfly/flyctl/internal/buildinfo.environment=production
      -X github.com/superfly/flyctl/internal/buildinfo.buildDate=#{time.iso8601}
      -X github.com/superfly/flyctl/internal/buildinfo.version=#{version}
      -X github.com/superfly/flyctl/internal/buildinfo.commit=#{Utils.git_short_head}
    ]
    system "go", "build", *std_go_args(ldflags: ldflags)

    bin.install_symlink "flyctl" => "fly"

    generate_completions_from_executable(bin/"flyctl", "completion")
  end

  test do
    assert_match "flyctl v#{version}", shell_output("#{bin}/flyctl version")

    flyctl_status = shell_output("#{bin}/flyctl status 2>&1", 1)
    assert_match "Error: No access token available. Please login with 'flyctl auth login'", flyctl_status
  end
end
