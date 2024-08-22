
Mix.Task.run("app.start")

alias Ecto.Adapters.SQL
alias TripTally.Repo

export_path = System.get_env("DB_TABLES_EXPORT_PATH")

File.mkdir_p!(export_path)

defmodule Exporter do
  def export_table_to_csv(table_name, export_path) do
    query = "COPY #{table_name} TO '#{export_path}#{table_name}.csv' DELIMITER ',' CSV HEADER;"

    case SQL.query(Repo, query) do
      {:ok, _result} ->
        IO.puts("Exported table: #{table_name}")

      {:error, reason} ->
        IO.puts("Failed to export table: #{table_name} - Reason: #{inspect(reason)}")
    end
  end
end

tables_query = "SELECT tablename FROM pg_tables WHERE schemaname = 'public';"
{:ok, result} = SQL.query(Repo, tables_query)

for row <- result.rows do
  [table_name] = row
  Exporter.export_table_to_csv(table_name, export_path)
end

IO.puts("All tables have been exported to #{export_path}")
