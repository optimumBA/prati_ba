Application.ensure_all_started(:ex_machina)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(PratiBa.Repo, :manual)
Application.ensure_all_started(:bypass)

Mox.defmock(PratiBa.Scrapers.ScraperMock, for: PratiBa.Scrapers.Scraper)
