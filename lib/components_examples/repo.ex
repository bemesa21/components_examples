defmodule ComponentsExamples.Repo do
  use Ecto.Repo,
    otp_app: :components_examples,
    adapter: Ecto.Adapters.Postgres
end
