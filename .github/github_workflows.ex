defmodule GitHubWorkflows do
  @moduledoc """
  Used by a custom tool to generate GitHub workflows.
  Reduces repetition.
  """

  def get do
    repo_name = "prati_ba"
    app_name = "prati-ba"

    %{
      "main.yml" => main_workflow(),
      "pr.yml" => pr_workflow(repo_name, app_name),
      "pr_closure.yml" => pr_closure_workflow(repo_name, app_name)
    }
  end

  defp main_workflow do
    [
      [
        name: "Main",
        on: [
          push: [
            branches: ["main"]
          ]
        ],
        jobs: [
          test: test_job()
        ]
      ]
    ]
  end

  defp pr_workflow(repo_name, app_name) do
    [
      [
        name: "PR",
        on: [
          pull_request: [
            branches: ["main"],
            types: ["opened", "reopened", "synchronize"]
          ]
        ],
        jobs: [
          deploy_preview_app: deploy_preview_app_job(repo_name, app_name),
          test: test_job()
        ]
      ]
    ]
  end

  defp pr_closure_workflow(repo_name, app_name) do
    [
      [
        name: "PR closure",
        on: [
          pull_request: [
            branches: ["main"],
            types: ["closed"]
          ]
        ],
        jobs: [
          delete_preview_app: delete_preview_app_job(repo_name, app_name)
        ]
      ]
    ]
  end

  defp delete_preview_app_job(repo_name, app_name) do
    [
      name: "Delete preview app",
      "runs-on": "ubuntu-latest",
      concurrency: [group: "pr-${{ github.event.number }}"],
      env: [
        FLY_API_TOKEN: "${{ secrets.FLY_API_TOKEN }}",
        REPO_NAME: repo_name
      ],
      steps: [
        [
          uses: "actions/checkout@v2"
        ],
        [
          name: "Delete preview app",
          uses: "almirsarajcic/fly-pr-review-apps@remote-builder",
          with: [
            name: "pr-${{ github.event.number }}-#{app_name}"
          ]
        ],
        [
          name: "Generate token",
          uses: "navikt/github-app-token-generator@v1.1.1",
          id: "generate_token",
          with: [
            "app-id": "${{ secrets.GH_APP_ID }}",
            "private-key": "${{ secrets.GH_APP_PRIVATE_KEY }}"
          ]
        ],
        [
          name: "Delete GitHub environment",
          uses: "strumwolf/delete-deployment-environment@v2.2.3",
          with: [
            token: "${{ steps.generate_token.outputs.token  }}",
            environment: "pr-${{ github.event.number }}-#{app_name}",
            ref: "${{ github.head_ref }}"
          ]
        ]
      ]
    ]
  end

  defp deploy_preview_app_job(repo_name, app_name) do
    [
      name: "Deploy preview app",
      needs: ["test"],
      permissions: "write-all",
      "runs-on": "ubuntu-latest",
      concurrency: [group: "pr-${{ github.event.number }}"],
      env: [
        FLY_API_TOKEN: "${{ secrets.FLY_API_TOKEN }}",
        FLY_ORG: "optimum-bh",
        FLY_REGION: "fra",
        PHX_HOST: "pr-${{ github.event.number }}-#{app_name}.fly.dev",
        REPO_NAME: repo_name
      ],
      environment: [
        name: "pr-${{ github.event.number }}-#{app_name}",
        url: "https://${{ env.PHX_HOST }}"
      ],
      steps: [
        [
          uses: "actions/checkout@v2"
        ],
        [
          name: "Delete previous deployments",
          uses: "strumwolf/delete-deployment-environment@v2.2.3",
          with: [
            token: "${{ secrets.GITHUB_TOKEN }}",
            environment: "pr-${{ github.event.number }}-#{app_name}",
            ref: "${{ github.head_ref }}",
            onlyRemoveDeployments: true
          ]
        ],
        [
          name: "Deploy preview app",
          uses: "almirsarajcic/fly-pr-review-apps@remote-builder",
          with: [
            name: "pr-${{ github.event.number }}-#{app_name}",
            secrets:
              "ADMIN_PASSWORD=${{ secrets.ADMIN_PASSWORD }} MAXMIND_LICENSE_KEY=${{ secrets.MAXMIND_LICENSE_KEY }} PHX_HOST=${{ env.PHX_HOST }} SECRET_KEY_BASE=${{ secrets.SECRET_KEY_BASE }}",
            vm_memory: 1024
          ]
        ]
      ]
    ]
  end

  defp test_job do
    [
      name: "Test",
      "runs-on": "ubuntu-latest",
      services: [
        db: [
          image: "postgres:12",
          ports: ["5432:5432"],
          env: [POSTGRES_PASSWORD: "postgres"],
          options:
            "--health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5"
        ]
      ],
      steps: [
        [
          uses: "actions/checkout@v2"
        ],
        [
          name: "Setup elixir",
          uses: "erlef/setup-beam@v1",
          with: [
            "elixir-version": "1.14.1",
            "otp-version": "25.0.4"
          ]
        ],
        [
          name: "Install rustup",
          uses: "actions-rs/toolchain@v1",
          with: [
            profile: "minimal",
            toolchain: "stable",
            override: true
          ]
        ],
        [
          uses: "actions/cache@v2",
          with: [
            path: "_build\ndeps",
            key:
              "${{ runner.os }}-mix-${{ hashFiles(format('{0}{1}', github.workspace, '/mix.lock')) }}",
            "restore-keys": "${{ runner.os }}-mix-"
          ]
        ],
        [
          name: "Install Dependencies",
          run: "mix deps.get --only test"
        ],
        [
          name: "Compile",
          run: "MIX_ENV=test mix compile --force --warnings-as-errors"
        ],
        [
          name: "Check formatting",
          run: "MIX_ENV=test mix format --check-formatted"
        ],
        [
          name: "Download UAInspector database",
          run: "MIX_ENV=test mix ua_inspector.download --force --quiet"
        ],
        [
          name: "Run Tests",
          run: "mix test"
        ]
      ]
    ]
  end
end
