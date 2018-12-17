defmodule SerializeTest do
  use ExUnit.Case

  defmodule User do
    use Serialize

    alias User.Config

    @type t :: %User{
            username: String.t() | atom,
          }

    defstruct [:username]
  end

  describe "create_struct/1" do
    test "should successfully create a struct for a valid map" do
      {:ok, %User{username: "MainShayne233"}} =
        User.deserialize(%{"username" => "MainShayne233"})
    end

    test "should fail create a struct if an invalid type is supplied" do
      {:error, [username: :invalid_type]} =
        User.deserialize(%{"username" => :MainShayne233})
    end
  end
end
