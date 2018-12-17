defmodule Serialize do
  @moduledoc """
  it
  """

  @type field_name :: atom()
  @type type :: atom()
  @type field :: {atom, [type()]}

  defmacro __using__(_env) do
    quote do
      Module.register_attribute(__MODULE__, :replace_register, accumulate: true)
      #    @on_definition Serialize
      @before_compile Serialize
    end
  end

  defmacro __before_compile__(%Macro.Env{} = macro) do
    with {:ok, raw_fields} <- get_raw_struct_fields(macro) do
      fields =
        raw_fields
        |> parse_struct_fields()

      field_builder_quotes =
        Enum.map(fields, fn {field_name, types} ->
          validator = get_validator_for_field(types)

          quote do
            {unquote(field_name), Map.get(params, Atom.to_string(unquote(field_name)))}
          end
        end)

      quote do
        def deserialize(params) do
          struct =
            %__MODULE__{}
            |> Map.merge(Map.new(unquote(field_builder_quotes)))

          {:ok, struct}
        end
      end
    end
  end

  defp get_validator_for_field(types) when is_list(types) do
    IO.inspect types
  end

  @spec parse_struct_fields(list()) :: [{field_name, [type]}]
  defp parse_struct_fields(struct_fields) do
    Enum.map(struct_fields, fn val ->
      IO.inspect(val)
    end)
  end

  @spec get_raw_struct_fields(Macro.Env.t()) :: {:ok, list} | {:error, :not_found}
  defp get_raw_struct_fields(%Macro.Env{module: module}) do
    module
    |> Module.get_attribute(:type)
    |> Enum.find_value(fn
      {:type,
       {_, _,
        [
          _,
          {_, _,
           [
             _,
             {_, _, fields} | _
           ]}
          | _
        ]}, _} ->
        fields

      _other ->
        false
    end)
    |> case do
      fields when is_list(fields) ->
        {:ok, fields}

      _other ->
        {:error, :not_found}
    end
  end

  # def __on_definition__(env, kind, name, args, guards, body) do
  # end

  # def __on_definition__(_env, other, _name, _args, _guards, _body) do
  # end
end
