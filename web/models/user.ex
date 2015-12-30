defmodule PhoenixTrello.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:id, :first_name, :last_name, :email]}

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :crypted_password, :string
    field :password, :string, virtual: true

    has_many :owned_boards, PhoenixTrello.Board
    has_many :user_boards, PhoenixTrello.UserBoard
    has_many :invited_boards, through: [:user_boards, :board]

    timestamps
  end

  @required_fields ~w(first_name email password)
  @optional_fields ~w(last_name crypted_password)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 5)
    |> put_password_hash
  end

  defp put_password_hash(current_changeset) do
    case current_changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(current_changeset, :crypted_password, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        current_changeset
    end
  end
end
