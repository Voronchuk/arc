defmodule Arc.Transformations.Convert do
  def apply(cmd, file, args) do
    new_path = Arc.File.generate_temporary_path(file)
    apply(cmd, file, args, new_path)
  end
  def apply(cmd, file, args, :png) do
    new_path = Arc.File.generate_temporary_path(file) <> ".png"
    apply(cmd, file, args, new_path)
  end
  def apply(cmd, file, args, :jpg) do
    new_path = Arc.File.generate_temporary_path(file) <> ".jpg"
    apply(cmd, file, args, new_path)
  end
  def apply(cmd, file, args, new_path) do
    args     = if is_function(args), do: args.(file.path, new_path), else: [file.path | (String.split(args, " ") ++ [new_path])]
    program  = to_string(cmd)

    ensure_executable_exists!(program)

    case System.cmd(program, args_list(args), stderr_to_stdout: true) do
      {_, 0} ->
        {:ok, %Arc.File{file | path: new_path}}
      {error_message, _exit_code} ->
        {:error, error_message}
    end
  end

  defp args_list(args) when is_list(args), do: args
  defp args_list(args), do: ~w(#{args})

  defp ensure_executable_exists!(program) do
    unless System.find_executable(program) do
      raise Arc.MissingExecutableError, message: program
    end
  end
end
