defmodule LocalIP do
  def get_ip_address do
    {output, 0} = System.cmd("ifconfig", [])

    lines = String.split(output, "\n")

    lines
    |> Enum.chunk_while(
      [],
      fn line, acc ->
        if String.starts_with?(line, "\t") or String.starts_with?(line, " ") do
          {:cont, [line | acc]}
        else
          {:cont, Enum.reverse(acc), [line]}
        end
      end,
      fn acc -> {:cont, Enum.reverse(acc), []} end
    )
    |> Enum.find_value(nil, fn chunk ->
      if Enum.any?(chunk, &String.contains?(&1, "status: active")) do
        Enum.find_value(chunk, nil, fn line ->
          case Regex.run(~r/inet (\d+\.\d+\.\d+\.\d+)/, line) do
            [_, ip] -> ip
            _ -> nil
          end
        end)
      else
        nil
      end
    end) || "No active IP address found"
  end

  def write_phx_host do
    ip_address = get_ip_address()

    if ip_address != "No active IP address found" do
      shell_config_file = find_shell_config_file()

      File.write!(shell_config_file, "\nexport PHX_HOST=#{ip_address}\n", [:append])

      IO.puts "PHX_HOST has been set to #{ip_address} in #{shell_config_file}"
    else
      IO.puts "Could not find a valid IP address."
    end
  end

  defp find_shell_config_file do
    shell = System.get_env("SHELL") |> Path.basename()

    case shell do
      "zsh" -> Path.expand("~/.zshrc")
      "bash" -> Path.expand("~/.bashrc")
      "fish" -> Path.expand("~/.config/fish/config.fish")
      _ -> Path.expand("~/.bash_profile")
    end
  end
end

# Usage
LocalIP.write_phx_host()
