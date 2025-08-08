defmodule Discogrify.Utils.ChangesetHelpers do
  @moduledoc """
  Utility functions for working with Ecto changesets.
  """

  @doc """
  Translates changeset errors into a readable format.

  ## Examples

      iex> changeset = %Ecto.Changeset{errors: [name: {"can't be blank", [validation: :required]}]}
      iex> Discogrify.Utils.ChangesetHelpers.translate_errors(changeset)
      %{name: ["can't be blank"]}

  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @doc """
  Returns a formatted error message string from a changeset.

  ## Examples

      iex> changeset = %Ecto.Changeset{errors: [name: {"can't be blank", [validation: :required]}]}
      iex> Discogrify.Utils.ChangesetHelpers.format_errors(changeset)
      "name can't be blank"

  """
  def format_errors(changeset) do
    changeset
    |> translate_errors()
    |> Enum.map(fn {field, errors} ->
      "#{field} #{Enum.join(errors, ", ")}"
    end)
    |> Enum.join(", ")
  end
end
